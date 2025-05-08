// Copyright 2023 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Nicole Narr <narrn@student.ethz.ch>
// Christopher Reinwardt <creinwar@student.ethz.ch>
// Paul Scheffler <paulsc@iis.ee.ethz.ch>

#include "regs/cheshire.h"
#include "dif/clint.h"
#include "dif/uart.h"
#include "params.h"
#include "util.h"
#include "printf.h"

int main(void) {
    uint32_t rtc_freq = *reg32(&__base_regs, CHESHIRE_RTC_FREQ_REG_OFFSET);
    uint64_t reset_freq = clint_get_core_freq(rtc_freq, 2500);
    uart_init(&__base_uart, reset_freq, __BOOT_BAUDRATE);


    printf("Hello Link!\r\n");

    void* local_dram = (void*)(uintptr_t)0x80000000;
    void* remote_dram = (void*)(uintptr_t)0x180000000;


    volatile uint32_t *local_num = (uint32_t *)local_dram;
    volatile uint32_t *remote_num = (uint32_t *)remote_dram;


    fence();
    *remote_num = 0xBAADCAFE;
    fence();

    while (*local_num != 0xBAADCAFE);

    printf("SYNC SUCCEEDED!");

    uart_write_flush(&__base_uart);
    return 0;
}
