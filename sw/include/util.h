// Copyright 2022 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Nicole Narr <narrn@student.ethz.ch>
// Christopher Reinwardt <creinwar@student.ethz.ch>
// Paul Scheffler <paulsc@iis.ee.ethz.ch>
// Alessandro Ottaviano <aottaviano@iis.ee.ethz.ch>

#pragma once

#include <stdint.h>
#include "regs/cheshire.h"
#include "params.h"

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

// Enables or disables M-mode timer interrupts.
static inline void set_mtie(int enable) {
    if (enable)
        asm volatile("csrs mie, %0" ::"r"(128) : "memory");
    else
        asm volatile("csrc mie, %0" ::"r"(128) : "memory");
}

// Enables or disables M-mode global interrupts.
static inline void set_mie(int enable) {
    if (enable)
        asm volatile("csrsi mstatus, 8" ::: "memory");
    else
        asm volatile("csrci mstatus, 8" ::: "memory");
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

// If a condition; if it is untrue, immediately return an error code.
#define CHECK_ASSERT(ret, cond) \
    if (!(cond)) return (ret);

#define MIN(a, b) (((a) <= (b)) ? (a) : (b))

// Bit manipulation
#define BIT(n) (1UL << (n))
#define BIT_MASK(n) (BIT(n) - 1)

// Check if an hardware feature is present from software
static inline uint32_t hw_feature_present(uint32_t bit) {
    uint32_t features_bitmap = *reg32(&__base_regs, CHESHIRE_HW_FEATURES_REG_OFFSET);
    return (features_bitmap & (1 << bit)) != 0;
}

// Helpers to handle Cheshire AXI managers attached to the system crossbar.

// Cheshire managers. We label only core0 as the other cores - if any - are
// contiguous after it by default.
enum chs_mngrs {
    CHS_MNGR_CORE0 = 0,
    CHS_MNGR_DEBUG,
    CHS_MNGR_DMA,
    CHS_MNGR_SERIAL_LINK,
    CHS_MNGR_VGA,
    CHS_MNGR_USB
};

// Get Cheshire manager ID based on the hardware feature. If an hardware feature
// is not implemented, returns `IMPL_ERR`.
static inline uint32_t get_chs_mngr_id_from_hw_feature(enum chs_mngrs feature) {
    uint32_t num_harts = *reg32(&__base_regs, CHESHIRE_NUM_INT_HARTS_REG_OFFSET);
    uint32_t current_id = num_harts;

    // Determine ID based on the input feature
    switch (feature) {
    case CHS_MNGR_CORE0:
        return 0; // Core 0 ID is always 0
        break;
    case CHS_MNGR_DEBUG:
        return num_harts; // Debug ID is always after cores
        break;
    case CHS_MNGR_DMA:
        return hw_feature_present(CHESHIRE_HW_FEATURES_DMA_BIT) ? ++current_id : HW_IMPL_ERR;
        break;
    case CHS_MNGR_SERIAL_LINK:
        return hw_feature_present(CHESHIRE_HW_FEATURES_SERIAL_LINK_BIT) ? ++current_id
                                                                        : HW_IMPL_ERR;
        break;
    case CHS_MNGR_VGA:
        return hw_feature_present(CHESHIRE_HW_FEATURES_VGA_BIT) ? ++current_id : HW_IMPL_ERR;
        break;
    case CHS_MNGR_USB:
        return hw_feature_present(CHESHIRE_HW_FEATURES_USB_BIT) ? ++current_id : HW_IMPL_ERR;
        break;
    default:
        return HW_IMPL_ERR; // Unknown feature
    }
}
