// Copyright 2026 Zhao Wenyao.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

// The linker places two distinct PT_LOAD segments next to each other, with the
// second starting inside the last 64-bit beat of the first. Preloading the
// second segment must preserve all 13 bytes of the first segment.
.section .text
.global main
main:
    fence
    li a0, 0
    la t0, slink_preload_a
    li t1, 1
    li t2, 14
1:
    lbu t3, 0(t0)
    xor t3, t3, t1
    snez t3, t3
    add a0, a0, t3
    addi t0, t0, 1
    addi t1, t1, 1
    bne t1, t2, 1b

    la t0, slink_preload_b
    li t1, 0x81
    li t2, 0x8a
1:
    lbu t3, 0(t0)
    xor t3, t3, t1
    snez t3, t3
    add a0, a0, t3
    addi t0, t0, 1
    addi t1, t1, 1
    bne t1, t2, 1b
    ret

.section .slink_preload_a,"a",@progbits
slink_preload_a:
    .byte 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13

.section .slink_preload_b,"a",@progbits
slink_preload_b:
    .byte 0x81, 0x82, 0x83, 0x84, 0x85, 0x86, 0x87, 0x88, 0x89
