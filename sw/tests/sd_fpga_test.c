// Copyright 2022 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Nicole Narr <narrn@student.ethz.ch>
// Christopher Reinwardt <creinwar@student.ethz.ch>

#include "opentitan_qspi.h"
#include "printf.h"
#include "sd.h"
#include "gpt.h"
#include "sleep.h"
#include "uart.h"

#define DT_LEN 0x8
#define FW_LEN 0x1800

#define SD_SPEED 25000000

char uart_initialized = 0;

void __attribute__((aligned(4))) trap_vector(void)
{
    long int mcause = 0, mepc = 0, mip = 0, mie = 0, mstatus = 0, mtval = 0;

    asm volatile(
        "csrrs t0, mcause, x0\n     \
         sd t0, %0\n                \
         csrrs t0, mepc, x0\n       \
         sd t0, %1\n                \
         csrrs t0, mip, x0\n        \
         sd t0, %2\n                \
         csrrs t0, mie, x0\n        \
         sd t0, %3\n                \
         csrrs t0, mstatus, x0\n    \
         sd t0, %4\n                \
         csrrs t0, mtval, x0\n      \
         sd t0, %5\n"
         : "=m" (mcause),
           "=m" (mepc),
           "=m" (mip),
           "=m" (mie),
           "=m" (mstatus),
           "=m" (mtval)
         :: "t0");

    // Interrupt with exception code 7 == Machine Mode Timer Interrupt
    if(mcause < 0 && (mcause << 1) == 14){
        // Handle interrupt by disabling the timer interrupt and returning
        asm volatile(
            "addi t0, x0, 128\n     \
             csrrc x0, mie, t0\n"
             ::: "t0"
        );
        return;
    } else {
        if(uart_initialized){
            printf_("Hello from the trap_vector :)\r\n");
            printf_("mcause:    0x%lx\r\n", mcause);
            printf_("mepc:      0x%lx\r\n", mepc);
            printf_("mip:       0x%lx\r\n", mip);
            printf_("mie:       0x%lx\r\n", mie);
            printf_("mstatus:   0x%lx\r\n", mstatus);
            printf_("mtval:     0x%lx\r\n", mtval);
        }
    }

    while(1){
        asm volatile("wfi\n" :::);
    }

    return;
}

int main(void)
{
    opentitan_qspi_t spi;
    int ret = 0;

    int dt_lba;
    int fw_lba;

    init_uart(50000000, 115200);
    uart_initialized = 1;

    // Setup the SPI Host
    opentitan_qspi_init((volatile unsigned int *) 0x03000000, 50000000,
                        25000000, &spi);

    opentitan_qspi_probe(&spi);

    opentitan_qspi_set_speed(&spi, 400000);

    opentitan_qspi_set_mode(&spi, 0);

    // Initialize the SD Card
    do {
        ret = sd_init(&spi);
    } while (ret);

    opentitan_qspi_set_speed(&spi, SD_SPEED);

    // Print info of SD Card
    gpt_info(&spi);

    // Copy Device Tree to high SPM
    gpt_find_partition(&spi, 0, &dt_lba);
    sd_copy_blocks(&spi, dt_lba, (unsigned char *) 0x70010000, DT_LEN);

    printf("Copied DT to 0x70010000\r\n");

    // Copy firmware to DRAM
    gpt_find_partition(&spi, 1, &fw_lba);
    sd_copy_blocks(&spi, fw_lba, (unsigned char *) 0x80000000, FW_LEN);

    printf("Copied FW to 0x80000000\r\n");

    void (*entry)(int,int,int) = (void (*)(int,int,int)) 0x80000000;
    
    asm volatile("ebreak\n");
    entry(0, 0x70010000, 0);  

    return 0;
}


