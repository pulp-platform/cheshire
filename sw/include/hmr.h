// Copyright 2023 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Yvan Tortorella <yvan.tortorella@unibo.it>

#include "regs/cheshire.h"
#include "util.h"

#define QUAUX(X) #X
#define QU(X) QUAUX(X)

#define BaseRegs 0x03000000
#define BaseHmr 0x0300B000
// We save 31 32-bit registers from RF
#define NumRfRegs 0x1F
#define HmrStateSize 0x8*NumRfRegs

void __attribute__((naked)) chs_hmr_store_state() {
  // First flush data and instruction caches to ensure
  // we do not lose menaingful infor before clear
  fencei();
  // Disable caches to store state in memory
  __asm__ __volatile__ (
    "csrrwi x0, 0x7C1, 0x0 \n\t"
    : : : "memory");

  __asm__ __volatile__ (
    // Allocate space on top of the stack to store
    // the state
    "add  sp, sp, -" QU(HmrStateSize) " \n\t"

    // Store registers to stack
    // zero not stored as hardwired (x0)
    // ra stored as HMR checkpoint (x1)
    // sp stored to HMR once complete (x2)
    "sd   t0,  0x20(sp) \n\t" //  x5
    "sd   t1,  0x28(sp) \n\t" //  x6
    "sd   t2,  0x30(sp) \n\t" //  x7
    : : : "memory");

  __asm__ __volatile__ (
    "sd   gp,  0x10(sp) \n\t" //  x3
    "sd   tp,  0x18(sp) \n\t" //  x4
    "sd   x8,  0x38(sp) \n\t" //  fp
    "sd   s1,  0x40(sp) \n\t" //  x9
    "sd   a0,  0x48(sp) \n\t" // x10
    "sd   a1,  0x50(sp) \n\t" // x11
    "sd   a2,  0x58(sp) \n\t" // x12
    "sd   a3,  0x60(sp) \n\t" // x13
    "sd   a4,  0x68(sp) \n\t" // x14
    "sd   a5,  0x70(sp) \n\t" // x15
    "sd   a6,  0x78(sp) \n\t" // x16
    "sd   a7,  0x80(sp) \n\t" // x17
    "sd   s2,  0x88(sp) \n\t" // x18
    "sd   s3,  0x90(sp) \n\t" // x19
    "sd   s4,  0x98(sp) \n\t" // x20
    "sd   s5,  0xA0(sp) \n\t" // x21
    "sd   s6,  0xA8(sp) \n\t" // x22
    "sd   s7,  0xB0(sp) \n\t" // x23
    "sd   s8,  0xB8(sp) \n\t" // x24
    "sd   s9,  0xC0(sp) \n\t" // x25
    "sd   s10, 0xC8(sp) \n\t" // x26
    "sd   s11, 0xD0(sp) \n\t" // x27
    "sd   t3,  0xD8(sp) \n\t" // x28
    "sd   t4,  0xE0(sp) \n\t" // x29
    "sd   t5,  0xE8(sp) \n\t" // x30
    "sd   t6,  0xF0(sp) \n\t" // x31

    // Manually store necessary CSRs
    // "csrr t1,  0x341 \n\t"    // mepc
    // "csrr t2,  0x300 \n\t"    // mstatus
    // "sw   t1,  0x78(sp) \n\t" // mepc
    // "csrr t1,  0x304 \n\t"    // mie
    // "sw   t2,  0x7C(sp) \n\t" // mstatus
    // "csrr t2,  0x305 \n\t"    // mtvec
    // "sw   t1,  0x80(sp) \n\t" // mie
    // "csrr t1,  0x340 \n\t"    // mscratch
    // "sw   t2,  0x84(sp) \n\t" // mtvec
    // "csrr t2,  0x342 \n\t"    // mcause
    // "sw   t1,  0x88(sp) \n\t" // mscratch
    // "csrr t1,  0x343 \n\t"    // mtval
    // "sw   t2,  0x8C(sp) \n\t" // mcause
    // "sw   t1,  0x90(sp) \n\t" // mtval
    : : : "memory");

  // store sp to hmr core reg
  __asm__ __volatile__(
    "csrr t0, mhartid \n\t"
    "li t1, " QU(BaseHmr + HMR_CORE_OFFS) " \n\t"
    "sll t2, t0, " QU(HMR_CORE_SLL) " \n\t"
    "add t2, t2, t1 \n\t"
    "sw sp, " QU(HMR_CORE_REGS_SP_STORE_REG_OFFSET) "(t2) \n\t"
    : : : "memory");

  // Store the return address in
  // the DMR checkpoint register
  __asm__ __volatile__(
    "la t1, " QU(BaseHmr + HMR_DMR_CHECKPOINT) "\n\t"
    "sw ra, 0(t1) \n\t"
    : : : "memory");

  // Request for resynchronization (reset)
  __asm__ __volatile__(
    "la t1, " QU(BaseRegs + CHESHIRE_HARTS_SYNC_REG_OFFSET) "\n\t"
    "lw t2, 0(t1) \n\t"
    "li t3, 1 \n\t"
    "sll t3, t3, t0 \n\t"
    "or t2, t2, t3 \n\t"
    "sw t2, 0(t1) \n\t"
    : : : "memory");

  // Re-enable caches
  __asm__ __volatile__ (
    "csrrwi x0, 0x7C1, 0x1 \n\t"
    : : : "memory");

  // Sleep until reset
  __asm__ __volatile__("wfi" ::: "memory");
}

