// Copyright 2022 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Nicole Narr <narrn@student.ethz.ch>
// Christopher Reinwardt <creinwar@student.ethz.ch>
// Paul Scheffler <paulsc@iis.ee.ethz.ch>

#pragma once

#include <stdint.h>
#include "params.h"

// CVA6 HMR Unit
#define HMR_CORE_OFFS               0x100
#define HMR_DMR_OFFS                0x200
#define HMR_TMR_OFFS                0x300
#define HMR_CORE_INCREMENT          0x010
#define HMR_CORE_SLL                0x004
#define HMR_DMR_INCREMENT           0x010
#define HMR_DMR_SLL                 0x004
#define HMR_TMR_INCREMENT           0x010
#define HMR_TMR_SLL                 0x004

// Stack Pointer storage register
#define HMR_CORE_REGS_SP_STORE_REG_OFFSET 0x8
#define HMR_DMR_ENABLE_OFFS         0x0
#define HMR_DMR_CFG_REG_OFFS        0x4
#define HMR_DMR_CHECKPOINT_REG_OFFS 0x8
#define HMR_DMR_ENABLE              HMR_DMR_OFFS + HMR_DMR_ENABLE_OFFS
#define HMR_DMR_CFG                 HMR_DMR_OFFS + HMR_DMR_CFG_REG_OFFS
#define HMR_DMR_CHECKPOINT          HMR_DMR_OFFS + HMR_DMR_CHECKPOINT_REG_OFFS

static inline volatile uint8_t *reg8(void *base, int offs) {
    return (volatile uint8_t *)(base + offs);
}

static inline volatile uint32_t *reg32(void *base, int offs) {
    return (volatile uint32_t *)(base + offs);
}

static inline void fence() {
    asm volatile("fence" ::: "memory");
}

static inline void fencei() {
    asm volatile("fence.i" ::: "memory");
}

static inline void wfi() {
    asm volatile("wfi" ::: "memory");
}

static inline void nop() {
    asm volatile("nop" ::: "memory");
}

// Enables or disables M-mode timer interrupts.
static inline void set_mtie(int enable) {
    if (enable)
        asm volatile("csrs mie, %0" ::"r"(128) : "memory");
    else
        asm volatile("csrc mie, %0" ::"r"(128) : "memory");
}

// Enables or disables M-mode software interrupts.
static inline void set_msie(int enable) {
    if (enable)
        asm volatile("csrs mie, %0" ::"r"(8) : "memory");
    else
        asm volatile("csrc mie, %0" ::"r"(8) : "memory");
}

// Enables or disables M-mode software interrupts pending bit.
static inline void set_msip(int enable) {
    if (enable)
        asm volatile("csrs mip, %0" ::"r"(8) : "memory");
    else
        asm volatile("csrc mip, %0" ::"r"(8) : "memory");
}

// Get M-mode software interrupts pending bit.
static inline uint64_t get_msip() {
    uint64_t msip;
    asm volatile("csrr %0, mip" : "=r"(msip)::"memory");
    return (msip & 0x8) >> 3;
}

// Enables or disables M-mode global interrupts.
static inline void set_mie(int enable) {
    if (enable)
        asm volatile("csrsi mstatus, 8" ::: "memory");
    else
        asm volatile("csrci mstatus, 8" ::: "memory");
}

// Get hart id
static inline uint64_t get_mhartid() {
    uint64_t mhartid;
    asm volatile("csrr %0, mhartid" : "=r"(mhartid)::"memory");
    return mhartid;
}

// Get cycle count since reset
static inline uint64_t get_mcycle() {
    uint64_t mcycle;
    asm volatile("csrr %0, mcycle" : "=r"(mcycle)::"memory");
    return mcycle;
}

// This may also be used to invoke code that does not return.
static inline uint64_t invoke(void *code) {
    uint64_t (*code_fun_ptr)(void) = code;
    fencei();
    return code_fun_ptr();
}

// Set global pointer and return prior value. Use with caution.
static inline void *gprw(void *gp) {
    void *ret;
    asm volatile("mv %0, gp" : "=r"(ret)::"memory");
    if (gp) asm volatile("mv gp, %0" ::"r"(gp) : "memory", "gp");
    return ret;
}

// If a call yields a nonzero return, return that immediately as an int.
#define CHECK_CALL(call) \
    { \
        int __ccret = (volatile int)(call); \
        if (__ccret) return __ccret; \
    }

// If a condition; if it is untrue, ummediately return an error code.
#define CHECK_ASSERT(ret, cond) \
    if (!(cond)) return (ret);

#define MIN(a, b) (((a) <= (b)) ? (a) : (b))

// Read hart ID
static inline unsigned int hart_id() {
    int hart_id;
    asm volatile("csrr %0, mhartid" : "=r"(hart_id) :);
    return hart_id;
}

// Disable data caches
static inline void disable_dcache() {
    asm volatile("csrrwi x0, 0x701, 0x0 \n\t" : : : "memory");
}

// Enable data caches
static inline void enable_dcache() {
    asm volatile("csrrwi x0, 0x701, 0x1 \n\t" : : : "memory");
}

// The following is for future DMR support
// Wake up sleeping hart using CLINT
static inline void wakeup_hart(unsigned int hart_id) {
    *reg32(&__base_clint, 0x4 * hart_id) = 0x1;
    *reg32(&__base_clint, 0x4 * hart_id) = 0x0;
}

// Write synchronization request in dedicated register
// static inline void sync_req(unsigned int hart_id){
//     uint32_t sync_reg = *reg32(&__base_regs, CHESHIRE_HARTS_SYNC_REG_OFFSET);
//     *reg32(&__base_regs, CHESHIRE_HARTS_SYNC_REG_OFFSET) = sync_reg | (0x1 << hart_id);
// }
