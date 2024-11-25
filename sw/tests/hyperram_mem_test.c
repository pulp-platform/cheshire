// Copyright 2023 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Nicole Narr <narrn@student.ethz.ch>
// Christopher Reinwardt <creinwar@student.ethz.ch>

#include "regs/cheshire.h"
#include "dif/clint.h"
#include "dif/uart.h"
#include "params.h"
#include "util.h"
#include <stdio.h>
#include <stdint.h>

#define HYPERRAM_START_ADDRESS 0x80000000
#define HYPERRAM_END_ADDRESS 0x81000000
#define HYPERRAM_NUM_ADDRESSES 256
#define HYPERRAM_STEP_SIZE 4

int main(void) {
    __asm volatile("csrrwi x0, 0x7C1, 0\n");

    char start_msg[] = "Starting RAM test\r\n";
    char reset_msg[] = "Gesamter RAM auf '-1' gesetzt\r\n";
    char write_msg[] = "Gesamter RAM beschrieben\r\n";
    char finish_msg[] = "RAM test finished\r\n";
    char value_msg[64];
    char msg[64];

    uint32_t rtc_freq = *reg32(&__base_regs, CHESHIRE_RTC_FREQ_REG_OFFSET);
    uint64_t reset_freq = clint_get_core_freq(rtc_freq, 2500);
    uart_init(&__base_uart, reset_freq, __BOOT_BAUDRATE);

    uart_write_str(&__base_uart, start_msg, sizeof(start_msg));
    uart_write_flush(&__base_uart);

    // Address Map auf -1 setzen
    for (uint32_t addr = HYPERRAM_START_ADDRESS + HYPERRAM_STEP_SIZE; addr < HYPERRAM_END_ADDRESS; addr += HYPERRAM_STEP_SIZE) {
        *(volatile uint32_t*)addr = (uint32_t)-1;
    }

    uart_write_str(&__base_uart, reset_msg, sizeof(reset_msg));
    uart_write_flush(&__base_uart);

    for (uint32_t addr = HYPERRAM_START_ADDRESS; addr < HYPERRAM_END_ADDRESS; addr += HYPERRAM_STEP_SIZE) {
        volatile uint32_t value = *(volatile uint32_t*)addr;
        if (value != (uint32_t)-1) {
            snprintf(msg, sizeof(msg), 
                     "ERROR - Adresse: 0x%08X, Value: %u, Expected: -1\r\n", 
                     addr, value);
            uart_write_str(&__base_uart, msg, sizeof(msg));
            uart_write_flush(&__base_uart);
        }

        *(volatile uint32_t*)addr = (addr - HYPERRAM_START_ADDRESS) / HYPERRAM_STEP_SIZE;
    }

    uart_write_str(&__base_uart, write_msg, sizeof(write_msg));
    uart_write_flush(&__base_uart);

    for (uint32_t addr = HYPERRAM_START_ADDRESS; addr < HYPERRAM_END_ADDRESS; addr += HYPERRAM_STEP_SIZE) {
        volatile uint32_t read_value = *(volatile uint32_t*)addr;
        uint32_t expected_value = (addr - HYPERRAM_START_ADDRESS) / HYPERRAM_STEP_SIZE;

        if (expected_value != read_value)
        {
            snprintf(value_msg, sizeof(value_msg), 
                    "Adresse: 0x%08X, Written Value: %u, Received Value: %u\r\n", 
                    addr, expected_value, read_value);

            uart_write_str(&__base_uart, value_msg, sizeof(value_msg));
            uart_write_flush(&__base_uart);
        }
    }

    uart_write_str(&__base_uart, finish_msg, sizeof(finish_msg));
    uart_write_flush(&__base_uart);
    return 0;
}
