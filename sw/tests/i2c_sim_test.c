// Copyright 2022 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Nicole Narr <narrn@student.ethz.ch>
// Christopher Reinwardt <creinwar@student.ethz.ch>

#include "printf.h"
#include "sw/device/lib/base/mmio.h"
#include "sw/device/lib/dif/dif_i2c.h"
#include "trap.h"
#include "uart.h"
#include "util.h"
#include <stdint.h>

#define CORE_FREQ_HZ 200000000

char uart_initialized = 0;

extern void *__base_i2c;

void __attribute__((aligned(4))) trap_vector(void) { test_trap_vector(&uart_initialized); }

int main(void) {
    init_uart(CORE_FREQ_HZ, 115200);
    uart_initialized = 1;

    // Variables for FIFO polling
    uint8_t fmt_fifo_level, rx_fifo_level;

    // Obtain handle to I2C
    mmio_region_t i2c_base = (mmio_region_t){.base = (void *)&__base_i2c};

    dif_i2c_params_t i2c_params = {.base_addr = i2c_base};
    dif_i2c_t i2c;
    CHECK_ELSE_TRAP(dif_i2c_init(i2c_params, &i2c), kDifI2cOk)

    // Configure I2C: worst case 24xx1025 @1.7V
    const uint32_t per_periph_ns = 1000 * 1000 * 1000 / CORE_FREQ_HZ;
    const dif_i2c_timing_config_t timing_config = {
        .clock_period_nanos = per_periph_ns,            // System-side periph clock
        .lowest_target_device_speed = kDifI2cSpeedFast, // Fast mode: max 400 kBaud
        .scl_period_nanos = 1000000 / 333,              // Slower to meet t_sda_rise
        .sda_fall_nanos = 300,                          // See 24xx1025 datasheet
        .sda_rise_nanos = 1000                          // See 24xx1025 datasheet
    };
    dif_i2c_config_t config;
    CHECK_ELSE_TRAP(dif_i2c_compute_timing(timing_config, &config), kDifI2cOk)
    CHECK_ELSE_TRAP(dif_i2c_configure(&i2c, config), kDifI2cOk)

    // Enable host functionality
    // We do *not* set up any interrupts; traps of any kind should be fatal
    CHECK_ELSE_TRAP(dif_i2c_host_set_enabled(&i2c, kDifI2cToggleEnabled), kDifI2cOk)

    // Address first 24FC1025 with a write request
    CHECK_ELSE_TRAP(dif_i2c_write_byte(&i2c, 0b10100000, kDifI2cFmtStart, true), kDifI2cOk)

    // Write high address byte
    CHECK_ELSE_TRAP(dif_i2c_write_byte(&i2c, 0x0, kDifI2cFmtTx, true), kDifI2cOk)

    // Write low address byte
    CHECK_ELSE_TRAP(dif_i2c_write_byte(&i2c, 0x0, kDifI2cFmtTx, true), kDifI2cOk)

    // Write 4 bytes to eeprom
    CHECK_ELSE_TRAP(dif_i2c_write_byte(&i2c, 0xde, kDifI2cFmtTx, true), kDifI2cOk)
    CHECK_ELSE_TRAP(dif_i2c_write_byte(&i2c, 0xad, kDifI2cFmtTx, true), kDifI2cOk)
    CHECK_ELSE_TRAP(dif_i2c_write_byte(&i2c, 0xbe, kDifI2cFmtTx, true), kDifI2cOk)
    CHECK_ELSE_TRAP(dif_i2c_write_byte(&i2c, 0xef, kDifI2cFmtTxStop, true), kDifI2cOk)

    // Wait for sending to complete
    do
        CHECK_ELSE_TRAP(dif_i2c_get_fifo_levels(&i2c, &fmt_fifo_level, &rx_fifo_level), kDifI2cOk)
    while (fmt_fifo_level != 0);

    bool nak_set = 1;
    do {
        // Check if the write process is done
        CHECK_ELSE_TRAP(dif_i2c_write_byte(&i2c, 0b10100000, kDifI2cFmtStart, false), kDifI2cOk)

        // Wait for sending to complete
        do
            CHECK_ELSE_TRAP(dif_i2c_get_fifo_levels(&i2c, &fmt_fifo_level, &rx_fifo_level), kDifI2cOk)
        while (fmt_fifo_level != 0);

        CHECK_ELSE_TRAP(dif_i2c_irq_is_pending(&i2c, kDifI2cIrqNak, &nak_set), kDifI2cOk)
        CHECK_ELSE_TRAP(dif_i2c_irq_acknowledge(&i2c, kDifI2cIrqNak), kDifI2cOk)
    } while (nak_set);

    PRINTF("Write done\r\n");

    // Reset address
    CHECK_ELSE_TRAP(dif_i2c_write_byte(&i2c, 0b10100000, kDifI2cFmtStart, false), kDifI2cOk)

    // Write high address byte
    CHECK_ELSE_TRAP(dif_i2c_write_byte(&i2c, 0x0, kDifI2cFmtTx, true), kDifI2cOk)

    // Write low address byte
    CHECK_ELSE_TRAP(dif_i2c_write_byte(&i2c, 0x0, kDifI2cFmtTxStop, true), kDifI2cOk)

    // Address first 24FC1025 with a read request
    CHECK_ELSE_TRAP(dif_i2c_write_byte(&i2c, 0b10100001, kDifI2cFmtStart, true), kDifI2cOk)

    // Request 4 bytes
    CHECK_ELSE_TRAP(dif_i2c_write_byte(&i2c, 4, kDifI2cFmtRx, false), kDifI2cOk)

    // Wait for reception to complete
    do
        CHECK_ELSE_TRAP(dif_i2c_get_fifo_levels(&i2c, &fmt_fifo_level, &rx_fifo_level), kDifI2cOk)
    while (rx_fifo_level < 3);

    // Read 4 bytes from the eeprom
    uint8_t buf[4];
    CHECK_ELSE_TRAP(dif_i2c_read_byte(&i2c, &buf[3]), kDifI2cOk)
    CHECK_ELSE_TRAP(dif_i2c_read_byte(&i2c, &buf[2]), kDifI2cOk)
    CHECK_ELSE_TRAP(dif_i2c_read_byte(&i2c, &buf[1]), kDifI2cOk)
    CHECK_ELSE_TRAP(dif_i2c_read_byte(&i2c, &buf[0]), kDifI2cOk)

    // Wait for sending to complete
    do
        CHECK_ELSE_TRAP(dif_i2c_get_fifo_levels(&i2c, &fmt_fifo_level, &rx_fifo_level), kDifI2cOk)
    while (fmt_fifo_level != 0);

    return (*((unsigned int *)buf) == 0xDEADBEEF);
}
