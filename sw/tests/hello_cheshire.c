// Copyright 2023 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Nicole Narr <narrn@student.ethz.ch>
// Christopher Reinwardt <creinwar@student.ethz.ch>
//
// Simple payload to test bootmodes

#include "cheshire_regs.h"
#include "printf.h"
#include "trap.h"
#include "uart.h"

extern void *__base_cheshire_regs;

char uart_initialized = 0;

void __attribute__((aligned(4))) trap_vector(void) { test_trap_vector(&uart_initialized); }

int main(void) {
    volatile uint32_t *reset_freq = (uint32_t *)(((uint64_t)&__base_cheshire_regs) + CHESHIRE_RESET_FREQ_REG_OFFSET);

    init_uart(*reset_freq, 115200);

    uart_initialized = 1;

    printf("Hello from Cheshire :)\r\n");

    return 0;
}
