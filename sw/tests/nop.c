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
    uint64_t cycle_start, cycle_end, cycles;
    // Warm up caches
    for (int i = 0; i < 10; i++) {
      cycle_start = get_mcycle();
      for (int i = 0; i < 100; i++) asm("nop");
      cycle_end = get_mcycle();
    }
    cycles = cycle_end - cycle_start;
    printf("Counted %d\n", cycles);
    return 0;
}
