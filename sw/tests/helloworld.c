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
#include "hal/spi_s25fs512s.h"
#include "params.h"
#include "util.h"

int main(void) {
    char str[] = "Hello World!\r\n";

    uint32_t rtc_freq = *reg32(&__base_regs, CHESHIRE_RTC_FREQ_REG_OFFSET);
    uint64_t core_freq = clint_get_core_freq(rtc_freq, 2500);

    spi_s25fs512s_t device = {
        .spi_freq = MIN(40 * 1000 * 1000, core_freq / 4), // Up to quarter core freq or 40MHz
        .csid = 1};
    uint32_t init = spi_s25fs512s_init(&device, core_freq);

    uint64_t len  = 0x1;
    uint64_t addr = 0x00F4FFF0;
    
    uint32_t read = spi_s25fs512s_single_read(&device, &__base_spm, addr, len);

    //uint64_t reset_freq = clint_get_core_freq(rtc_freq, 2500);
    uart_init(&__base_uart, core_freq, 115200);
    uart_write_str(&__base_uart, str, sizeof(str));
    uart_write_flush(&__base_uart);
    

    return 0;
}
