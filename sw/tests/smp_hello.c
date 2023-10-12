// Copyright 2023 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Nicole Narr <narrn@student.ethz.ch>
// Christopher Reinwardt <creinwar@student.ethz.ch>
// Emanuele Parisi <emanuele.parisi@unibo.it>
//
// Simple SMP Hello World.

#include "regs/cheshire.h"
#include "dif/clint.h"
#include "dif/uart.h"
#include "params.h"
#include "util.h"
#include "smp.h"
#include "printf.h"

uint32_t __attribute__((section(".data"))) semaphore = 0x0;

void semaphore_wait() {
    asm volatile (
        "   li t0, 1                    \n"
        "1:                             \n"
        "   amoswap.w.aq t0, t0, (%0)   \n"
        "   bnez t0, 1b                 \n"
        ::"r"(&semaphore)
    );
}

void semaphore_post() {
    asm volatile (
        "   amoswap.w.rl zero, zero, (%0)   \n"
        ::"r"(&semaphore)
    );
}

int main(void) {
    uint32_t rtc_freq = *reg32(&__base_regs, CHESHIRE_RTC_FREQ_REG_OFFSET);
    uint64_t reset_freq = clint_get_core_freq(rtc_freq, 2500);
    uart_init(&__base_uart, reset_freq, __BAUDRATE);

    smp_resume();

    for (uint64_t i=0; i<10; i++) {
        semaphore_wait();
        printf("Hello World! - (%d, %d)\r\n", get_mhartid(), i);
        semaphore_post();
    }

    return 0;
}
