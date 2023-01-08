// Copyright 2022 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Nicole Narr <narrn@student.ethz.ch>
// Christopher Reinwardt <creinwar@student.ethz.ch>

#include "cheshire_regs.h"
#include "opentitan_qspi.h"
#include "printf.h"
#include "sd.h"
#include "uart.h"
#include "gpt.h"
#include "axi_llc_reg32.h"

#define DRAM 0x80000000

#define DT_LEN 0x8
#define FW_LEN 0x1800

#define SPI_SCLK_TARGET 12500000

#define UART_BAUD 115200

extern void *__base_cheshire_regs;
extern void *__base_axi_llc;
extern void *__base_spim;
extern void *__base_spm;

void llc_info(void *base)
{
    printf("[axi_llc] AXI LLC Version   :       0x%lx\r\n", axi_llc_reg32_get_version(base));
    printf("[axi_llc] Set Associativity :       %d\r\n", axi_llc_reg32_get_set_asso(base));
    printf("[axi_llc] Num Blocks        :       %d\r\n", axi_llc_reg32_get_num_blocks(base));
    printf("[axi_llc] Num Lines         :       %d\r\n", axi_llc_reg32_get_num_lines(base));
    printf("[axi_llc] BIST Outcome      :       %d\r\n", axi_llc_reg32_get_bist_out(base));
}

void sd_boot(unsigned int core_freq)
{
    opentitan_qspi_t spi;
    unsigned int dt_lba = 0, fw_lba = 0;
    int ret = 0;

    // Setup the SPI Host
    opentitan_qspi_init((volatile unsigned int *) &__base_spim, core_freq,
                        core_freq/2, &spi);

    opentitan_qspi_probe(&spi);

    // Init at 400 kHz
    opentitan_qspi_set_speed(&spi, 400000);

    opentitan_qspi_set_mode(&spi, 0);

    // Initialize the SD Card
    do {
        ret = sd_init(&spi);
    } while (ret);

    opentitan_qspi_set_speed(&spi, SPI_SCLK_TARGET);

    // Print info of SD Card
    gpt_info(&spi);

    // Get the start LBAs of the first two partitions (DT and firmware)
    gpt_find_partition(&spi, 0, &dt_lba);
    gpt_find_partition(&spi, 1, &fw_lba);
    
    // Copy Device Tree to SPM
    sd_copy_blocks(&spi, dt_lba, (unsigned char *) &__base_spm, DT_LEN);

    printf("Copied device tree to 0x%lx\r\n", (unsigned long int) &__base_spm);

    // Copy firmware to DRAM
    sd_copy_blocks(&spi, fw_lba, (unsigned char *) DRAM, FW_LEN);

    printf("Copied firmware to 0x%lx\r\n", (unsigned long int) DRAM);

    void (*cheshire_entry)(unsigned long int,unsigned long int,unsigned long int) =
                          (void (*)(unsigned long int,unsigned long int,unsigned long int)) DRAM;
    
    asm volatile("fence.i\n" ::: "memory");

    cheshire_entry(0, (unsigned long int) &__base_spm, 0);

    return;
}

int main(void)
{
    volatile uint32_t *bootmode   = (uint32_t *) (((uint64_t)&__base_cheshire_regs) + CHESHIRE_REGISTER_FILE_BOOT_MODE_REG_OFFSET);
    volatile uint32_t *reset_freq = (uint32_t *) (((uint64_t)&__base_cheshire_regs) + CHESHIRE_REGISTER_FILE_RESET_FREQ_REG_OFFSET);

    // Initiate our window to the world around us
    init_uart(*reset_freq, UART_BAUD);

    // Print AXI LLC status
    llc_info((void *) &__base_axi_llc);

    // Decide what to do
    switch(*bootmode){
        // Normal boot over SD Card
        case 0: printf_("Bootmode 0: Booting from SD Card\r\n");
                sd_boot(*reset_freq);
                break; // We will never reach this

        case 1: printf_("Bootmode 1: Doing nothing :)\r\n");
                break;

        case 2: printf_("Bootmode 2: Doing nothing :)\r\n");
                break;

        case 3: printf_("Bootmode 3: Doing nothing :)\r\n");
                break;

        default:    printf_("Bootmode %d: Doing nothing :)\r\n", *bootmode);
                    break;
    }

    while(1){
        asm volatile("wfi\n" :::);
    }

}
