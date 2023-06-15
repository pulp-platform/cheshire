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
#include "regs/axi_llc.h"

int main(void) {

    // Configure LLC partitioning
    uint32_t *a = (0x03001054);
    *a = 0xa000;        // give pat0 size 0xa0
    a = (0x03001064);   // commit changes for llc
    *a = 1;

    // Configure
    a = (0x0300a044);   // set user signal to 1
    *a = 1;
    a = (0x0300a000);   // commit changes for tagger
    *a = 1;

    // Switch LLC into non-SPM mode
    a = (0x03001000);
    *a = 0;
    a = (0x03001010);
    *a = 1;

    char str[] = "Hello World!\r\n";
    uint32_t rtc_freq = *reg32(&__base_regs, CHESHIRE_RTC_FREQ_REG_OFFSET);
    uint64_t reset_freq = clint_get_core_freq(rtc_freq, 2500);
    uart_init(&__base_uart, reset_freq, 115200);
    uart_write_str(&__base_uart, str, sizeof(str));
    uart_write_flush(&__base_uart);
    return 0;
}
