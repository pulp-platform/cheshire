// Copyright 2022 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Nicole Narr <narrn@student.ethz.ch>
// Christopher Reinwardt <creinwar@student.ethz.ch>

#include "opentitan_qspi.h"
#include "printf.h"
#include "sleep.h"
#include "uart.h"

char uart_initialized = 0;

extern void *__base_spim;

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

    char txbuf[5] = {0};
    char rxbuf[8] = {0};
    txbuf[0] = 0x13;

    init_uart(200000000, 115200);
    uart_initialized = 1;

    opentitan_qspi_init((volatile unsigned int *) &__base_spim, 50000000,
                        25000000, &spi);

    opentitan_qspi_probe(&spi);

    opentitan_qspi_set_speed(&spi, 1600000);

    opentitan_qspi_set_mode(&spi, 0);

    opentitan_qspi_xfer(&spi, 5*8, txbuf, NULL, SPI_XFER_BEGIN);

    opentitan_qspi_xfer(&spi, 1*8, NULL, rxbuf, 0);
    opentitan_qspi_xfer(&spi, 2*8, NULL, rxbuf+1, 0);
    opentitan_qspi_xfer(&spi, 2*8, NULL, rxbuf+3, 0);
    opentitan_qspi_xfer(&spi, 3*8, NULL, rxbuf+5, 0);

    opentitan_qspi_xfer(&spi, 0, NULL, NULL, SPI_XFER_END);

    return (*((unsigned long int *) rxbuf) != 0xb50000b0efbeadde);
}


