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
.section .text._start

// Minimal bootrom loader
.global _start
.align 4
_start:
    // Globally disable Machine and Supervisor interrupts (MIE, SIE = 0).
    // Note that this will *not* stop WFI from resuming on enabled interrupts.
    csrrc zero, mstatus, 10

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

    // Pause SMP harts: enable only MSIE, disable all other interrupt sources
    li   t1, 0x8
    csrw mie, t1
    li   t0, 0
    csrr t1, mhartid
    bne  t0, t1, _smp_wait

    // Init stack and global pointer with safe, linked values
    la sp, __stack_pointer$
    .option push
    .option norelax
    la gp, __global_pointer$
    .option pop

    // If LLC present: Wait for end of BIST, then extend stack and set to all SPM
    la   t0, __base_regs
    lwu  t0, CHESHIRE_HW_FEATURES_REG_OFFSET(t0)
    andi t0, t0, (1 << CHESHIRE_HW_FEATURES_LLC_BIT)
    beqz t0, _prom_check_run
    la   t0, __base_llc
_wait_llc_bist:
    lwu  t1, AXI_LLC_BIST_STATUS_REG_OFFSET(t0) // Check BIST status done bit
    beqz t1, _wait_llc_bist
    li   t1, -1
    sw   t1, AXI_LLC_CFG_SPM_LOW_REG_OFFSET(t0)
    sw   t1, AXI_LLC_CFG_SPM_HIGH_REG_OFFSET(t0)
    li   t1, 1
    sw   t1, AXI_LLC_COMMIT_CFG_REG_OFFSET(t0)
    // Correct stack to start at end of SPM
    la   t0, __base_regs
    la   sp, __base_spm
    lwu  t0, CHESHIRE_LLC_SIZE_REG_OFFSET(t0)
    add  sp, sp, t0
    addi sp, sp, -8

// Enter Platform ROM if present. Falls through to `_boot`.
_prom_check_run:
    // Note that we have internal access to SPM here *if and only if* there is an LLC.
    li   t0, 0
    li   t1, 0
    la   ra, __base_regs
    lwu  ra, CHESHIRE_PLATFORM_ROM_REG_OFFSET(ra)
    beqz ra, _boot
    jalr ra, 0(ra)

// Reset regs, full fence, then jump to main
_boot:
    li t0, 0
    li t1, 0
    fence
    fence.i
    call main

// If main returns, we end up here
.global _exit
.align 4
_exit:
    // Save the return value to scratch register 2, try `ebreak`, then wait forever
    // Set bit 0 to signal that the execution is done.
    slli a0, a0, 1
    ori  a0, a0, 1
    la t0, __base_regs
    sw a0, CHESHIRE_SCRATCH_2_REG_OFFSET(t0)
    ebreak
1:  wfi
    j 1b

// Nonzero harts wait for and handle wakeup here
_smp_wait:
    // Set mtvec, sleep, and check MSIP; repeat unless MSIP is set (M IPI is pending).
    la   t0, 1f
    csrw t0, mtvec
    wfi
1:  csrr t0, mip
    andi t0, t0, 0x8
    beqz t0, _smp_wait
    // Clear CLINT M IPI register for this hart
    la   t0, __base_clint
    csrr ra, mhartid
    slli t1, ra, 2
    add  t1, t1, t0
    sw   zero, 0(t1) // *(CLINT_BASE + hart_id * 4) = 0
    // Check SMP enable (scratch[6][0]).
    // If this is not set, go back to sleep, as we are not meant to resume.
    la   t0, __base_regs
    lwu  t0, CHESHIRE_SCRATCH_6_REG_OFFSET(t0)
    andi t0, t0, 1
    beqz t0, _smp_wait
    // Jump to scratch[5:4]. Synchronization, if any, should be done there.
    la   t1, __base_regs
    lwu  t0, CHESHIRE_SCRATCH_4_REG_OFFSET(t1)
    lwu  t1, CHESHIRE_SCRATCH_5_REG_OFFSET(t1)
    slli t1, t1, 32
    ori  ra, t1, t0
    li   t0, 0
    li   t1, 1
    jalr ra, 0(ra)
    // Should we return, go back to `_start` to be parked again.
    j _start
