// Copyright 2026 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Workload for activity-based power analysis: an integer and a double-precision
// matrix multiplication, then an idle phase (the core waits for a timer in WFI).
// Each phase is marked on the GPIO outputs (bit 0: a phase runs, bits 3:1: which),
// so that simulation scripts can record activity per phase. Each product is
// checked: the sum of its elements must equal the sum over k of the k-th column
// sum of A times the k-th row sum of B. Returns 0 if both products are correct.

#include <stdint.h>
#include "dif/clint.h"
#include "params.h"
#include "util.h"

#ifndef MATMUL_N
#define MATMUL_N 16
#endif
#ifndef MATMUL_IDLE_TICKS
#define MATMUL_IDLE_TICKS 2
#endif

#define N MATMUL_N

// OpenTitan GPIO: direct output and output enable registers
#define GPIO_DIRECT_OUT 0x14
#define GPIO_DIRECT_OE 0x20

enum phase { PHASE_NONE = 0x0, PHASE_INT = 0x3, PHASE_FP = 0x5, PHASE_IDLE = 0x7 };

static void mark(enum phase p) {
    fence();
    *reg32(&__gpio_base_addr__, GPIO_DIRECT_OUT) = p;
    fence();
}

static int32_t ai[N][N], bi[N][N], ci[N][N];
static double af[N][N], bf[N][N], cf[N][N];

static void matmul_int(void) {
    for (int i = 0; i < N; ++i)
        for (int j = 0; j < N; ++j) {
            int32_t acc = 0;
            for (int k = 0; k < N; ++k) acc += ai[i][k] * bi[k][j];
            ci[i][j] = acc;
        }
}

static void matmul_fp(void) {
    for (int i = 0; i < N; ++i)
        for (int j = 0; j < N; ++j) {
            double acc = 0.0;
            for (int k = 0; k < N; ++k) acc += af[i][k] * bf[k][j];
            cf[i][j] = acc;
        }
}

// Sum of all elements of A*B, from the column sums of A and the row sums of B
static int64_t expected_int(void) {
    int64_t sum = 0;
    for (int k = 0; k < N; ++k) {
        int64_t col = 0, row = 0;
        for (int i = 0; i < N; ++i) col += ai[i][k];
        for (int j = 0; j < N; ++j) row += bi[k][j];
        sum += col * row;
    }
    return sum;
}

static double expected_fp(void) {
    double sum = 0.0;
    for (int k = 0; k < N; ++k) {
        double col = 0.0, row = 0.0;
        for (int i = 0; i < N; ++i) col += af[i][k];
        for (int j = 0; j < N; ++j) row += bf[k][j];
        sum += col * row;
    }
    return sum;
}

// Wait in WFI for `ticks` of the real-time clock: the timer interrupt is enabled
// but global interrupts are not, so WFI resumes here without taking a trap
static void idle(uint64_t ticks) {
    uint64_t tgt = clint_get_mtime() + ticks;
    clint_set_mtimecmpx(0, tgt);
    set_mie(0);
    set_mtie(1);
    while (clint_get_mtime() < tgt) wfi();
    set_mtie(0);
    clint_set_mtimecmpx(0, UINT64_MAX);
}

int main(void) {
    // Small integer values: the double-precision products are exact
    for (int i = 0; i < N; ++i)
        for (int j = 0; j < N; ++j) {
            ai[i][j] = (i * 7 + j * 3) % 13 - 6;
            bi[i][j] = (i * 5 + j * 11) % 17 - 8;
            af[i][j] = (double)((i * 3 + j * 5) % 11 - 5);
            bf[i][j] = (double)((i * 13 + j * 7) % 9 - 4);
        }
    *reg32(&__gpio_base_addr__, GPIO_DIRECT_OE) = 0xf;

    mark(PHASE_INT);
    matmul_int();
    mark(PHASE_NONE);

    mark(PHASE_FP);
    matmul_fp();
    mark(PHASE_NONE);

    mark(PHASE_IDLE);
    idle(MATMUL_IDLE_TICKS);
    mark(PHASE_NONE);

    int64_t sum_int = 0;
    double sum_fp = 0.0;
    for (int i = 0; i < N; ++i)
        for (int j = 0; j < N; ++j) {
            sum_int += ci[i][j];
            sum_fp += cf[i][j];
        }
    int err = (sum_int != expected_int()) | ((sum_fp != expected_fp()) << 1);
    return err;
}
