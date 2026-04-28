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

#define DCACHE_SIZE 32768UL
#define DCACHE_NUM_WAYS 8
#define DCACHE_WAY_SIZE ((DCACHE_SIZE) / (DCACHE_NUM_WAYS))

#define data_t uint64_t

volatile data_t *spm_data = (volatile data_t *)&__l1_dspm_base_addr__;

int main(void) {

    // Disable D-cache
    asm volatile("csrwi 0x7C1, 0");
    // Flush the D-cache
    asm volatile("fence");
    // Configure all ways as scratchpad
    uint32_t way_mask = (1 << DCACHE_NUM_WAYS) - 1;
    asm volatile("csrw 0x5E0, %0" : : "r"(way_mask));
    // Re-enable the D-cache
    asm volatile("csrwi 0x7C1, 1");

    for (unsigned int i = 0; i < (DCACHE_WAY_SIZE / sizeof(data_t)) * DCACHE_NUM_WAYS; i += 1) {
        spm_data[i] = i;
    }

    for (unsigned int i = 0; i < (DCACHE_WAY_SIZE / sizeof(data_t)) * DCACHE_NUM_WAYS; i += 1) {
        if (spm_data[i] != i) return i + 1;
    }

    return 0;
}
