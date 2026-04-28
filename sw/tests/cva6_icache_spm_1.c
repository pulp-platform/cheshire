// Copyright 2023 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
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

#define data_t uint64_t

volatile data_t *spm_data = (volatile data_t *)&__l1_ispm_base_addr__;

int main(void) {

    // Disable I-cache
    asm volatile("csrwi 0x7C0, 0");
    // Configure all ways as scratchpad
    asm volatile("csrwi 0x5E1, 15");
    // Re-enable the I-cache
    asm volatile("csrwi 0x7C0, 1");

    for (unsigned int i = 0; i < (ICACHE_WAY_SIZE / sizeof(data_t)) * ICACHE_NUM_WAYS; i += 1) {
        spm_data[i] = i;
    }

    for (unsigned int i = 0; i < (ICACHE_WAY_SIZE / sizeof(data_t)) * ICACHE_NUM_WAYS; i += 1) {
        if (spm_data[i] != i) return i + 1;
    }

    return 0;
}
