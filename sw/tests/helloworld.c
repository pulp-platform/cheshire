// Copyright 2023 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Nicole Narr <narrn@student.ethz.ch>
// Christopher Reinwardt <creinwar@student.ethz.ch>
//
// Simple payload to test bootmodes

#include "printf.h"
#include "dif/uart.h"
#include "regs/cheshire.h"
#include "params.h"
#include "util.h"
#include "dif/clint.h"

#include "hal/spi_sdcard.h"



int main(void) {

    uint64_t reset_freq = 50*1000*1000;

    uart_init(&__base_uart, reset_freq, 115200);

    //printf("Test printf\r\n");

    printf("Testing...\r\n");

    // Initialize device handle
    spi_sdcard_t device = {
        .spi_freq = 25*1000*1000,  // 25 MHz: full steam ahead!
        .csid = 0,
        .csid_dummy = 1
    };
    CHECK_CALL(spi_sdcard_init(&device, reset_freq))

    printf("Oh yeah yeah!\r\n");


    // NEW BELOW
    uint64_t tgt_base = 0x201;
    uint64_t tgt_len = 12344;
    char tgt[tgt_len+1];
    tgt[tgt_len] = '\0';

    CHECK_CALL(spi_sdcard_read_checkcrc(&device, tgt, tgt_base, tgt_len))

    printf("===================\r\n");
    for (int i = 0; i < tgt_len; i+=8)
        printf("%8x: %02x %02x %02x %02x %02x %02x %02x %02x\r\n", i+tgt_base, tgt[i], tgt[i+1], tgt[i+2], tgt[i+3], tgt[i+4], tgt[i+5], tgt[i+6], tgt[i+7]);
    printf("===================\r\n");

    return 0;
}
