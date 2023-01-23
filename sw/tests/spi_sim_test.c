// Copyright 2022 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Nicole Narr <narrn@student.ethz.ch>
// Christopher Reinwardt <creinwar@student.ethz.ch>

#include "opentitan_qspi.h"
#include "printf.h"
#include "sleep.h"
#include "trap.h"
#include "uart.h"

char uart_initialized = 0;

extern void *__base_spim;

void __attribute__((aligned(4))) trap_vector(void) { test_trap_vector(&uart_initialized); }

int main(void) {
    opentitan_qspi_t spi;

    char txbuf[5] = {0};
    char rxbuf[8] = {0};
    txbuf[0] = 0x13;

    init_uart(200000000, 115200);
    uart_initialized = 1;

    opentitan_qspi_init((volatile unsigned int *)&__base_spim, 50000000, 25000000, &spi);

    opentitan_qspi_probe(&spi);

    opentitan_qspi_set_speed(&spi, 1600000);

    opentitan_qspi_set_mode(&spi, 0);

    opentitan_qspi_xfer(&spi, 5 * 8, txbuf, NULL, SPI_XFER_BEGIN);

    opentitan_qspi_xfer(&spi, 1 * 8, NULL, rxbuf, 0);
    opentitan_qspi_xfer(&spi, 2 * 8, NULL, rxbuf + 1, 0);
    opentitan_qspi_xfer(&spi, 2 * 8, NULL, rxbuf + 3, 0);
    opentitan_qspi_xfer(&spi, 3 * 8, NULL, rxbuf + 5, 0);

    opentitan_qspi_xfer(&spi, 0, NULL, NULL, SPI_XFER_END);

    return (*((unsigned long int *)rxbuf) != 0xb50000b0efbeadde);
}
