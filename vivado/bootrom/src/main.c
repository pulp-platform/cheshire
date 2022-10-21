// Copyright 2022 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Nicole Narr <narrn@student.ethz.ch>
// Christopher Reinwardt <creinwar@student.ethz.ch>

#include "cheshire_regs.h"
#include "opentitan_qspi.h"
#include "printf.h"
#include "sd.h"
#include "uart.h"

#define DT_LBA 0x800
#define DT_LEN 0x8
#define FW_LBA 0x40800
#define FW_LEN 0x1800

#define CORE_FREQ_HZ 50000000

#define SPI_SCLK_TARGET 12500000

extern uint32_t __base_cheshire_regs;

void sd_boot(void)
{
    opentitan_qspi_t spi;
    int ret = 0;

    // Setup the SPI Host
    opentitan_qspi_init((volatile unsigned int *) 0x03000000, CORE_FREQ_HZ,
                        CORE_FREQ_HZ/2, &spi);

    opentitan_qspi_probe(&spi);

    // Init at 400 kHz
    opentitan_qspi_set_speed(&spi, 400000);

    opentitan_qspi_set_mode(&spi, 0);

    // Initialize the SD Card
    do {
        ret = sd_init(&spi);
    } while (ret);

    opentitan_qspi_set_speed(&spi, SPI_SCLK_TARGET);

    // Copy Device Tree to SPM
    sd_copy_blocks(&spi, DT_LBA, (unsigned char *) 0x70000000, DT_LEN);

    printf("Copied device tree to 0x70000000\r\n");

    // Copy firmware to DRAM
    sd_copy_blocks(&spi, FW_LBA, (unsigned char *) 0x80000000, FW_LEN);

    printf("Copied firmware to 0x80000000\r\n");

    void (*entry)(int,int,int) = (void (*)(int,int,int)) 0x80000000;
    
    asm volatile("fence.i\n" ::: "memory");

    entry(0, 0x70000000, 0);  

    return;
}

int main(void)
{
    volatile uint32_t *bootmode = (uint32_t *) (((uint64_t)&__base_cheshire_regs) + CHESHIRE_REGISTER_FILE_BOOT_MODE_REG_OFFSET);

    // Initiate our window to the world around us
    init_uart(CORE_FREQ_HZ, 115200);

    // Decide what to do
    switch(*bootmode){
        // Normal boot over SD Card
        case 0: printf_("Booting from SD Card\r\n");
                sd_boot();
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
