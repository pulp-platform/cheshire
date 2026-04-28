// Copyright 2023 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Christopher Reinwardt <creinwar@iis.ee.ethz.ch>
// Enrico Zelioli <ezelioli@iis.ee.ethz.ch>

#include <stdint.h>
#include <stdint.h>
#include "regs/cheshire.h"
#include "dif/clint.h"
#include "dif/uart.h"
#include "params.h"
#include "util.h"

#define ICACHE_SIZE 16384UL
#define ICACHE_NUM_WAYS 4
#define ICACHE_WAY_SIZE ((ICACHE_SIZE) / (ICACHE_NUM_WAYS))

uint64_t __attribute__((noinline)) __attribute__((aligned(8))) spm_func(uint64_t a, uint64_t b) {
    uint64_t tmp = 1;
    for (unsigned int i = 0; i < 100; i++) {
        tmp = tmp * a * b;
    }
    return tmp;
}

int main(void) {

    uint64_t res_cache, res_spm;
    volatile uint64_t *src;
    volatile uint64_t *dst;

    // Disable I-cache
    asm volatile("csrwi 0x7C0, 0");
    // Configure two ways as scratchpad
    asm volatile("csrwi 0x5E1, 3");
    // Re-enable the I-cache
    asm volatile("csrwi 0x7C0, 1");

    src = (volatile uint64_t *)(spm_func);
    dst = (volatile uint64_t *)&__l1_ispm_base_addr__;

    // Copy the payload function (128 bytes) to the icache spm
    for (unsigned int i = 0; i < 16; i++) {
        *dst++ = *src++;
    }

    __asm volatile("fence.i\n" :::);

    uint64_t (*f)(uint64_t, uint64_t) = (uint64_t(*)(uint64_t, uint64_t)) & __l1_ispm_base_addr__;

    dst--;
    res_spm = f(*src, *dst);
    res_cache = spm_func(*src, *dst);

    if (res_cache != res_spm) return res_cache - res_spm;

    return 0;
}
