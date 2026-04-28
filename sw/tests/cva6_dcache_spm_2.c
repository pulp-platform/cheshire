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

#define N 1024
#define data_t uint64_t

volatile data_t *spm_data_1 = (volatile data_t *)(&__l1_dspm_base_addr__ + 0 * N * sizeof(data_t));
volatile data_t *spm_data_2 = (volatile data_t *)(&__l1_dspm_base_addr__ + 1 * N * sizeof(data_t));

data_t data_1[N];
data_t data_2[N];

void axpy(data_t a, data_t *x, data_t *y, data_t n) {
    for (data_t i = 0; i < n; i++) {
        y[i] += a * x[i];
    }
}

void init_data(data_t *data, data_t n, data_t seed) {
    data[0] = seed;
    for (data_t i = 1; i < n; i++) {
        data[i] = data[i - 1] * i;
    }
}

void enable_spm(uint32_t num_ways) {
    // Limit to maximum number of ways
    if (num_ways > DCACHE_NUM_WAYS) {
        num_ways = DCACHE_NUM_WAYS;
    }
    // Disable D-cache
    asm volatile("csrwi 0x7C1, 0");
    // Flush the D-cache
    asm volatile("fence");
    // Configure four ways as scratchpad
    uint32_t way_mask = (1 << num_ways) - 1;
    asm volatile("csrw 0x5E0, %0" : : "r"(way_mask));
    // Re-enable the D-cache
    asm volatile("csrwi 0x7C1, 1");
}

int main(void) {

    data_t result_cache, result_spm;

    init_data(data_1, N, 1);
    init_data(data_2, N, 2);

    axpy(11, data_1, data_2, N);

    // Enable SPM with 4 ways
    enable_spm(4);

    init_data(spm_data_1, N, 1);
    init_data(spm_data_2, N, 2);

    axpy(11, spm_data_1, spm_data_2, N);

    for (data_t i = 0; i < N; i++) {
        if (spm_data_2[i] != data_2[i]) {
            return i + 1; // Error: data mismatch
        }
    }

    return 0;
}
