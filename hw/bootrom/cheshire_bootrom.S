// Copyright 2022 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Nicole Narr <narrn@student.ethz.ch>
// Christopher Reinwardt <creinwar@student.ethz.ch>
// Paul Scheffler <paulsc@iis.ee.ethz.ch>
// Enrico Zelioli <ezelioli@iis.ee.ethz.ch>

#include <regs/cheshire.h>
#include <regs/axi_llc.h>

// The hart that non-SMP tests should run on
#ifndef NONSMP_HART
#define NONSMP_HART 0
#endif

.section .text._start

// Minimal bootrom loader
.global _start
_start:
    // Reset all integer GPRs; we do *not* assume FP in the boot ROM.
    li x1, 0
    li x4, 0
    li x5, 0
    li x6, 0
    li x7, 0
    li x8, 0
    li x9, 0
    li x10, 0
    li x11, 0
    li x12, 0
    li x13, 0
    li x14, 0
    li x15, 0
    li x16, 0
    li x17, 0
    li x18, 0
    li x19, 0
    li x20, 0
    li x21, 0
    li x22, 0
    li x23, 0
    li x24, 0
    li x25, 0
    li x26, 0
    li x27, 0
    li x28, 0
    li x29, 0
    li x30, 0
    li x31, 0

    // Pause SMP harts
    li   t1, 0x8
    csrw mie, t1
    li   t0, NONSMP_HART
    csrr t1, mhartid
    bne  t0, t1, _wait_for_ipi

    // Init stack and global pointer with safe, linked values
    la sp, __stack_pointer$
    .option push
    .option norelax
    la gp, __global_pointer$
    .option pop

    // If LLC present: Wait for end of BIST, then extend stack and set to all SPM
    la   t0, __base_regs
    lw   t0, CHESHIRE_HW_FEATURES_REG_OFFSET(t0)
    andi t0, t0, 2  // HW_FEATURES.llc
    beqz t0, _prom_check_run
    la   t0, __base_llc
_wait_llc_bist:
    lw   t1, AXI_LLC_BIST_STATUS_REG_OFFSET(t0) // Check BIST status done bit
    beqz t1, _wait_llc_bist
    li   t1, -1
    sw   t1, AXI_LLC_CFG_SPM_LOW_REG_OFFSET(t0)
    sw   t1, AXI_LLC_CFG_SPM_HIGH_REG_OFFSET(t0)
    li   t1, 1
    sw   t1, AXI_LLC_COMMIT_CFG_REG_OFFSET(t0)
    // Correct stack to start at end of SPM
    la   t0, __base_regs
    la   sp, __base_spm
    lw   t0, CHESHIRE_LLC_SIZE_REG_OFFSET(t0)
    add  sp, sp, t0
    addi sp, sp, -8

// Enter Platform ROM if present.
_prom_check_run:
    // Note that we have internal access to SPM here *if and only if* there is an LLC.
    la t0, __base_regs
    lw t0, CHESHIRE_PLATFORM_ROM_REG_OFFSET(t0)
    beqz t0, _boot
    jalr t0

// Move to next stage of booting
// 1. Write the address of next stage boot loader in Cheshire's scratch registers
// 2. Resume execution of all other harts
.global boot_next_stage
boot_next_stage:

    // Non-SMP hart: write boot address into global scratch registers
    la   t0, __base_regs
    sw   a0, CHESHIRE_SCRATCH_4_REG_OFFSET(t0)
    srli a0, a0, 32
    sw   a0, CHESHIRE_SCRATCH_5_REG_OFFSET(t0)
    fence

    // Resume SMP harts: set CLINT IPI registers
    // NOTE: this will cause CLINT to send IPIs to all cores, therefore also the
    // non-smp hart will receive one. The following instructions make sure that
    // all harts will wait until the IPI is received (WFI with global ie disabled),
    // then clear the IPI in the CLINT and wait until all other harts are done with it.
    la   t0, __base_clint
    la   t2, __base_regs
    lw   t2, CHESHIRE_NUM_INT_HARTS_REG_OFFSET(t2)
    slli t2, t2, 2
    add  t2, t0, t2  // t2 = CLINT_BASE + (n_harts * 4)
1:
    li   t1, 1
    sw   t1, 0(t0)
    addi t0, t0, 4
    blt  t0, t2, 1b

// Stall hart until IPI is raised
_wait_for_ipi:

    // Wait until this hart receives IPI
    wfi
    csrr t1, mip
    andi t1, t1, 0x8
    beqz t1, _wait_for_ipi

    // Clear CLINT IPI register for this hart
    la   t0, __base_clint
    csrr t1, mhartid
    slli t1, t1, 2
    add  t1, t1, t0
    sw   zero, 0(t1)   // *(CLINT_BASE + hart_id * 4) = 0

    la   t2, __base_regs
    lw   t2, CHESHIRE_NUM_INT_HARTS_REG_OFFSET(t2)
    slli t2, t2, 2
    add  t2, t0, t2    // t2 = CLINT_BASE + (n_harts * 4)

    // Wait until *all* CLINT IPI registers are cleared
1:
    lw   t1, 0(t0)
    bnez t1, 1b
    addi t0, t0, 4
    blt  t0, t2, 1b

    // Jump to next stage
    // Load boot address from global scratch registers
    la   t0, __base_regs
    lwu  t1, CHESHIRE_SCRATCH_5_REG_OFFSET(t0)
    slli t1, t1, 32
    lwu  t0, CHESHIRE_SCRATCH_4_REG_OFFSET(t0)
    or   t0, t0, t1
    csrr a0, mhartid  // Store hartid to a0
    jalr ra, 0(t0)    // Jump to boot address
    ret               // We should never get here

// Reset regs, full fence, then jump to main
_boot:
    li t0, 0
    li t1, 0
    fence
    fence.i
    call main

// If main returns, we end up here
.global _exit
_exit:
    // Save the return value to scratch register 2 and wait forever
    // Set bit 0 to signal that the execution is done.
    slli a0, a0, 1
    ori  a0, a0, 1
    la t0, __base_regs
    sw a0, CHESHIRE_SCRATCH_2_REG_OFFSET(t0)
1:  wfi
    j 1b
