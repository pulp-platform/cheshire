// Copyright 2022 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Nicole Narr <narrn@student.ethz.ch>
// Christopher Reinwardt <creinwar@student.ethz.ch>

.section .text._start

// Minimal crt0
.global _start
_start:
    // Globally disable Machine and Supervisor interrupts
    csrrc x0, mstatus, 10

    // Init stack and global pointer
    la sp, __stack_pointer$
    .option push
    .option norelax
    la gp, __global_pointer$
    .option pop

    // Set trap vector
    la t0, _trap_handler_wrap
    csrrw x0, mtvec, t0

_zero_bss:
    // Zero the .bss section
    la t0, __bss_start      // t0 = bss start address
    la t1, __bss_end        // t1 = bss end address
    sub t2, t1, t0          // t2 = #bytes to zero
    li a0, 0

_zero_bss_loop:
    addi t4, t2, -32
    blez t2, _zero_bss_end  // t2 <= 0? => No bss to zero
    blt t4, x0, _zero_bss_rem   // t4 <  0? => Less than 4 words left

    sd a0, 0(t0)
    sd a0, 8(t0)
    sd a0, 16(t0)
    sd a0, 24(t0)

    addi t2, t2, -32
    addi t0, t0, 32

    bgt t2, x0, _zero_bss_loop  // Still more to go
    j _zero_bss_end

_zero_bss_rem:
    sb a0, 0(t0)
    addi t2, t2, -1
    addi t0, t0, 1
    bgt t2, x0, _zero_bss_rem

_zero_bss_end:

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

    // Boldly flush everything
    fence.i

    jal main

    // Main returned - save return value and mark as done
    j _exit



// This wraps the normal C function for trap handling
// to save the caller-save registers and perform a proper
// Machine mode exception return
.align 4
_trap_handler_wrap:
    addi sp, sp, -128
    sd ra, 120(sp)
    sd t0, 112(sp)
    sd t1, 104(sp)
    sd t2, 96(sp)
    sd a0, 88(sp)
    sd a1, 80(sp)
    sd a2, 72(sp)
    sd a3, 64(sp)
    sd a4, 56(sp)
    sd a5, 48(sp)
    sd a6, 40(sp)
    sd a7, 32(sp)
    sd t3, 24(sp)
    sd t4, 16(sp)
    sd t5, 8(sp)
    sd t6, 0(sp)

    jal trap_vector

    ld ra, 120(sp)
    ld t0, 112(sp)
    ld t1, 104(sp)
    ld t2, 96(sp)
    ld a0, 88(sp)
    ld a1, 80(sp)
    ld a2, 72(sp)
    ld a3, 64(sp)
    ld a4, 56(sp)
    ld a5, 48(sp)
    ld a6, 40(sp)
    ld a7, 32(sp)
    ld t3, 24(sp)
    ld t4, 16(sp)
    ld t5, 8(sp)
    ld t6, 0(sp)
    addi sp, sp, 128
    mret

.global trap_vector
.weak trap_vector
trap_vector:
    j trap_vector

// If main returns, we end up here.
// Save the return value to scratch register 2 and wait forever.
_exit:
    slli a0, a0, 1
    ori  a0, a0, 1
    la t0, __base_regs
    sw a0, 8(t0)     // regs.SCRATCH[2]

_exit_wait_loop:
    wfi
    j _exit_wait_loop
