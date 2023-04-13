// Copyright 2023 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Nicole Narr <narrn@student.ethz.ch>
// Christopher Reinwardt <creinwar@student.ethz.ch>
// Paul Scheffler <paulsc@iis.ee.ethz.ch>

#include "hal/i2c_24fc1025.h"
#include "i2c_regs.h"
#include "util.h"
#include "params.h"

#include "dif/clint.h"

int i2c_24fc1025_init(dif_i2c_t *i2c, uint64_t core_freq) {
    // Check for legal arguments
    CHECK_ASSERT(0x11, i2c != 0);
    CHECK_ASSERT(0x12, core_freq != 0);
    // Initialize handle
    mmio_region_t i2c_base = (mmio_region_t){.base = (void *)&__base_i2c};
    CHECK_CALL(dif_i2c_init(i2c_base, i2c))
    // Disable I2C in case enabled and reset FIFOs
    CHECK_CALL(dif_i2c_host_set_enabled(i2c, kDifToggleDisabled))
    CHECK_CALL(dif_i2c_reset_acq_fifo(i2c))
    CHECK_CALL(dif_i2c_reset_fmt_fifo(i2c))
    CHECK_CALL(dif_i2c_reset_rx_fifo(i2c))
    CHECK_CALL(dif_i2c_reset_tx_fifo(i2c))
    // Set up timing: worst case 24FC1025 @1.8V
    dif_i2c_timing_config_t timing_config = {
        .clock_period_nanos = (uint64_t)(1e9) / core_freq, // From system-side clock
        .lowest_target_device_speed = kDifI2cSpeedFast,    // Fast mode: up to 400 kBaud
        .scl_period_nanos = 1000000 / 400,                 // Max supported speed
        .sda_fall_nanos = 300,                             // From 24FC1025 datasheet
        .sda_rise_nanos = 100                              // From 24FC1025 datasheet
    };
    // Configure I2C
    dif_i2c_config_t config;
    CHECK_CALL(dif_i2c_compute_timing(timing_config, &config))
    CHECK_CALL(dif_i2c_configure(i2c, config))
    // Enable host functionality (no traps or interrupts)
    CHECK_CALL(dif_i2c_host_set_enabled(i2c, kDifToggleEnabled))
    // Nothing went wrong
    return 0;
}

static inline int __i2c_24fc1025_access_chunk(dif_i2c_t *i2c, void *buf, uint64_t addr,
                                              uint64_t len, int write) {
    // Wait for all FIFOs to be vacated
    uint8_t lfmt, lrx, ltx, lacq;
    do CHECK_CALL(dif_i2c_get_fifo_levels(i2c, &lfmt, &lrx, &ltx, &lacq))
    while (lfmt || lrx || ltx || lacq);
    // Disable host until TX FIFO contains entire TX data to prevent (fatal) TX stalls
    clint_spin_ticks(1);
    CHECK_CALL(dif_i2c_host_set_enabled(i2c, kDifToggleDisabled))
    // 0xA0 identifies an 24FC1025 on the bus, followed by block and chip selects.
    // We overflow addresses to that device's upper block first, then further devices if any.
    uint64_t ctrl_waddr = 0xA0 | ((addr & 0x10000) >> 1) | ((addr & 0x1100000) >> 4);
    // Write address
    CHECK_CALL(dif_i2c_write_byte(i2c, ctrl_waddr, kDifI2cFmtStart, true))
    CHECK_CALL(dif_i2c_write_byte(i2c, (addr >> 8) & 0xFF, kDifI2cFmtTx, true))
    CHECK_CALL(dif_i2c_write_byte(i2c, addr & 0xFF, write ? kDifI2cFmtTx : kDifI2cFmtTxStop, true))
    // From here, either read from or write to bus
    if (write) {
        // For safe writes, we make *two* writes of half-block size.
        // Fill at most half the FIFO immediately to avoid overflow
        uint64_t half_fill = I2C_PARAM_FIFO_DEPTH / 2;
        // Send out all except last byte of half transfer, which needs stop bit
        for (uint64_t b = 0; b < MIN(len - 1, half_fill); b++)
            CHECK_CALL(dif_i2c_write_byte(i2c, ((uint8_t *)buf)[b], kDifI2cFmtTx, true))
        // Send out last byte with stop bit
        CHECK_CALL(dif_i2c_write_byte(i2c, ((uint8_t *)buf)[len - 1], kDifI2cFmtTx, true))
        // Enable the host to launch the half transfer
        CHECK_CALL(dif_i2c_host_set_enabled(i2c, kDifToggleEnabled))
        // If our length exceeded half the FIFO, invoke another half transfer
        if (len > half_fill)
            CHECK_CALL(__i2c_24fc1025_access_chunk(i2c, buf + len, addr + len, len - half_fill, 1))
    } else {
        // Request read of len bytes
        uint64_t ctrl_rdata = ctrl_waddr | 0x1;
        CHECK_CALL(dif_i2c_write_byte(i2c, ctrl_rdata, kDifI2cFmtStart, true))
        CHECK_CALL(dif_i2c_write_byte(i2c, len, kDifI2cFmtRx, false))
        // Re-enable host (no more bytes to write for this chunk)
        CHECK_CALL(dif_i2c_host_set_enabled(i2c, kDifToggleEnabled))
        // Wait for read chunk to be fully received
        do CHECK_CALL(dif_i2c_get_fifo_levels(i2c, &lfmt, &lrx, &ltx, &lacq))
        while (lrx < len);
        // Transfer chunk to memory destination
        for (int b = 0; b < len; b++) CHECK_CALL(dif_i2c_read_byte(i2c, buf + b))
    }
    // Nothing went wrong
    return 0;
}

static inline int __i2c_24fc1025_access(void *priv, void *buf, uint64_t addr, uint64_t len,
                                        int write) {
    // Ensure that FIFO size divides device pages (and hence is a power of two)
    CHECK_ASSERT(0x13, 128 % I2C_PARAM_FIFO_DEPTH == 0);
    // The private pointer passed is an I2C handle
    dif_i2c_t *i2c = (dif_i2c_t *)priv;
    // Align to FIFO size boundary if necessary
    uint64_t addr_offs = addr % I2C_PARAM_FIFO_DEPTH;
    uint64_t offs = 0;
    if (addr_offs) {
        offs = I2C_PARAM_FIFO_DEPTH - addr_offs;
        CHECK_CALL(__i2c_24fc1025_access_chunk(i2c, buf, addr, offs, write))
    }
    // Copy start-aligned chunks
    for (; offs < len; offs += I2C_PARAM_FIFO_DEPTH) {
        uint64_t chunk_len = MIN(I2C_PARAM_FIFO_DEPTH, len - offs);
        CHECK_CALL(__i2c_24fc1025_access_chunk(i2c, buf + offs, addr + offs, chunk_len, write))
    }
    // Nothing went wrong
    return 0;
}

int i2c_24fc1025_read(void *priv, void *buf, uint64_t addr, uint64_t len) {
    return __i2c_24fc1025_access(priv, buf, addr, len, 0);
}

int i2c_24fc1025_write(void *priv, void *buf, uint64_t addr, uint64_t len) {
    return __i2c_24fc1025_access(priv, buf, addr, len, 1);
}
