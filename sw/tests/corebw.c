// Copyright 2023 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Nicole Narr <narrn@student.ethz.ch>
// Christopher Reinwardt <creinwar@student.ethz.ch>
//
// Simple payload to test bootmodes

#include "regs/cheshire.h"
#include "dif/clint.h"
#include "dif/uart.h"
#include "params.h"
#include "util.h"
#include "printf.h"


#define BLOCK_SIZE 0x2000

int main(void) {

    volatile uint64_t buf [BLOCK_SIZE];

    uint32_t rtc_freq = *reg32(&__base_regs, CHESHIRE_RTC_FREQ_REG_OFFSET);
    uint64_t reset_freq = clint_get_core_freq(rtc_freq, 2500);
    uart_init(&__base_uart, reset_freq, __BOOT_BAUDRATE);

    fence();

    uint64_t start = get_mcycle();

    for (int k = 0; k < BLOCK_SIZE; k += 16) {
        asm volatile (
            "sd zero,  0(%[o])  \n"
            "sd zero,  8(%[o])  \n"
            "sd zero, 16(%[o])  \n"
            "sd zero, 24(%[o])  \n"
            "sd zero, 32(%[o])  \n"
            "sd zero, 40(%[o])  \n"
            "sd zero, 48(%[o])  \n"
            "sd zero, 56(%[o])  \n"
            "sd zero, 64(%[o])  \n"
            "sd zero, 72(%[o])  \n"
            "sd zero, 80(%[o])  \n"
            "sd zero, 88(%[o])  \n"
            "sd zero, 96(%[o])  \n"
            "sd zero,104(%[o])  \n"
            "sd zero,112(%[o])  \n"
            "sd zero,120(%[o])  \n"
            :: [o]"r"(&buf[k]) : "memory"
        );
    }

    uint64_t cycles = get_mcycle() - start;

    uint64_t rel_tp_perc_w = (100 * BLOCK_SIZE) / cycles;

    start = get_mcycle();

    for (int k = 0; k < BLOCK_SIZE; k += 16) {
        asm volatile (
            "ld x10,  0(%[i])   \n"
            "ld x11,  8(%[i])   \n"
            "ld x12, 16(%[i])   \n"
            "ld x13, 24(%[i])   \n"
            "ld x14, 32(%[i])   \n"
            "ld x15, 40(%[i])   \n"
            "ld x16, 48(%[i])   \n"
            "ld x17, 56(%[i])   \n"
            "ld x18, 64(%[i])   \n"
            "ld x19, 72(%[i])   \n"
            "ld x20, 80(%[i])   \n"
            "ld x21, 88(%[i])   \n"
            "ld x22, 96(%[i])   \n"
            "ld x23,104(%[i])   \n"
            "ld x24,112(%[i])   \n"
            "ld x25,120(%[i])   \n"
            :: [i]"r"(&buf[k]) :
            "x10", "x11", "x12", "x13", "x14", "x15", "x16", "x17",
            "x18", "x19", "x20", "x21", "x22", "x23", "x24", "x25",
            "memory"
        );
    }

    cycles = get_mcycle() - start;

    uint64_t rel_tp_perc_r = (100 * BLOCK_SIZE) / cycles;

    printf("WTP: %d%%, RTP: %d%%\r\n", rel_tp_perc_w, rel_tp_perc_r);

    uart_write_flush(&__base_uart);

    return 0;
}
