// Copyright 2022 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Nicole Narr <narrn@student.ethz.ch>
// Christopher Reinwardt <creinwar@student.ethz.ch>

#include "opentitan_qspi.h"
#include "printf.h"
#include "sd.h"
#include "sleep.h"
#include "trap.h"
#include "uart.h"

#define BENCH_LBA 0x800
#define BENCH_LEN 0x1800

// clang-format off
unsigned int speeds[] = {
      100000,
      200000,
      300000,
      400000,
     1000000,
     2000000,
     5000000,
    10000000,
    12500000,
    25000000
};
// clang-format on

/*unsigned int speeds[] = {
    25000000,
    12500000,
    10000000,
     5000000,
     2000000,
     1000000,
      400000
};*/

char uart_initialized = 0;

extern void *__base_spim;

void __attribute__((aligned(4))) trap_vector(void) { test_trap_vector(&uart_initialized); }

int main(void) {
    opentitan_qspi_t spi;
    unsigned long int *dram = (unsigned long *)0x80000000;
    int ret = 0;

    init_uart(50000000, 115200);
    uart_initialized = 1;

    // Setup the SPI Host
    opentitan_qspi_init((volatile unsigned int *)&__base_spim, 50000000, 25000000, &spi);

    opentitan_qspi_probe(&spi);

    opentitan_qspi_set_speed(&spi, 200000);

    opentitan_qspi_set_mode(&spi, 0);

    // Initialize the SD Card
    do {
        ret = sd_init(&spi);
    } while (ret);

    // Iterate over different speeds
    for (int i = 0; i < (sizeof(speeds) / sizeof(unsigned int)); i++) {
        unsigned long int mismatches = 0;

        printf("--- Zeroing the memory region ---\r\n");
        for (int x = 0; x < BENCH_LEN * 512 / 8; x++) {
            dram[x] = 0L;
        }

        printf("--- Testing %d Hz ---\r\n", speeds[i]);
        opentitan_qspi_set_speed(&spi, speeds[i]);

        // for(int b = 0; b < BENCH_LEN; b++){
        //  ret = sd_copy_blocks(&spi, BENCH_LBA + b, (unsigned char *) (0x80000000 + b*512), 1);
        //}

        // Copy check pattern to DRAM
        ret = sd_copy_blocks(&spi, BENCH_LBA, (unsigned char *)0x80000000, BENCH_LEN);

        printf("----- Check pattern copied with return value %d. Verifying... -----\r\n", ret);

        for (int j = 0; j < BENCH_LEN * 512 / 8; j++) {
            unsigned long int expected = ((4 * j) & 0xFFFFL) | (((4 * j + 1) & 0xFFFFL) << 16) |
                                         (((4 * j + 2) & 0xFFFFL) << 32) | (((4 * j + 3) & 0xFFFFL) << 48);

            if (expected != dram[j]) {
                printf("!!! Mismatch @ 0x%x: Expected: 0x%lx <-> Actual: 0x%lx !!!\r\n", (unsigned long int)&dram[j],
                       expected, dram[j]);
                mismatches++;
            }
        }

        printf("----- %d Hz: %ld mismatches -----\r\n\n\n", speeds[i], mismatches);
    }

    return 0;
}
