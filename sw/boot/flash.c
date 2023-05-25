// Copyright 2023 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Paul Scheffler <paulsc@iis.ee.ethz.ch>
//
// Boot disk flasher for Cheshire; writes a contiguous disk segment to a boot target disk.
// This program can be preloaded and invoked repeatedly to write multiple segments.

#include <stdint.h>
#include "util.h"
#include "params.h"
#include "regs/cheshire.h"
#include "spi_host_regs.h"
#include "dif/clint.h"
#include "hal/i2c_24fc1025.h"
#include "hal/spi_s25fs512s.h"
#include "hal/spi_sdcard.h"
#include "hal/uart_debug.h"
#include "gpt.h"
#include "printf.h"

int flash_spi_sdcard(uint64_t core_freq, uint64_t rtc_freq, void *img_base, uint64_t sector,
                     uint64_t len) {
    // Initialize device handle
    spi_sdcard_t device = {
        .spi_freq = 24 * 1000 * 1000, // 24MHz (maximum is 25MHz)
        .csid = 0,
        .csid_dummy = SPI_HOST_PARAM_NUM_C_S - 1 // Last physical CS is designated dummy
    };
    CHECK_CALL(spi_sdcard_init(&device, core_freq))
    // Wait for device to be initialized (1ms, round up extra tick to be sure)
    clint_spin_until((1000 * rtc_freq) / (1000 * 1000) + 1);
    // Write sectors: we have 512 512B blocks per 256KiB sector, so a 9b left shift
    return spi_sdcard_write_blocks(&device, img_base, sector << 9, len << 9, 1);
}

int flash_spi_s25fs512s(uint64_t core_freq, uint64_t rtc_freq, void *img_base, uint64_t sector,
                        uint64_t len) {
    // Initialize device handle
    spi_s25fs512s_t device = {
        .spi_freq = MIN(40 * 1000 * 1000, core_freq / 4), // Up to quarter core freq or 40MHz
        .csid = 1};
    CHECK_CALL(spi_s25fs512s_init(&device, core_freq))
    // Wait for device to be initialized (t_PU = 300us, round up extra tick to be sure)
    clint_spin_until((350 * rtc_freq) / (1000 * 1000) + 1);
    // Write sectors of 256 KiB directly
    return spi_s25fs512s_single_flash(&device, img_base, sector, len);
}

int flash_i2c_24fc1025(uint64_t core_freq, void *img_base) {
    // Initialize device handle
    dif_i2c_t i2c;
    CHECK_CALL(i2c_24fc1025_init(&i2c, core_freq))
    // Write half of a single 256 KiB sector (entire capacity)
    return i2c_24fc1025_write(&i2c, img_base, 0, 128 * 1024);
}

int main() {
    int ret;
    // Read reference frequency and compute core frequency
    uint32_t rtc_freq = *reg32(&__base_regs, CHESHIRE_RTC_FREQ_REG_OFFSET);
    uint64_t core_freq = clint_get_core_freq(rtc_freq, 2500);
    // Get arguments from scratch registers
    volatile uint32_t *scratch = reg32(&__base_regs, CHESHIRE_SCRATCH_0_REG_OFFSET);
    uint64_t target = scratch[0];
    void *img_base = (void *)(uintptr_t)scratch[1];
    uint64_t sector = scratch[2];
    uint64_t len = scratch[3];
    // Flash chosen disk
    printf("[FLASH] Write buffer at 0x%x of length %d to target %d, sector %d ... ", img_base, len,
           target, sector);
    switch (target) {
    case 1: {
        ret = flash_spi_sdcard(core_freq, rtc_freq, img_base, sector, len);
        break;
    }
    case 2: {
        ret = flash_spi_s25fs512s(core_freq, rtc_freq, img_base, sector, len);
        break;
    }
    case 3: {
        ret = flash_i2c_24fc1025(core_freq, img_base);
        break;
    }
    default: {
        ret = -1;
        break;
    }
    }
    if (ret)
        printf("ERROR (%d)\r\n", ret);
    else
        printf("OK\r\n");
    return ret;
}
