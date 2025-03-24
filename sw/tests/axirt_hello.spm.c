// Copyright 2023 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Nicole Narr <narrn@student.ethz.ch>
// Christopher Reinwardt <creinwar@student.ethz.ch>
// Thomas Benz <tbenz@iis.ee.ethz.ch>
//
// Simple payload to test AXI-RT

#include "regs/cheshire.h"
#include "dif/clint.h"
#include "dif/uart.h"
#include "axirt.h"
#include "regs/axi_rt.h"
#include "params.h"
#include "util.h"

int main(void) {
    // Immediately return an error if AXI_REALM, DMA, or UART are not present
    CHECK_ASSERT(-1, chs_hw_feature_present(CHESHIRE_HW_FEATURES_AXIRT_BIT));
    CHECK_ASSERT(-2, chs_hw_feature_present(CHESHIRE_HW_FEATURES_DMA_BIT));
    CHECK_ASSERT(-3, chs_hw_feature_present(CHESHIRE_HW_FEATURES_UART_BIT));

    // This test requires at least two subordinate regions
    CHECK_ASSERT(-4, AXI_RT_PARAM_NUM_SUB >= 2);

    char str[] = "Hello AXI-RT!\r\n";
    uint32_t rtc_freq = *reg32(&__base_regs, CHESHIRE_RTC_FREQ_REG_OFFSET);
    uint64_t reset_freq = clint_get_core_freq(rtc_freq, 2500);

    // Enable and configure AXI REALM
    __axirt_claim(1, 1);
    __axirt_set_len_limit_group(2, 0);

    // Configure CVA6 core 0
    __axirt_set_region(0, 0xffffffff, 0, 0);
    __axirt_set_region(0x100000000, 0xffffffffffffffff, 1, 0);
    __axirt_set_budget(8, 0, 0);
    __axirt_set_budget(8, 1, 0);
    __axirt_set_period(100, 0, 0);
    __axirt_set_period(100, 1, 0);

    // Configure DMA
    int chs_dma_id = *reg32(&__base_regs, CHESHIRE_NUM_INT_HARTS_REG_OFFSET) + 1;
    __axirt_set_region(0, 0xffffffff, 0, chs_dma_id);
    __axirt_set_region(0x100000000, 0xffffffffffffffff, 1, chs_dma_id);
    __axirt_set_budget(0x10000000, 0, chs_dma_id);
    __axirt_set_budget(0x10000000, 1, chs_dma_id);
    __axirt_set_period(0x10000000, 0, chs_dma_id);
    __axirt_set_period(0x10000000, 1, chs_dma_id);

    // Enable RT unit for DMA and CVA6 core 0
    __axirt_enable(0x5);

    // Configure UART and write message
    uart_init(&__base_uart, reset_freq, __BOOT_BAUDRATE);
    uart_write_str(&__base_uart, str, sizeof(str) - 1);
    uart_write_flush(&__base_uart);
    return 0;
}
