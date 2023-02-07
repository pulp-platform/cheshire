// Copyright 2023 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Nicole Narr <narrn@student.ethz.ch>
// Christopher Reinwardt <creinwar@student.ethz.ch>
//
// Stage 1 chainloader

#include "axi_llc_reg32.h"
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

#define DRAM 0x80000000

// Devicetree lenght in blocks
#define DT_LEN 0x8

#define SD_RETRY_COUNT 10

#define SPI_SCLK_TARGET 12500000

#define UART_BAUD 115200

extern void *__base_cheshire_regs;
extern void *__base_axi_llc;
extern void *__base_i2c;
extern void *__base_spim;
extern void *__base_spm;

unsigned char devicetree[DT_LEN*512];

void llc_info(void *base) {

    printf("[axi_llc] AXI LLC Version   :       0x%lx\r\n", axi_llc_reg32_get_version(base));
    printf("[axi_llc] Set Associativity :       %d\r\n", axi_llc_reg32_get_set_asso(base));
    printf("[axi_llc] Num Blocks        :       %d\r\n", axi_llc_reg32_get_num_blocks(base));
    printf("[axi_llc] Num Lines         :       %d\r\n", axi_llc_reg32_get_num_lines(base));
    printf("[axi_llc] BIST Outcome      :       %d\r\n", axi_llc_reg32_get_bist_out(base));
}

void idle_boot(void)
{
    void (*cheshire_entry)(void);
    volatile unsigned int *scratch0 = (unsigned int *)(((unsigned long int)&__base_cheshire_regs) + CHESHIRE_SCRATCH_0_REG_OFFSET);
    volatile unsigned int *scratch1 = (unsigned int *)(((unsigned long int)&__base_cheshire_regs) + CHESHIRE_SCRATCH_1_REG_OFFSET);

    // Reset the commit register to 0
    *scratch1 = 0;

    printf("[stage1] Polling scratch0 for entry point and scratch1 for start signal.\r\n");

    while(!*scratch1){
        (void) *scratch1;
    }

    cheshire_entry = (void (*)(void)) ((unsigned long int) *scratch0);

    asm volatile("fence.i\n" ::: "memory");

    cheshire_entry();

    return;
}

void sd_boot(unsigned int core_freq)
{
    opentitan_qspi_t spi = {0};
    unsigned int dt_lba_s = 0;
    unsigned int fw_lba_s = 0;
    unsigned int fw_lba_e = 0;
    unsigned int sd_init_tries = SD_RETRY_COUNT;
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

    if(ret){
        printf("[stage1] Could not initialize a SD card. Falling back to idle boot!\r\n");
        idle_boot();
    }

    opentitan_qspi_set_speed(&spi, SPI_SCLK_TARGET);

    // Print info of SD card
    gpt_info(sd_read_blocks_callback, &spi);

    // Get the start LBA of the second partition (devicetree)
    gpt_find_partition(sd_read_blocks_callback, &spi, 1, &dt_lba_s, NULL);

    // Copy devicetree to SPM
    sd_read_blocks(&spi, dt_lba_s, devicetree, DT_LEN);

    // Get the start LBA of the third partition (firmware)
    gpt_find_partition(sd_read_blocks_callback, &spi, 2, &fw_lba_s, &fw_lba_e);

    // Copy firmware to DRAM
    // Length in blocks = end_lba - start_lba + 1
    // as end_lba is inclusive
    sd_read_blocks(&spi, fw_lba_s, (unsigned char *) DRAM, fw_lba_e - fw_lba_s + 1);

    void (*cheshire_entry)(unsigned long int, unsigned long int, unsigned long int) =
        (void (*)(unsigned long int, unsigned long int, unsigned long int))DRAM;

    asm volatile("fence.i\n" ::: "memory");

    cheshire_entry(0, (unsigned long int)devicetree, 0);

    return;
}

