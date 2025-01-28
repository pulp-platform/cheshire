// Copyright 2025 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Nils Wistoff <nwistoff@iis.ee.ethz.ch>
//
// Simple bare-metal timing channel exploiting the round-robin arbiter's state of
// Cheshire's AXI Xbar.

#include "regs/cheshire.h"
#include "dif/clint.h"
#include "dif/uart.h"
#include "params.h"
#include "util.h"
#include "smp.h"
#include "printf.h"
#include <stdlib.h>

#define N_ITERATIONS 200

extern void pad(uint64_t cycles);

uint8_t secret[N_ITERATIONS];
uint64_t time[N_ITERATIONS];

uint64_t sync(uint64_t cycle) {
    uint64_t now;
    uint64_t sync_time;

    // Synchronise. Use mcycle instead of an AMO barrier to increase accuracy.
    now = get_mcycle();
    sync_time = ((now + cycle - 1) / cycle) * cycle;
    pad(sync_time - now);
    return sync_time;
}

int main(void) {

    uint64_t hart_id = get_mhartid();
    uint32_t num_harts = *reg32(&__base_regs, CHESHIRE_NUM_INT_HARTS_REG_OFFSET);
    uint64_t probe_start;

    // Initialize secret vector and UART
    if (hart_id == 0) {
        for (uint64_t i = 0; i < N_ITERATIONS; i++) {
            secret[i] = rand() % num_harts;
        }
        fence();
        uint32_t rtc_freq = *reg32(&__base_regs, CHESHIRE_RTC_FREQ_REG_OFFSET);
        uint64_t reset_freq = clint_get_core_freq(rtc_freq, 2500);
        uart_init(&__base_uart, reset_freq, __BOOT_BAUDRATE);
        smp_barrier_init();
        smp_resume();
    }

    // Synchronize cores
    while (get_mcycle() < 350000);

    // Prime&Probe
    for (uint64_t i = 0; i < N_ITERATIONS; i++) {
        // Encode secret
        if (secret[i] == hart_id) {
            uart_read_ready(&__base_uart);
        }

        // Probe
        probe_start = sync(500);
        uart_read_ready(&__base_uart);
        if (hart_id == 0) {
            time[i] = get_mcycle() - probe_start;
        }
    }

    // Print results
    if (hart_id == 0) {
        for (uint64_t i = 0; i < N_ITERATIONS; i++) {
            printf("%lu,%lu\n", secret[i], time[i]);
        }
    }

    smp_barrier_down();

    return 0;
}
