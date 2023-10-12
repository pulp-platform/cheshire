// Copyright 2022 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Emanuele Parisi <emanuele.parisi@unibo.it> 

#include "smp.h"

void smp_pause(void) {
    uint64_t mhartid = get_mhartid();
    uint64_t next_addr_lo = 0x0;
    uint64_t next_addr_hi = 0x0;
    
    fence();
    if (mhartid != 0x0) {
        // Enable M-mode software interrupts. 
        set_msie(true);

        // Remain in WFI until the MSIP bit is set and clear it on wake-up.
        do {
            wfi();
        } while (!get_msip());

        // Clear MSIP bit and appropriate IPI register in the CLINT.
        set_msip(false);
        *reg32(&__base_clint, mhartid << 2) = 0x0;

        // Read jump address from SCRATCH[4:5] registers.
        next_addr_lo = (uint64_t)*reg32(&__base_regs, CHESHIRE_SCRATCH_4_REG_OFFSET);
        next_addr_hi = (uint64_t)*reg32(&__base_regs, CHESHIRE_SCRATCH_5_REG_OFFSET);

        // Flush i-cache and jump.
        invoke((void*)(next_addr_lo | (next_addr_hi << 32)));
    }
}

void smp_resume(void) {
    uint64_t resume_addr = (uint64_t)(&&Lsmp_resume_target);
    uint32_t resume_addr_lo = resume_addr & 0xffffffff;
    uint32_t resume_addr_hi = resume_addr >> 32;
    uint32_t num_harts = *reg32(&__base_regs, CHESHIRE_NUM_INT_HARTS_REG_OFFSET);

    // Write resume address in SCRATCH[4:5].
    *reg32(&__base_regs, CHESHIRE_SCRATCH_4_REG_OFFSET) = resume_addr_lo;
    *reg32(&__base_regs, CHESHIRE_SCRATCH_5_REG_OFFSET) = resume_addr_hi;

    // Flush cache and wake-up all sleeping cores.
    fence();
    for (uint32_t i=1; i<num_harts; i++) {
        *reg32(&__base_clint, i << 2) = 0x1;
        while (*reg32(&__base_clint, i << 2));
    }

Lsmp_resume_target:
    nop();
}
