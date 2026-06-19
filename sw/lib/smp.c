// Copyright 2022 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Emanuele Parisi <emanuele.parisi@unibo.it>
// Enrico Zelioli <ezelioli@iis.ee.ethz.ch>

#include "smp.h"

void smp_resume(void) {
    uint32_t num_harts = CHS_REGS->num_int_harts.w;
    fence();
    for (uint32_t i = 1; i < num_harts; i++) {
        *reg32(&__clint_base_addr__, i << 2) = 0x1;
        while (*reg32(&__clint_base_addr__, i << 2))
            ;
    }
}

static volatile uint64_t _barrier_target_a = 0;
static volatile uint64_t _barrier_target_b = 0;

static void barrier_wait(volatile uint64_t *barrier, uint64_t incr, uint64_t reach) {
    __atomic_fetch_add(barrier, incr, __ATOMIC_RELEASE);
    while (__atomic_load_n(barrier, __ATOMIC_RELAXED) != reach)
        ;
    __atomic_thread_fence(__ATOMIC_ACQUIRE);
}

void smp_barrier_init(void) {
    _barrier_target_a = 0;
    _barrier_target_b = 0;
}

void smp_barrier_up(uint64_t n_processes) {
    barrier_wait(&_barrier_target_a, 1, n_processes);
    barrier_wait(&_barrier_target_b, 1, n_processes);
}

void smp_barrier_down(void) {
    barrier_wait(&_barrier_target_a, -1, 0);
    barrier_wait(&_barrier_target_b, -1, 0);
}