void spi_flash_boot(unsigned int core_freq)
{
    opentitan_qspi_t spi = {0};
    unsigned int dt_lba_s = 0;
    unsigned int fw_lba_s = 0;
    unsigned int fw_lba_e = 0;
    // Setup the SPI Host
    opentitan_qspi_init((volatile unsigned int *)&__base_spim, core_freq, core_freq / 2, 1, &spi);

    opentitan_qspi_probe(&spi);

    // Use 25 MHz by default
    opentitan_qspi_set_speed(&spi, 25000000);

    opentitan_qspi_set_mode(&spi, 0);

    // Print info of SPI flash
    gpt_info(spi_flash_read_blocks_callback, &spi);

    // Get the start LBA of the second partition (devicetree)
    gpt_find_partition(spi_flash_read_blocks_callback, &spi, 1, &dt_lba_s, NULL);

    // Copy devicetree to SPM
    spi_flash_read_blocks(&spi, dt_lba_s, devicetree, DT_LEN);

    // Get the start LBA of the third partition (firmware)
    gpt_find_partition(spi_flash_read_blocks_callback, &spi, 2, &fw_lba_s, &fw_lba_e);

    // Copy firmware to DRAM
    spi_flash_read_blocks(&spi, fw_lba_s, (unsigned char *) DRAM, fw_lba_e - fw_lba_s + 1);

    void (*cheshire_entry)(unsigned long int, unsigned long int, unsigned long int) =
        (void (*)(unsigned long int, unsigned long int, unsigned long int))DRAM;

    asm volatile("fence.i\n" ::: "memory");

    cheshire_entry(0, (unsigned long int)devicetree, 0);

    return;
}

void i2c_flash_boot(unsigned int core_freq)
{
    unsigned int dt_lba_s = 0;
    unsigned int fw_lba_s = 0;
    unsigned int fw_lba_e = 0;
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

    // Print info of I2C flash
    gpt_info(i2c_flash_read_blocks_callback, &i2c);

    // Get the start LBA of the second partition (devicetree)
    gpt_find_partition(i2c_flash_read_blocks_callback, &i2c, 1, &dt_lba_s, NULL);

    // Copy devicetree to SPM
    i2c_flash_read_blocks(&i2c, dt_lba_s, devicetree, DT_LEN);

    // Get the start LBA of the third partition (firmware)
    gpt_find_partition(i2c_flash_read_blocks_callback, &i2c, 2, &fw_lba_s, &fw_lba_e);

    // Copy firmware to DRAM
    i2c_flash_read_blocks(&i2c, fw_lba_s, (unsigned char *) DRAM, fw_lba_e - fw_lba_s + 1);

    void (*cheshire_entry)(unsigned long int, unsigned long int, unsigned long int) =
        (void (*)(unsigned long int, unsigned long int, unsigned long int))DRAM;

    asm volatile("fence.i\n" ::: "memory");

    cheshire_entry(0, (unsigned long int)devicetree, 0);

    return;
}

int main(void) {
    volatile uint32_t *bootmode = (uint32_t *)(((uint64_t)&__base_cheshire_regs) + CHESHIRE_BOOT_MODE_REG_OFFSET);
    volatile uint32_t *reset_freq = (uint32_t *)(((uint64_t)&__base_cheshire_regs) + CHESHIRE_RESET_FREQ_REG_OFFSET);

    // Initiate our window to the world around us
    init_uart(*reset_freq, UART_BAUD);

    // Dump LLC config
    llc_info(&__base_axi_llc);

    // Decide what to do
    switch (*bootmode) {
    // Normal boot over SD Card
        case 0:
            printf("[stage1] Idle boot.\r\n");
            idle_boot();
            break; // We will never reach this

        case 1:
            printf_("[stage1] SD Card boot (CS 0).\r\n");
            sd_boot(*reset_freq);
            break;

        case 2:
            printf_("[stage1] SPI flash boot (CS 1).\r\n");
            spi_flash_boot(*reset_freq);
            break;

        case 3:
            printf_("[stage1] I2C flash boot.\r\n");
            i2c_flash_boot(*reset_freq);
            break;

        default:
            printf_("[stage1] Unknown bootmode %d\r\n", *bootmode);
            idle_boot();
            break;
    }

    while (1) {
        asm volatile("wfi\n" :::);
    }
}
