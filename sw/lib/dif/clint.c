// Copyright 2022 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Nicole Narr <narrn@student.ethz.ch>
// Christopher Reinwardt <creinwar@student.ethz.ch>
// Paul Scheffler <paulsc@iis.ee.ethz.ch>

#include "dif/clint.h"
#include "regs/clint.h"
#include "util.h"
#include "params.h"

volatile uint64_t clint_get_mtime() {
    return (((volatile uint64_t) * reg32(&__base_clint, CLINT_MTIME_HIGH_REG_OFFSET) << 32) |
            *reg32(&__base_clint, CLINT_MTIME_LOW_REG_OFFSET));
}

void clint_set_mtimecmpx(uint64_t timer_idx, uint64_t value) {
    uint32_t vlo = (uint32_t)(value);
    uint32_t vhi = (uint32_t)(value >> 32);
    uint64_t mtimecmp_offs = timer_idx << 3;
    // Write high register first
    *reg32(&__base_clint, CLINT_MTIMECMP_HIGH0_REG_OFFSET + mtimecmp_offs) = vhi;
    *reg32(&__base_clint, CLINT_MTIMECMP_LOW0_REG_OFFSET + mtimecmp_offs) = vlo;
}

// PRE: requires an appropriate trap handler catching the timer interrupt
void clint_sleep_ticks(uint64_t timer_idx, uint64_t ticks) {
    if (ticks == 0) return;
    // Set comparison register `ticks` from now
    clint_set_mtimecmpx(timer_idx, clint_get_mtime() + ticks);
    fence();
    // Make sure timer and global interrupts are enabled
    set_mtie(1);
    set_mie(1);
    // Wait for interrupt, resuming from here
    wfi();
}
