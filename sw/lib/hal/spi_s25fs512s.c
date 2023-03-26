// Copyright 2023 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Nicole Narr <narrn@student.ethz.ch>
// Christopher Reinwardt <creinwar@student.ethz.ch>
// Paul Scheffler <paulsc@iis.ee.ethz.ch>

#include "hal/spi_s25fs512s.h"
#include "spi_host_regs.h"
#include "util.h"
#include "params.h"

int spi_s25fs512s_init(spi_s25fs512s_t *handle, uint64_t core_freq) {
    // Check for legal arguments
    CHECK_ASSERT(0x11, handle != 0)
    CHECK_ASSERT(0x12, handle->csid < SPI_HOST_PARAM_NUM_C_S)
    CHECK_ASSERT(0x13, handle->spi_freq != 0)
    CHECK_ASSERT(0x14, handle->spi_freq <= core_freq)
    // Initialize handle
    mmio_region_t spi_host_base = (mmio_region_t){.base = (void *)&__base_spih};
    CHECK_CALL(dif_spi_host_init(spi_host_base, &handle->spi_host))
    // Reset SPI host
    dif_spi_host_reset(&handle->spi_host);
    // Configure SPI host for s25fs512s
    dif_spi_host_config_t config = {
        .chip_select = {.idle = 0xF, .lead = 0xF, .trail = 0xF},
        .cpha = 0,
        .cpol = 0,
        .full_cycle = false,
        .peripheral_clock_freq_hz = core_freq,
        .spi_clock = handle->spi_freq
    };
    CHECK_CALL(dif_spi_host_configure_cs(&handle->spi_host, config, handle->csid))
    // Enable SPI host (no traps or interrupts)
    dif_spi_host_enable(&handle->spi_host, 1);
    CHECK_CALL(dif_spi_host_output_set_enabled(&handle->spi_host, 1))
    // Nothing went wrong
    return 0;

}

static inline int __spi_s25fs512s_single_read_chunk(spi_s25fs512s_t *handle, void* buf,
                                                    uint64_t addr, uint64_t len) {
    // Define 3 segments: opcode, address, RX of data
    dif_spi_host_segment_t segs[] = {
        {kDifSpiHostSegmentTypeOpcode, {.opcode = 0x13}},
        {kDifSpiHostSegmentTypeAddress, {.address = {
            .width = kDifSpiHostWidthStandard,
            .mode = kDifSpiHostAddrMode4b,
            .address = addr }}},
        {kDifSpiHostSegmentTypeRx, {.rx = {
            .width = kDifSpiHostWidthStandard,
            .buf = buf,
            .length = len }}}
    };
    CHECK_CALL(dif_spi_host_transaction(&handle->spi_host, handle->csid, segs, 3))
    // Nothing went wrong
    return 0;
}

int spi_s25fs512s_single_read(void *priv, void* buf, uint64_t addr, uint64_t len) {
    // The private pointer passed is a device handle
    spi_s25fs512s_t *handle = (spi_s25fs512s_t*) priv;
    // Top speed for the used command is 50 MHz
    CHECK_ASSERT(0x15, handle->spi_freq < 50*1000*1000)
    // Copy in chunks (no alignment necessary)
    for (uint64_t offs = 0; offs < len; offs += 4*SPI_HOST_PARAM_RX_DEPTH) {
        uint64_t chunk_len = MIN(4*SPI_HOST_PARAM_RX_DEPTH, len - offs);
        CHECK_CALL(__spi_s25fs512s_single_read_chunk(handle, buf + offs, addr + offs, chunk_len))
    }
    // Nothing went wrong
    return 0;
}

// Poll the write in progress (WIP) register until it is 0
static inline int __spi_s25fs512s_poll_wip(spi_s25fs512s_t *handle) {
    uint8_t status_reg_1;
    do {
        dif_spi_host_segment_t segs[] = {
            {kDifSpiHostSegmentTypeOpcode, {.opcode = 0x05}},
            {kDifSpiHostSegmentTypeRx, {.rx = {
                .width = kDifSpiHostWidthStandard,
                .buf = &status_reg_1,
                .length = 1 }}}
        };
        CHECK_CALL(dif_spi_host_transaction(&handle->spi_host, handle->csid, segs, 2))
    } while (status_reg_1 & 1);
    // Return actual status for error checking, masking away non-error bits
    return status_reg_1 & 0b01100000;
}

static inline int __spi_s25fs512s_single_flash_page(spi_s25fs512s_t *handle, void* buf,
                                                    uint64_t page) {
    // Erase two 256B sectors, equal to one 512B page
    for (int i = 0; i < 2; ++i) {
        dif_spi_host_segment_t segs[] = {
            {kDifSpiHostSegmentTypeOpcode, {.opcode = 0xDC}},
            {kDifSpiHostSegmentTypeAddress, {.address = {
                .width = kDifSpiHostWidthStandard,
                .mode = kDifSpiHostAddrMode4b,
                .address = (page << 9) + (i << 8) }}}
        };
        CHECK_CALL(dif_spi_host_transaction(&handle->spi_host, handle->csid, segs, 2))
        // Poll WIP until erase is complete
        CHECK_CALL(__spi_s25fs512s_poll_wip(handle))
    }
    // Program one 512B page with provided data at single speed
    dif_spi_host_segment_t segs[] = {
        {kDifSpiHostSegmentTypeOpcode, {.opcode = 0x12}},
        {kDifSpiHostSegmentTypeAddress, {.address = {
            .width = kDifSpiHostWidthStandard,
            .mode = kDifSpiHostAddrMode4b,
            .address = (page << 9) }}},
        {kDifSpiHostSegmentTypeRx, {.rx = {
            .width = kDifSpiHostWidthStandard,
            .buf = buf,
            .length = 512 }}}
    };
    CHECK_CALL(dif_spi_host_transaction(&handle->spi_host, handle->csid, segs, 3))
    // Poll WIP until erase is complete
    CHECK_CALL(__spi_s25fs512s_poll_wip(handle))
    // Nothing went wrong
    return 0;
}

int spi_s25fs512s_single_flash(void *priv, void* buf, uint64_t page, uint64_t num_pages) {
    // The private pointer passed is a device handle
    spi_s25fs512s_t *handle = (spi_s25fs512s_t*) priv;
    // Top speed for the used commands is 100 MHz
    CHECK_ASSERT(0x16, handle->spi_freq < 100*1000*1000)
    // Ensure write enable (WREN) control register is set
    dif_spi_host_segment_t wren = {kDifSpiHostSegmentTypeOpcode, {.opcode = 0x06}};
    CHECK_CALL(dif_spi_host_transaction(&handle->spi_host, handle->csid, &wren, 1))
    // Flash the requested pages
    for (uint64_t p = 0; p < num_pages; ++p) {
        CHECK_CALL(__spi_s25fs512s_single_flash_page(handle, buf + (p << 9), page + p));
    }
    // Nothing went wrong
    return 0;
}
