// Copyright 2023 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Nicole Narr <narrn@student.ethz.ch>
// Christopher Reinwardt <creinwar@student.ethz.ch>

#ifndef I2C_FLASH_C_
#define I2C_FLASH_C_

#include "i2c_flash.h"
#include "i2c_regs.h"
#include "printf.h"
#include "sw/device/lib/dif/dif_i2c.h"
#include "util.h"
#include <stdint.h>

int i2c_flash_read_blocks_callback(void *priv, unsigned int lba, void *mem_addr, unsigned int num_blocks) {
    return i2c_flash_read_blocks((dif_i2c_t *)priv, lba, (unsigned char *)mem_addr, num_blocks);
}

int i2c_flash_read_blocks(dif_i2c_t *i2c, unsigned int lba, unsigned char *mem_addr, unsigned int num_blocks) {
    unsigned int byte_addr = 0;
    unsigned char control = 0;

    // Variables for FIFO polling
    uint8_t fmt_fifo_level = 0, rx_fifo_level = 0;

    // So you don't want data?
    if (num_blocks == 0)
        return 0;

    // This overflows our address space so no way to get to that LBA
    if (lba >= 0x100)
        return -1;

    // We don't need to transfer more than our entire contents
    if (num_blocks >= 0x100)
        return -1;

    for (int chunk = 0; chunk < num_blocks * 8; chunk++) {
        byte_addr = lba * 512 + chunk * 64;
        control = 0xA0;

        if (byte_addr > 0xFFFF) {
            control += 0x8;
        }

        // Reset address
        CHECK_ELSE_TRAP(dif_i2c_write_byte(i2c, control, kDifI2cFmtStart, true), kDifI2cOk)

        // Write high address byte
        CHECK_ELSE_TRAP(dif_i2c_write_byte(i2c, (byte_addr >> 8) & 0xFF, kDifI2cFmtTx, true), kDifI2cOk)

        // Write low address byte
        CHECK_ELSE_TRAP(dif_i2c_write_byte(i2c, byte_addr & 0xFF, kDifI2cFmtTxStop, true), kDifI2cOk)

        // Address first 24FC1025 with a read request
        CHECK_ELSE_TRAP(dif_i2c_write_byte(i2c, control | 0x1, kDifI2cFmtStart, true), kDifI2cOk)

        // Request 64 bytes
        CHECK_ELSE_TRAP(dif_i2c_write_byte(i2c, 64, kDifI2cFmtRx, false), kDifI2cOk)

        // Wait for reception to complete
        do
            CHECK_ELSE_TRAP(dif_i2c_get_fifo_levels(i2c, &fmt_fifo_level, &rx_fifo_level), kDifI2cOk)
        while (rx_fifo_level < 64);

        for (int b = 0; b < 8; b++) {
            CHECK_ELSE_TRAP(dif_i2c_read_byte(i2c, mem_addr + chunk * 64 + 8 * b), kDifI2cOk)
            CHECK_ELSE_TRAP(dif_i2c_read_byte(i2c, mem_addr + chunk * 64 + 8 * b + 1), kDifI2cOk)
            CHECK_ELSE_TRAP(dif_i2c_read_byte(i2c, mem_addr + chunk * 64 + 8 * b + 2), kDifI2cOk)
            CHECK_ELSE_TRAP(dif_i2c_read_byte(i2c, mem_addr + chunk * 64 + 8 * b + 3), kDifI2cOk)
            CHECK_ELSE_TRAP(dif_i2c_read_byte(i2c, mem_addr + chunk * 64 + 8 * b + 4), kDifI2cOk)
            CHECK_ELSE_TRAP(dif_i2c_read_byte(i2c, mem_addr + chunk * 64 + 8 * b + 5), kDifI2cOk)
            CHECK_ELSE_TRAP(dif_i2c_read_byte(i2c, mem_addr + chunk * 64 + 8 * b + 6), kDifI2cOk)
            CHECK_ELSE_TRAP(dif_i2c_read_byte(i2c, mem_addr + chunk * 64 + 8 * b + 7), kDifI2cOk)
        }
    }

    return 0;
}

#endif
