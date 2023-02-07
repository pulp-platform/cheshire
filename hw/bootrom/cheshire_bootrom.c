// Copyright 2022 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Nicole Narr <narrn@student.ethz.ch>
// Christopher Reinwardt <creinwar@student.ethz.ch>

#include "cheshire_regs.h"
#include "gpt.h"
#include "i2c_flash.h"
#include "opentitan_qspi.h"
#include "printf.h"
#include "sd.h"
#include "spi_flash.h"
#include "uart.h"
#include "util.h"

#include "sw/device/lib/base/mmio.h"
#include "sw/device/lib/dif/dif_i2c.h"

#include <stdint.h>

#define SPI_SCLK_TARGET 12500000

#define UART_BAUD 115200

#define SD_RETRY_COUNT 10

// Length of stage1 partition to load (in bytes)
#define STAGE1_LEN 16384

extern void *__base_cheshire_regs;
extern void *__base_i2c;
extern void *__base_spim;
extern void *__base_spm;

void idle_boot(void) {
    void (*cheshire_entry)(void);
    volatile unsigned int *scratch0 =
        (unsigned int *)(((unsigned long int)&__base_cheshire_regs) + CHESHIRE_SCRATCH_0_REG_OFFSET);
    volatile unsigned int *scratch1 =
        (unsigned int *)(((unsigned long int)&__base_cheshire_regs) + CHESHIRE_SCRATCH_1_REG_OFFSET);

    printf("[bootrom] Polling scratch0 for entry point and scratch1 for start signal.\r\n");

    // Reset the commit register to 0
    *scratch1 = 0;

    while (!*scratch1) {
        (void)*scratch1;
    }

    cheshire_entry = (void (*)(void))((unsigned long int)*scratch0);

    asm volatile("fence.i\n" ::: "memory");

    cheshire_entry();

    return;
}

void sd_boot(unsigned int core_freq) {
    opentitan_qspi_t spi = {0};
    unsigned int stage1_lba = 0, sd_init_tries = SD_RETRY_COUNT;
    int ret = 0;

    // Setup the SPI Host
    opentitan_qspi_init((volatile unsigned int *)&__base_spim, core_freq, core_freq / 2, 0, &spi);

    opentitan_qspi_probe(&spi);

    // Init at 400 kHz
    opentitan_qspi_set_speed(&spi, 400000);

    opentitan_qspi_set_mode(&spi, 0);

    // Initialize the SD Card
    do {
        ret = sd_init(&spi);
        sd_init_tries--;
    } while (ret && sd_init_tries > 0);

    if (ret) {
        printf("[bootrom] Could not initialize a SD card. Falling back to idle boot!\r\n");
        idle_boot();
    }

    opentitan_qspi_set_speed(&spi, SPI_SCLK_TARGET);

    // Get the start LBA of the first partition (stage1 loader)
    gpt_find_partition(sd_read_blocks_callback, &spi, 0, &stage1_lba, NULL);

    // Copy stage1 to SPM
    sd_read_blocks(&spi, stage1_lba, (unsigned char *)&__base_spm, STAGE1_LEN / 512);

    void (*cheshire_entry)(void) = (void (*)(void)) & __base_spm;

    asm volatile("fence.i\n" ::: "memory");

    cheshire_entry();

    return;
}

void spi_flash_boot(unsigned int core_freq) {
    opentitan_qspi_t spi = {0};
    unsigned int stage1_lba = 0;

    // Setup the SPI Host
    opentitan_qspi_init((volatile unsigned int *)&__base_spim, core_freq, core_freq / 2, 1, &spi);

    opentitan_qspi_probe(&spi);

    // Use 25 MHz by default
    opentitan_qspi_set_speed(&spi, 25000000);

    opentitan_qspi_set_mode(&spi, 0);

    // Get the start LBA of the first partition (stage1 loader)
    gpt_find_partition(spi_flash_read_blocks_callback, &spi, 0, &stage1_lba, NULL);

    // Copy stage1 to SPM
    spi_flash_read_blocks(&spi, stage1_lba, (unsigned char *)&__base_spm, STAGE1_LEN / 512);

    void (*cheshire_entry)(void) = (void (*)(void)) & __base_spm;

    asm volatile("fence.i\n" ::: "memory");

    cheshire_entry();
}

