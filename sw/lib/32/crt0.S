// Copyright 2022 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Nicole Narr <narrn@student.ethz.ch>
// Christopher Reinwardt <creinwar@student.ethz.ch>
// Paul Scheffler <paulsc@iis.ee.ethz.ch>

.section .text._start

// Minimal CRT0
.global _start
_start:
    // Globally disable Machine and Supervisor interrupts
    csrrc x0, mstatus, 10

    // Park SMP harts
    csrr t0, mhartid
    beqz t0, 2f
1:
    wfi
    j 1b
2:
    // Init stack and global pointer iff linked as nonzero
    mv t1, sp
    la t0, __stack_pointer$
    beqz t0, 1f
    mv sp, t0
1:  .option push
    .option norelax
    la t0, __global_pointer$
    beqz t0, 1f
    mv gp, t0
1:  .option pop

    // Store existing stack, global, return pointers on new stack
    addi sp, sp, -12
    sw t1, 0(sp)
    sw gp, 4(sp)
    sw ra, 8(sp)

    // Set trap vector
    la t0, _trap_handler_wrap
    csrrw x0, mtvec, t0

    // Zero the .bss section
    la t0, __bss_start      // t0 = bss start address
    la t1, __bss_end        // t1 = bss end address
    sub t2, t1, t0          // t2 = #bytes to zero
    li a0, 0

_zero_bss_loop:
    addi t4, t2, -16
    blez t2, _fp_init           // t2 <= 0? => No bss to zero
    blt t4, x0, _zero_bss_rem   // t4 <  0? => Less than 4 words left
    sw a0, 0(t0)
    sw a0, 4(t0)
    sw a0, 8(t0)
    sw a0, 12(t0)
    addi t2, t2, -16
    addi t0, t0, 16
    bgt t2, x0, _zero_bss_loop  // Still more to go
    j _fp_init

_zero_bss_rem:
    sb a0, 0(t0)
    addi t2, t2, -1
    addi t0, t0, 1
    bgt t2, x0, _zero_bss_rem

_fp_init:
    // Full fence, then jump to main
    call main

// If main returns, we end up here
.global _exit
_exit:
    // Restore the original context registers (sp last)
    lw ra, 8(sp)
    lw gp, 4(sp)
    lw sp, 0(sp)
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
    addi sp, sp, -64
    sw ra, 60(sp)
    sw t0, 56(sp)
    sw t1, 52(sp)
    sw t2, 48(sp)
    sw a0, 44(sp)
    sw a1, 40(sp)
    sw a2, 36(sp)
    sw a3, 32(sp)
    sw a4, 28(sp)
    sw a5, 24(sp)
    sw a6, 20(sp)
    sw a7, 16(sp)
    sw t3, 12(sp)
    sw t4, 8(sp)
    sw t5, 4(sp)
    sw t6, 0(sp)

    jal trap_vector

    lw ra, 60(sp)
    lw t0, 56(sp)
    lw t1, 52(sp)
    lw t2, 48(sp)
    lw a0, 44(sp)
    lw a1, 40(sp)
    lw a2, 36(sp)
    lw a3, 32(sp)
    lw a4, 28(sp)
    lw a5, 24(sp)
    lw a6, 20(sp)
    lw a7, 16(sp)
    lw t3, 12(sp)
    lw t4, 8(sp)
    lw t5, 4(sp)
    lw t6, 0(sp)
    addi sp, sp, 128
    mret

.global trap_vector
.weak trap_vector
trap_vector:
    j trap_vector