void __attribute__((naked)) chs_hmr_load_state() {
  // Read the SP from HMR register
  __asm__ __volatile__(
    "csrr t0, mhartid \n\t" // Read core id
    "li t1, " QU(BaseHmr + HMR_CORE_OFFS) " \n\t"
    "sll t0, t0, " QU(HMR_CORE_SLL) " \n\t"
    "add t0, t0, t1 \n\t"
    "lw sp, " QU(HMR_CORE_REGS_SP_STORE_REG_OFFSET) "(t0) \n\t"
    "slli sp, sp, 0x20 \n\t"
    "srli sp, sp, 0x20 \n\t"
    // "mv ra, t0 \n\t"
    : : : "memory");

  __asm__ __volatile__ (
    // Manually load necessary CSRs
    // "lw   t1,  0x78(sp) \n\t" // mepc
    // "lw   t2,  0x7C(sp) \n\t" // mstatus
    // "csrw 0x341,  t1 \n\t"    // mepc
    // "lw   t1,  0x80(sp) \n\t" // mie
    // "csrw 0x300,  t2 \n\t"    // mstatus
    // "lw   t2,  0x84(sp) \n\t" // mtvec
    // "csrw 0x304,  t1 \n\t"    // mie
    // "lw   t1,  0x88(sp) \n\t" // mscratch
    // "csrw 0x305,  t2 \n\t"    // mtvec
    // "lw   t2,  0x8C(sp) \n\t" // mcause
    // "csrw 0x340,  t1 \n\t"    // mscratch
    // "lw   t1,  0x90(sp) \n\t" // mtval
    // "csrw 0x342,  t2 \n\t"    // mcause
    // "csrw 0x343,  t1 \n\t"    // mtval

    // Load registers from stack
    // zero not loaded as hardwired (x0)
    // ra not touched is used for reboot (x1)
    // sp loaded from HMR regs (x2)
    "ld   gp,  0x10(sp) \n\t" //  x3
    "ld   tp,  0x18(sp) \n\t" //  x4
    "ld   t0,  0x20(sp) \n\t" //  x5
    "ld   t1,  0x28(sp) \n\t" //  x6
    "ld   t2,  0x30(sp) \n\t" //  x7
    "ld   x8,  0x38(sp) \n\t" //  fp
    "ld   s1,  0x40(sp) \n\t" //  x9
    "ld   a0,  0x48(sp) \n\t" // x10
    "ld   a1,  0x50(sp) \n\t" // x11
    "ld   a2,  0x58(sp) \n\t" // x12
    "ld   a3,  0x60(sp) \n\t" // x13
    "ld   a4,  0x68(sp) \n\t" // x14
    "ld   a5,  0x70(sp) \n\t" // x15
    "ld   a6,  0x78(sp) \n\t" // x16
    "ld   a7,  0x80(sp) \n\t" // x17
    "ld   s2,  0x88(sp) \n\t" // x18
    "ld   s3,  0x90(sp) \n\t" // x19
    "ld   s4,  0x98(sp) \n\t" // x20
    "ld   s5,  0xA0(sp) \n\t" // x21
    "ld   s6,  0xA8(sp) \n\t" // x22
    "ld   s7,  0xB0(sp) \n\t" // x23
    "ld   s8,  0xB8(sp) \n\t" // x24
    "ld   s9,  0xC0(sp) \n\t" // x25
    "ld   s10, 0xC8(sp) \n\t" // x26
    "ld   s11, 0xD0(sp) \n\t" // x27
    "ld   t3,  0xD8(sp) \n\t" // x28
    "ld   t4,  0xE0(sp) \n\t" // x29
    "ld   t5,  0xE8(sp) \n\t" // x30
    "ld   t6,  0xF0(sp) \n\t" // x31

    // Release space on the stack
    "add  sp, sp, " QU(HmrStateSize) " \n\t"
    : : : "memory");

  // Clear SP register in HMR
  // __asm__ __volatile__(
  //   "sw zero, " QU(HMR_CORE_REGS_SP_STORE_REG_OFFSET) "(ra) \n\t"
  //   "lw ra, -" QU(HmrStateSize) "(sp) \n\t"
  //   : : : "memory");
}
