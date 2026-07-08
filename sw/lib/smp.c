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

static volatile uint64_t _barrier_target = 0;

/*
With hardware coherence the cleaner implementation would be:

static void barrier_wait(volatile uint64_t *barrier, uint64_t incr, uint64_t reach) {
    __atomic_fetch_add(barrier, incr, __ATOMIC_SEQ_CST);
    while (__atomic_load_n(barrier, __ATOMIC_ACQUIRE) != reach)
        ;
}

We have to force an AMO instruction to load the value since the vanilla HPDCache
ensures coherence on such instructions. NOTE: this is implementation dependent!
*/

static void barrier_wait(volatile uint64_t *barrier, uint64_t incr, uint64_t reach) {
    __atomic_fetch_add(barrier, incr, __ATOMIC_SEQ_CST);

    while (__atomic_fetch_add(barrier, 0, __ATOMIC_ACQUIRE) != reach)
        ;
}

void smp_barrier_init(void) {
    _barrier_target = 0;
}

void smp_barrier_up(uint64_t n_processes) {
    barrier_wait(&_barrier_target, 1, n_processes);
}

void smp_barrier_down(void) {
    barrier_wait(&_barrier_target, -1, 0);
}
