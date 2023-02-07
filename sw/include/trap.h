// Copyright 2021 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Nicole Narr <narrn@student.ethz.ch>
// Christopher Reinwardt <creinwar@student.ethz.ch>

#pragma once

#include "printf.h"

inline static void test_trap_vector(char *uart_initialized) {
    long int mcause = 0, mepc = 0, mip = 0, mie = 0, mstatus = 0, mtval = 0;

    // clang format-off
    asm volatile("csrrs t0, mcause, x0\n     \
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
                 : "=m"(mcause), "=m"(mepc), "=m"(mip), "=m"(mie), "=m"(mstatus), "=m"(mtval)::"t0");

    // Interrupt with exception code 7 == Machine Mode Timer Interrupt
    if (mcause < 0 && (mcause << 1) == 14) {
        // Handle interrupt by disabling the timer interrupt and returning
        asm volatile("addi t0, x0, 128\n     \
             csrrc x0, mie, t0\n" ::
                         : "t0");
        return;
    } else {
        if (*uart_initialized) {
            printf("Hello from the trap_vector :)\r\n");
            printf("mcause:    0x%lx\r\n", mcause);
            printf("mepc:      0x%lx\r\n", mepc);
            printf("mip:       0x%lx\r\n", mip);
            printf("mie:       0x%lx\r\n", mie);
            printf("mstatus:   0x%lx\r\n", mstatus);
            printf("mtval:     0x%lx\r\n", mtval);
        }
    }

    while (1) {
        asm volatile("wfi\n" :::);
    }

    return;
}
