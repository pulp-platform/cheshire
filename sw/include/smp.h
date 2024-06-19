// Copyright 2023 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#pragma once

// The hart that non-SMP tests should run on
#ifndef NONSMP_HART
#define NONSMP_HART 0
#endif

// Let non-SMP hart continue and all other harts jump (and loop) in smp_resume
#define smp_pause(reg1, reg2) \
    li reg2, 0x8; \
    csrw mie, reg2; \
    li reg1, NONSMP_HART; \
    csrr reg2, mhartid; \
    bne reg1, reg2, 2f

// If the two harts are lockestepped at reset or peremanetly locked, we must
// see a single Hart ID at boot. Otherwise we see NUM_INT_HARTS.
// The procedure to set/unset the CLINT MSIP registers for the two harts is
// the following:
// 0. We read the number of physical harts (NUM_INT_HARTS) in reg3.
// 1. We read the DMR enabled register from the HMR unit in reg2.
// 2. We compute the number of virtual harts:
//    2a. If reg2=1, we divide NUM_INT_HARTS by 2 (reg3 >> reg2).
//    2b. If reg2=0, we divide NUM_INT_HARTS by 1 (reg3 >> reg2).
// 3. We multiply the number of virtual harts by 4:
//    3a. If reg2=1, the result is 4 (reg3 << 2).
//    3b. If reg2=0, the result is 8 (reg3 << 2).
// 4. Consequently, we compute the MSIP offset to access the CLINT.
#define smp_resume(reg1, reg2, reg3) \
    la reg1, __base_clint; \
    la reg3, __base_regs; \
    lw reg3, 76(reg3); /* regs.NUM_INT_HARTS */ \
    la reg2, __base_hmr; \
    lw reg2, 512(reg2); /* DMR en/dis */ \
    srl reg3, reg3, reg2; \
    sll reg3, reg3, 2; \
    add reg3, reg1, reg3; \
    1:; \
    li reg2, 1; \
    sw reg2, 0(reg1); \
    addi reg1, reg1, 4; \
    blt reg1, reg3, 1b; \
    2:; \
    wfi; \
    csrr reg2, mip; \
    andi reg2, reg2, 0x8; \
    beqz reg2, 2b; \
    la reg1, __base_clint; \
    csrr reg2, mhartid; \
    slli reg2, reg2, 2; \
    add reg2, reg2, reg1; \
    sw zero, 0(reg2); \
    la reg3, __base_regs; \
    lw reg3, 76(reg3); /* regs.NUM_INT_HARTS */ \
    slli reg3, reg3, 2; \
    add reg3, reg1, reg3; \
    3:; \
    lw reg2, 0(reg1); \
    bnez reg2, 3b; \
    addi reg1, reg1, 4; \
    blt reg1, reg3, 3b
