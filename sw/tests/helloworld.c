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

char content[256];

int main(void) {
    char str[] = "Hello World!\r\n";

    //*reg32((void *)0x0300A000UL, 0x8) = 8;
    //*reg32((void *)0x0300A000UL, 0xc) = 2;
    //*reg32((void *)0x0300A000UL, 0x10) = 6;

    for (int i = 1; i < 256; i+=4) {
        *reg32((void *)0, (int)&content[i]) = i;
    }
    fence();
    for (int i = 1; i < 256; i+=4) {
        int j = *reg32((void *)0x400000000UL, (int)&content[i]);
        if (i != j) return i;
    }
    uint32_t rtc_freq = *reg32(&__base_regs, CHESHIRE_RTC_FREQ_REG_OFFSET);
    uint64_t reset_freq = clint_get_core_freq(rtc_freq, 2500);
    uart_init(&__base_uart, reset_freq, __BOOT_BAUDRATE);
    uart_write_str(&__base_uart, str, sizeof(str));
    uart_write_flush(&__base_uart);
    return 0;
}
