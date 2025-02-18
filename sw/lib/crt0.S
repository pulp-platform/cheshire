// Copyright 2022 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Nicole Narr <narrn@student.ethz.ch>
// Christopher Reinwardt <creinwar@student.ethz.ch>
// Paul Scheffler <paulsc@iis.ee.ethz.ch>

.section .text._start


#if __riscv_xlen == 64
# define LREG ld
# define SREG sd
# define REGBYTES 8
#elif __riscv_xlen == 32
# define LREG lw
# define SREG sw
# define REGBYTES 4
#endif

#if __riscv_flen == 64
#define FCVT fcvt.d.l
#define FMV fmv.d
#elif __riscv_flen == 32
#define FCVT fcvt.s.w
#define FMV fmv.s
#endif

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
    addi sp, sp, -(3*REGBYTES)
    SREG t1, 0*REGBYTES(sp)
    SREG gp, 1*REGBYTES(sp)
    SREG ra, 2*REGBYTES(sp)

    // Set trap vector
    la t0, _trap_handler_wrap
    csrrw x0, mtvec, t0

    // Zero the .bss section
    la t0, __bss_start      // t0 = bss start address
    la t1, __bss_end        // t1 = bss end address
    sub t2, t1, t0          // t2 = #bytes to zero
    li a0, 0

_zero_bss_loop:
    addi t4, t2, -32
    blez t2, _fp_init           // t2 <= 0? => No bss to zero
    blt t4, x0, _zero_bss_rem   // t4 <  0? => Less than 4 words left
    SREG a0, 0*REGBYTES(t0)
    SREG a0, 1*REGBYTES(t0)
    SREG a0, 2*REGBYTES(t0)
    SREG a0, 3*REGBYTES(t0)
    addi t2, t2, -32
    addi t0, t0, 32
    bgt t2, x0, _zero_bss_loop  // Still more to go
    j _fp_init

_zero_bss_rem:
    sb a0, 0(t0)
    addi t2, t2, -1
    addi t0, t0, 1
    bgt t2, x0, _zero_bss_rem

_fp_init:

    #if defined(__riscv_flen) && __riscv_flen > 0
    // Set FS state to "Initial", enabling FP instructions
    li t1, 1
    slli t1, t1, 13
    csrs mstatus, t1

    // Clear all 32 double FP registers
    FCVT f0, x0
    FMV f1, f0
    FMV f2, f0
    FMV f3, f0
    FMV f4, f0
    FMV f5, f0
    FMV f6, f0
    FMV f7, f0
    FMV f8, f0
    FMV f9, f0
    FMV f10, f0
    FMV f11, f0
    FMV f12, f0
    FMV f13, f0
    FMV f14, f0
    FMV f15, f0
    FMV f16, f0
    FMV f17, f0
    FMV f18, f0
    FMV f19, f0
    FMV f20, f0
    FMV f21, f0
    FMV f22, f0
    FMV f23, f0
    FMV f24, f0
    FMV f25, f0
    FMV f26, f0
    FMV f27, f0
    FMV f28, f0
    FMV f29, f0
    FMV f30, f0
    FMV f31, f0

    // Set FS state to "Clean"
    csrrc x0, mstatus, t1

    #endif

    // Full fence, then jump to main
    fence
    call main

// If main returns, we end up here
.global _exit
_exit:
    // Restore the original context registers (sp last)
    LREG ra, 2*REGBYTES(sp)
    LREG gp, 1*REGBYTES(sp)
    LREG sp, 0*REGBYTES(sp)
    addi sp, sp, (3*REGBYTES)
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
    addi sp, sp, -(16*REGBYTES)
    SREG ra, 15*REGBYTES(sp)
    SREG t0, 14*REGBYTES(sp)
    SREG t1, 13*REGBYTES(sp)
    SREG t2, 12*REGBYTES(sp)
    SREG a0, 11*REGBYTES(sp)
    SREG a1, 10*REGBYTES(sp)
    SREG a2, 9*REGBYTES(sp)
    SREG a3, 8*REGBYTES(sp)
    SREG a4, 7*REGBYTES(sp)
    SREG a5, 6*REGBYTES(sp)
    SREG a6, 5*REGBYTES(sp)
    SREG a7, 4*REGBYTES(sp)
    SREG t3, 3*REGBYTES(sp)
    SREG t4, 2*REGBYTES(sp)
    SREG t5, 1*REGBYTES(sp)
    SREG t6, 0*REGBYTES(sp)

    jal trap_vector

    LREG ra, 15*REGBYTES(sp)
    LREG t0, 14*REGBYTES(sp)
    LREG t1, 13*REGBYTES(sp)
    LREG t2, 12*REGBYTES(sp)
    LREG a0, 11*REGBYTES(sp)
    LREG a1, 10*REGBYTES(sp)
    LREG a2, 9*REGBYTES(sp)
    LREG a3, 8*REGBYTES(sp)
    LREG a4, 7*REGBYTES(sp)
    LREG a5, 6*REGBYTES(sp)
    LREG a6, 5*REGBYTES(sp)
    LREG a7, 4*REGBYTES(sp)
    LREG t3, 3*REGBYTES(sp)
    LREG t4, 2*REGBYTES(sp)
    LREG t5, 1*REGBYTES(sp)
    LREG t6, 0*REGBYTES(sp)
    addi sp, sp, (16*REGBYTES)
    mret

.global trap_vector
.weak trap_vector
trap_vector:
    j trap_vector