void i2c_flash_boot(unsigned int core_freq) {
    unsigned int stage1_lba = 0;
    dif_i2c_config_t config = {0};
    dif_i2c_t i2c = {0};

    // Obtain handle to I2C
    mmio_region_t i2c_base = (mmio_region_t){.base = (void *)&__base_i2c};
    dif_i2c_params_t i2c_params = {.base_addr = i2c_base};

    // Configure I2C: worst case 24xx1025 @1.7V
    const unsigned int per_periph_ns = 1000 * 1000 * 1000 / core_freq;
    const dif_i2c_timing_config_t timing_config = {
        .clock_period_nanos = per_periph_ns,            // System-side periph clock
        .lowest_target_device_speed = kDifI2cSpeedFast, // Fast mode: max 400 kBaud
        .scl_period_nanos = 1000000 / 333,              // Slower to meet t_sda_rise
        .sda_fall_nanos = 300,                          // See 24xx1025 datasheet
        .sda_rise_nanos = 1000                          // See 24xx1025 datasheet
    };

    CHECK_ELSE_TRAP(dif_i2c_init(i2c_params, &i2c), kDifI2cOk)

    CHECK_ELSE_TRAP(dif_i2c_compute_timing(timing_config, &config), kDifI2cOk)

    CHECK_ELSE_TRAP(dif_i2c_configure(&i2c, config), kDifI2cOk)

    // Enable host functionality
    // We do *not* set up any interrupts; traps of any kind should be fatal
    CHECK_ELSE_TRAP(dif_i2c_host_set_enabled(&i2c, kDifI2cToggleEnabled), kDifI2cOk)

    // Get the start LBA of the first partition (stage1 loader)
    gpt_find_partition(i2c_flash_read_blocks_callback, &i2c, 0, &stage1_lba, NULL);

    // Copy stage1 to SPM
    i2c_flash_read_blocks(&i2c, stage1_lba, (unsigned char *)&__base_spm, STAGE1_LEN / 512);

    void (*cheshire_entry)(void) = (void (*)(void)) & __base_spm;

    asm volatile("fence.i\n" ::: "memory");

    cheshire_entry();
}

int main(void) {
    volatile unsigned int *bootmode =
        (volatile unsigned int *)(((unsigned long int)&__base_cheshire_regs) + CHESHIRE_BOOT_MODE_REG_OFFSET);
    volatile unsigned int *reset_freq =
        (volatile unsigned int *)(((unsigned long int)&__base_cheshire_regs) + CHESHIRE_RESET_FREQ_REG_OFFSET);

    // Initiate our window to the world around us
    init_uart(*reset_freq, UART_BAUD);

    // Decide what to do
    switch (*bootmode) {
    case 0:
        printf("[bootrom] Bootmode 0: Idle boot.\r\n");
        idle_boot();
        break;

    case 1:
        printf("[bootrom] Bootmode 1: SD card boot (CS 0)\r\n");
        sd_boot(*reset_freq);
        break;

    case 2:
        printf("[bootrom] Bootmode 2: SPI flash boot (CS 1)\r\n");
        spi_flash_boot(*reset_freq);
        break;

    case 3:
        printf("[bootrom] Bootmode 3: I2C flash boot (addr: 0b1010000)\r\n");
        i2c_flash_boot(*reset_freq);
        break;

    default:
        printf("[bootrom] Bootmode %d: Unknown bootmode. Using idle boot.\r\n", *bootmode);
        idle_boot();
        break;
    }

    while (1) {
        asm volatile("wfi\n" :::);
    }
}
