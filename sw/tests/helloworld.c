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
#include "printf.h"

int main(void) {
    uint32_t NumHarts = *reg32(&__base_regs, CHESHIRE_NUM_INT_HARTS_REG_OFFSET);
    uint32_t OtherHart = NumHarts - 1 - hart_id(); // If hart_id() == 0 -> return 1;
                                                   // If hart_id() == 1 -> return 0;
    // Hart 0 enters first
    if (hart_id() != 0) wfi();

    printf("Hi [%d]!\n", hart_id());

    wakeup_hart(OtherHart);

    wfi();

    // Only core 0 exits.
    return 0;
}
