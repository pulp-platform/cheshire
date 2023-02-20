// Copyright 2022 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Nicole Narr <narrn@student.ethz.ch>
// Christopher Reinwardt <creinwar@student.ethz.ch>
// Paul Scheffler <paulsc@iis.ee.ethz.ch>

#include <stdint.h>

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

// This may also be used to invoke code that does not return.
static inline uint64_t invoke(void *code) {
    uint64_t (*code_fun_ptr)(void) = code;
    fencei();
    return code_fun_ptr();
}

// If a call yields an unexpected return, call `_exit` procedure with error code
// clang-format off
#define CHECK_ELSE_EXIT_ERRCODE -3
#define CHECK_ELSE_EXIT(exp, call) \
    if ((call) != (exp)) \
        asm volatile("li a0, %[errcode]; j _exit" :: \
            [errcode]"i"(CHECK_ELSE_EXIT_ERRCODE) : "a0");
// clang-format on

#define MIN(a, b) ((a <= b) ? a : b)
