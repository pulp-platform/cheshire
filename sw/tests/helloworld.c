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
#include "regs/cheshire.h"
#include "params.h"
#include "util.h"
#include "dif/clint.h"

extern void *__base_cheshire_regs;

char uart_initialized = 0;

int main(void) {

    return 0;
}
