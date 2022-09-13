// Copyright 2022 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Nicole Narr <narrn@student.ethz.ch>
// Christopher Reinwardt <creinwar@student.ethz.ch>

.section .text._start

// Minimal bootrom crt0
.global _start
.global _exit
_start:
    // Init stack and global pointer
    la sp, __stack_pointer$
    .option push
    .option norelax
    la gp, __global_pointer$
    .option pop

    // Reset all the registers
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

// If main returns we end up here
// Save the return value to the scratch register 0
// and wait forever
_exit:
    slli a0, a0, 1
    ori  a0, a0, 1
    li t0, 0x02004000
    sw a0, 4(t0)

_exit_wait_loop:
    wfi
    j _exit_wait_loop