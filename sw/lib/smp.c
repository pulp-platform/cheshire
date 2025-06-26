// Copyright 2022 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Emanuele Parisi <emanuele.parisi@unibo.it>
// Enrico Zelioli <ezelioli@iis.ee.ethz.ch>
// Paul Scheffler <paulsc@iis.ee.ethz.ch>

#include "smp.h"

#include "util.h"
#include "regs/cheshire.h"
#include "params.h"

// Unpark specified harts and send them to a given destination.
// Note that these harts are *not* set up and `dst` should set them up accordingly.
// This is a runtime function and should not be used in general BMPs.
void _smp_unpark(void* dst) {
    // Only hart 0 should unpark harts
    if (get_mhartid()) return;
    // Set destination address.
    *reg32(&__base_regs, CHESHIRE_SCRATCH_5_REG_OFFSET) = (uintptr_t)(dst) >> 32;
    *reg32(&__base_regs, CHESHIRE_SCRATCH_4_REG_OFFSET) = (uintptr_t)(dst);
    // Set SMP resume enable
    *reg32(&__base_regs, CHESHIRE_SCRATCH_6_REG_OFFSET) = 1;
    // Wake up harts
    uint32_t num_int_harts = *reg32(&__base_regs, CHESHIRE_NUM_INT_HARTS_REG_OFFSET);
    for (uint32_t i = 1; i < num_int_harts; i++) {
        // Set interrupt
        *reg32(&__base_clint, i << 2) = 1;
        // Wait for interrupt pending to be cleared
        while (*reg32(&__base_clint, i << 2)) {}
    }
    // Unset SMP resume enable.
    *reg32(&__base_regs, CHESHIRE_SCRATCH_6_REG_OFFSET) = 0;
}

// Park all active nonzero harts entering this function by sending them to the boot ROM.
// This is a runtime function and should not be used in general BMPs.
void _smp_park() {
    if (get_mhartid() == 0) return;
    invoke((void *)(uintptr_t)&__base_bootrom);
}

smp_sema_t smp_sema_get(int sid) {
    // We can only allocate as many semaphores as we have platform scratch registers.
    if (sid < 0 || sid >= CHESHIRE_SCRATCH_MULTIREG_COUNT - 8) return NULL;
    return reg32(&__base_regs, CHESHIRE_SCRATCH_8_REG_OFFSET)[sid];
}

void smp_sema_wait(smp_sema_t sema, int value, uint64_t spin_period) {
    while (*sema != value) { for (uint64_t i = 0; i < spin_period; ++i) nop(); }
}

void smp_barrier(uint64_t spin_period) {
    uint32_t num_int_harts = *reg32(&__base_regs, CHESHIRE_NUM_INT_HARTS_REG_OFFSET);
    volatile uint32_t *sema = reg32(&__base_regs, CHESHIRE_SCRATCH_7_REG_OFFSET);
    __atomic_fetch_add(sema, 1, __ATOMIC_RELAXED);
    smp_sema_wait(-1, num_int_harts, spin_period);
    *sema = 0;
}
