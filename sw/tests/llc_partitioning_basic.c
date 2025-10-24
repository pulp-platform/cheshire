// Copyright 2025 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Robert Balas <balasr@iis.ee.ethz.ch>
// Enrico Zelioli <ezelioli@iis.ee.ethz.ch>

// Basic testing of the cache partitioning's configuration registers

#include <stdint.h>
#include "dif/clint.h"
#include "dif/uart.h"
#include "params.h"
#include "regs/cheshire.h"
#include "regs/axi_llc.h"
#include "util.h"
#include "printf.h"

static int probe_rw(void *base, int offs, uint32_t val) {
    *(volatile uint32_t *)((uint8_t *)base + offs) = val;
    uint32_t ret = *reg32(base, offs);
    return !(ret == val);
}

#define LLC_RW_TEST_REG(NAME, VAL) \
    err = probe_rw(&__base_llc, NAME, VAL); \
    if (err) { \
        printf("error: rw " #NAME "\n"); \
        uart_write_flush(&__base_uart); \
        return 1; \
    }

int main(void) {
    int err = 0;

    // Init UART
    uint32_t rtc_freq = *reg32(&__base_regs, CHESHIRE_RTC_FREQ_REG_OFFSET);
    uint64_t reset_freq = clint_get_core_freq(rtc_freq, 2500);
    uart_init(&__base_uart, reset_freq, 115200);

    // Read LLC version register
    uint32_t low = *reg32(&__base_llc, AXI_LLC_VERSION_LOW_REG_OFFSET);
    uint32_t high = *reg32(&__base_llc, AXI_LLC_VERSION_HIGH_REG_OFFSET);
    uint64_t version = ((uint64_t)high << 32) | ((uint64_t)low);

    // Run basic register rw tests
    LLC_RW_TEST_REG(AXI_LLC_CFG_FLUSH_PARTITION_LOW_REG_OFFSET, 0xcafedead);
    LLC_RW_TEST_REG(AXI_LLC_CFG_FLUSH_PARTITION_HIGH_REG_OFFSET, 0xcafedead);

    LLC_RW_TEST_REG(AXI_LLC_CFG_SET_PARTITION_LOW_0_REG_OFFSET, 0xdefec8ed);
    LLC_RW_TEST_REG(AXI_LLC_CFG_SET_PARTITION_LOW_1_REG_OFFSET, 0xdefec8ed);

    LLC_RW_TEST_REG(AXI_LLC_CFG_SET_PARTITION_HIGH_0_REG_OFFSET, 0xdeadc0de);
    LLC_RW_TEST_REG(AXI_LLC_CFG_SET_PARTITION_HIGH_1_REG_OFFSET, 0xdeadc0de);

    printf("llc ver = 0x%016X\n", version);
    uart_write_flush(&__base_uart);

    return 0;
}
