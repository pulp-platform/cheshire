// Copyright 2022 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Nicole Narr <narrn@student.ethz.ch>
// Christopher Reinwardt <creinwar@student.ethz.ch>
// Paul Scheffler <paulsc@iis.ee.ethz.ch>
// Emanuele Parisi <emanuele.parisi@unibo.it>

.section .text._start

// Minimal CRT0
.global _start
_start:
    // Globally disable Machine and Supervisor interrupts
    csrrc x0, mstatus, 10

_init_gp:
    // Init global pointer iff linked as nonzero
    .option push
    .option norelax
    la t0, __global_pointer$
    beqz t0, _init_sp
    mv gp, t0
    .option pop

_init_sp:
    // Init stack pointer iff linked as nonzero
    mv t0, sp
    la t1, __stack_pointer$
    beqz t1, _init_context
    la t2, __stack_size$
    csrr t3, mhartid
    mul t3, t3, t2
    sub sp, t1, t3

_init_context:
    // Store existing stack, global, return pointers on new stack
    addi sp, sp, -24
    sd t0, 0(sp)
    sd gp, 8(sp)
    sd ra, 16(sp)

    // Set trap vector
    la t0, _trap_handler_wrap
    csrrw x0, mtvec, t0

_fp_init:
    // Set FS state to "Initial", enabling FP instructions
    li t1, 1
    slli t1, t1, 13
    csrs mstatus, t1

    // Clear all 32 double FP registers
    fcvt.d.l f0, x0
    fmv.d f1, f0
    fmv.d f2, f0
    fmv.d f3, f0
    fmv.d f4, f0
    fmv.d f5, f0
    fmv.d f6, f0
    fmv.d f7, f0
    fmv.d f8, f0
    fmv.d f9, f0
    fmv.d f10, f0
    fmv.d f11, f0
    fmv.d f12, f0
    fmv.d f13, f0
    fmv.d f14, f0
    fmv.d f15, f0
    fmv.d f16, f0
    fmv.d f17, f0
    fmv.d f18, f0
    fmv.d f19, f0
    fmv.d f20, f0
    fmv.d f21, f0
    fmv.d f22, f0
    fmv.d f23, f0
    fmv.d f24, f0
    fmv.d f25, f0
    fmv.d f26, f0
    fmv.d f27, f0
    fmv.d f28, f0
    fmv.d f29, f0
    fmv.d f30, f0
    fmv.d f31, f0

    // Set FS state to "Clean"
    csrrc x0, mstatus, t1

_smp_park:
    call smp_pause

_zero_bss_init:
    // Zero the .bss section
    la t0, __bss_start      // t0 = bss start address
    la t1, __bss_end        // t1 = bss end address
    sub t2, t1, t0          // t2 = #bytes to zero
    li a0, 0

_zero_bss_loop:
    addi t4, t2, -32
    blez t2, _entry             // t2 <= 0? => No bss to zero
    blt t4, x0, _zero_bss_rem   // t4 <  0? => Less than 4 words left
    sd a0, 0(t0)
    sd a0, 8(t0)
    sd a0, 16(t0)
    sd a0, 24(t0)
    addi t2, t2, -32
    addi t0, t0, 32
    bgt t2, x0, _zero_bss_loop  // Still more to go
    j _entry

_zero_bss_rem:
    sb a0, 0(t0)
    addi t2, t2, -1
    addi t0, t0, 1
    bgt t2, x0, _zero_bss_rem

_entry:
    // Full fence, then jump to main
    fence
    call main

// If main returns, we end up here
.global _exit
_exit:
    // Restore the original context registers (sp last)
    ld ra, 16(sp)
    ld gp, 8(sp)
    ld sp, 0(sp)
    // Save the return value to scratch register 2 and wait forever.
    slli t0, a0, 1
    ori  t0, t0, 1
    la t1, __base_regs
    sw t0, 8(t1)     // regs.SCRATCH[2]
    // Hand over to whatever called us, passing return
    ret

// This wraps the C trap handler to save the (integer-only) caller-save
// registers and perform a proper machine-mode exception return.
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
