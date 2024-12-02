// Copyright 2022 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Emanuele Parisi <emanuele.parisi@unibo.it>
// Enrico Zelioli <ezelioli@iis.ee.ethz.ch>

#include "smp.h"

void smp_resume(void) {
    uint32_t num_harts = *reg32(&__base_regs, CHESHIRE_NUM_INT_HARTS_REG_OFFSET);
    // Flush cache and wake-up all sleeping cores
    fence();
    for (uint32_t i = 1; i < num_harts; i++) {
        *reg32(&__base_clint, i << 2) = 0x1;
        while (*reg32(&__base_clint, i << 2))
            ;
    }
}

// Shared variable for barrier synchronization
static volatile uint64_t _barrier_target = 0;

static void barrier_wait(volatile uint64_t *barrier, uint64_t incr, uint64_t reach) {
    asm volatile("amoadd.d x6, %1, (%0)             \n"
                 "2:                                \n"
                 "fence                             \n"
                 "ld     x6, 0(%0)                  \n"
                 "bne    x6, %2, 2b                 \n"

                 : /* output operands */
                 : /* input operands */
                 "r"(barrier), "r"(incr), "r"(reach)
                 : /* clobbered registers */
                 "x6");
}

void smp_barrier_init() {
    _barrier_target = 0;
}

void smp_barrier_up(uint64_t n_processes) {
    barrier_wait(&_barrier_target, 1, n_processes);
}

void smp_barrier_down() {
    barrier_wait(&_barrier_target, -1, 0);
}
