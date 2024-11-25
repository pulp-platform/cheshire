// Copyright 2023 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Nicole Narr <narrn@student.ethz.ch>
// Christopher Reinwardt <creinwar@student.ethz.ch>
//
// Simple payload to test bootmodes

#include "regs/cheshire.h"
#include "dif/clint.h"
#include "dif/uart.h"
#include "params.h"
#include "util.h"
#include <stdio.h>
#include <stdint.h>

#define HYPERRAM_START_ADDRESS 0x80000000
#define HYPERRAM_END_ADDRESS 0x81000000
#define HYPERRAM_STEP_SIZE 32

int main(void) {
    __asm volatile("csrrwi x0, 0x7C1, 0\n");

    char test_finish_msg[] = "RAM test finished\r\n";
    char test_start_msg[] = "Starting RAM test\r\n";
    char value_msg[64];
    char test_msg[64];

    uint32_t rtc_freq = *reg32(&__base_regs, CHESHIRE_RTC_FREQ_REG_OFFSET);
    uint64_t reset_freq = clint_get_core_freq(rtc_freq, 2500);
    uart_init(&__base_uart, reset_freq, __BOOT_BAUDRATE);

    uart_write_str(&__base_uart, test_start_msg, sizeof(test_start_msg));
    uart_write_flush(&__base_uart);



    uart_write_str(&__base_uart, test_finish_msg, sizeof(test_finish_msg));
    uart_write_flush(&__base_uart);
    return 0;
}
