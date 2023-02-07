// Copyright 2022 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Nicole Narr <narrn@student.ethz.ch>
// Christopher Reinwardt <creinwar@student.ethz.ch>

#include "opentitan_qspi.h"
#include "printf.h"
#include "sd.h"
#include "trap.h"
#include "uart.h"

#define TEST_LEN 0x8

#define SD_SPEED 25000000
//#define SD_SPEED 400000

char uart_initialized = 0;

extern void *__base_spim;

void __attribute__((aligned(4))) trap_vector(void) { test_trap_vector(&uart_initialized); }

int main(void) {
    opentitan_qspi_t spi;
    int ret = 0;

    init_uart(200000000, 115200);
    uart_initialized = 1;

    // Setup the SPI Host
    opentitan_qspi_init((volatile unsigned int *)&__base_spim, 200000000, 25000000, 0, &spi);

    opentitan_qspi_probe(&spi);

    opentitan_qspi_set_speed(&spi, 400000);

    opentitan_qspi_set_mode(&spi, 0);

    // Initialize the SD Card
    do {
        ret = sd_init(&spi);
    } while (ret);

    opentitan_qspi_set_speed(&spi, SD_SPEED);

    return sd_write_blocks(&spi, 0, (unsigned char *) 0x01000000, TEST_LEN);
}
