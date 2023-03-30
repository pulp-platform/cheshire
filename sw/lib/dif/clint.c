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
    return (((volatile uint64_t) * reg32(&__base_clint, CLINT_MTIME_HIGH_REG_OFFSET)) << 32) |
           ((volatile uint64_t) * reg32(&__base_clint, CLINT_MTIME_LOW_REG_OFFSET));
}

void clint_spin_until(uint64_t tgt_mtime) {
    while (clint_get_mtime() < tgt_mtime)
        ;
}

void clint_spin_ticks(uint64_t ticks) {
    clint_spin_until(clint_get_mtime() + ticks);
}

uint64_t clint_get_core_freq(uint64_t ref_freq, uint64_t num_ticks) {
    uint64_t end_mcycle, start_mcycle;
    uint64_t end_mtime = clint_get_mtime(), start_mtime;
    // Capture start times until we observe an RTC tick rollover
    do {
        start_mcycle = get_mcycle();
        start_mtime = clint_get_mtime();
    } while (start_mtime == end_mtime);
    // Capture end times until we observe rollover to the past-the-end RTC tick
    do {
        end_mcycle = get_mcycle();
        end_mtime = clint_get_mtime();
    } while (end_mtime < start_mtime + num_ticks);
    // Compute current frequency in Hz
    return ((end_mcycle - start_mcycle) * ref_freq) / (end_mtime - start_mtime);
}

void clint_set_mtimecmpx(uint64_t timer_idx, uint64_t value) {
    uint32_t vlo = (uint32_t)(value);
    uint32_t vhi = (uint32_t)(value >> 32);
    uint64_t mtimecmp_offs = timer_idx << 3;
    // Write high register first
    *reg32(&__base_clint, CLINT_MTIMECMP_HIGH0_REG_OFFSET + mtimecmp_offs) = vhi;
    *reg32(&__base_clint, CLINT_MTIMECMP_LOW0_REG_OFFSET + mtimecmp_offs) = vlo;
}

void clint_sleep_until(uint64_t timer_idx, uint64_t tgt_mtime) {
    if (clint_get_mtime() < tgt_mtime) return;
    // Set comparison register `ticks` from now
    clint_set_mtimecmpx(timer_idx, tgt_mtime);
    fence();
    // Make sure timer and global interrupts are enabled
    set_mtie(1);
    set_mie(1);
    // Wait for interrupt, resuming from here
    wfi();
}

void clint_sleep_ticks(uint64_t timer_idx, uint64_t ticks) {
    clint_sleep_until(timer_idx, clint_get_mtime() + ticks);
}
