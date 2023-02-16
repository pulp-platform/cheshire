// Copyright 2022 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Alessandro Ottaviano <aottaviano@iis.ee.ethz.ch>

#include "cheshire_regs.h"
#include "printf.h"
#include "trap.h"
#include "uart.h"

char uart_initialized = 0;

extern void *__base_cheshire_regs;

void __attribute__((aligned(4))) trap_vector(void) { test_trap_vector(&uart_initialized); }

int main(void) {
    init_uart(200000000, 115200);
    // init_uart(50000000, 115200);

    uart_initialized = 1;

    printf_("Test printf\n");

    volatile uint32_t *bootmode = (uint32_t *)(((uint64_t)&__base_cheshire_regs) + CHESHIRE_BOOT_MODE_REG_OFFSET);
    printf_("Using bootmode: %d\r\n", *bootmode);

    return 0;
}
