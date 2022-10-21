// Copyright 2020 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51

#pragma once

#define STATIC_INLINE static inline __attribute__((always_inline))

#define CONST __attribute__((const))

#define OPT_O3 __attribute__((optimize("03")))

#define CHECK_ELSE_TRAP(call, code) if ((call) != (code)) printf_("Trap! Expected 0x%lx but got 0x%lx\r\n", (code), (call));

STATIC_INLINE void execute_void(void* code) {
    asm volatile("fence.i" ::: "memory");
    void (*code_fun_ptr)(void) = code;
    code_fun_ptr();
}
