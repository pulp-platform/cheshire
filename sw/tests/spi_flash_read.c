// Copyright 2023 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Yann Picod <ypicod@ethz.ch>
//
// Simple read to test the SPI Flash

#include "regs/cheshire.h"
#include "dif/clint.h"
#include "dif/uart.h"
#include "hal/spi_s25fs512s.h"
#include "params.h"
#include "util.h"
#include "printf.h"

int main(void) {
    char start[] = "Hello World!\r\n";
    uint32_t rtc_freq = *reg32(&__base_regs, CHESHIRE_RTC_FREQ_REG_OFFSET);
    uint64_t core_freq = clint_get_core_freq(rtc_freq, 2500);
    uint64_t reset_freq = clint_get_core_freq(rtc_freq, 2500);
    uart_init(&__base_uart, reset_freq, 115200);
    uart_write_str(&__base_uart, start, sizeof(start));
    uart_write_flush(&__base_uart);

    spi_s25fs512s_t device = {
        .spi_freq = MIN(40 * 1000 * 1000, core_freq / 4), // Up to quarter core freq or 40MHz
        .csid = 1};

    spi_s25fs512s_init(&device, core_freq);

    uint32_t err;
    uint64_t len = 0x16;
    uint64_t addr_init = 0x00000000;
    uint8_t  c = 2;
    uint8_t  l = 32;

    uint8_t buf[128];

    for(uint64_t addr=addr_init; addr<(addr_init+(c*l)); addr+=c) {
        err = spi_s25fs512s_single_read(&device, buf, addr, len);
        printf("err=%u, addr=%08x : ", err, addr);
        for(uint64_t i=0; i<(c); i+=2) {
            printf("%02X%02X ", buf[i], buf[i+1]);
        }
        printf("\r\n");
    }

    char str_end[] = "\nEnd of test\r\n";
    uart_write_str(&__base_uart, str_end, sizeof(str_end));
    uart_write_flush(&__base_uart);

    return 0;
}