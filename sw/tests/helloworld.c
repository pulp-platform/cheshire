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

extern void *__base_cheshire_regs;

char uart_initialized = 0;

void __attribute__((aligned(4))) trap_vector(void) {
    // Disable timing interrupt (should be conditionalized)
    set_mtie(0);
 }

int main(void) {
    //volatile uint32_t *reset_freq = (uint32_t *)(((uint64_t)&__base_cheshire_regs) + CHESHIRE_RESET_FREQ_REG_OFFSET);

    //uart_init(__base_uart, *reset_freq, 115200);

    // *((volatile char*)(0x02003000)) = 'b';
    // *((volatile char*)(0x02003000)) = '\n';
    // *((volatile char*)(0x02003000)) = 'c';
    // *((volatile char*)(0x02003000)) = '\n';

    while (1) {
        printf("Hello from Cheshire :)\r\n");
        clint_sleep_ticks(0, 500000);
    }

    return 0;
}
