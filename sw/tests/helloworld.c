// Copyright 2023 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Nicole Narr <narrn@student.ethz.ch>
// Christopher Reinwardt <creinwar@student.ethz.ch>
//
// Simple payload to test bootmodes

#include "printf.h"
#include "dif/uart.h"
#include "params.h"
#include "util.h"
#include "dif/clint.h"

int main(void) {
    uint64_t reset_freq = 200*1000*1000;
    uart_init(&__base_uart, reset_freq, 115200);
    printf("Hello World!\r\n");
    uart_write_flush(&__base_uart);
    return 0;
}
