// Copyright 2023 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Nicole Narr <narrn@student.ethz.ch>
// Christopher Reinwardt <creinwar@student.ethz.ch>
// Paul Scheffler <paulsc@iis.ee.ethz.ch>

#include "regs/cheshire.h"
#include "dif/clint.h"
#include "params.h"
#include "util.h"
#include "dif/dma.h"

int main(void) {
    // Source and dst
    volatile uint64_t dma_src = 0x80000000;
    volatile uint64_t dma_dst = 0x80010000;

    volatile uint64_t mcycle_start = get_mcycle();
    volatile uint64_t mcycle_tot = get_mcycle() - mcycle_start;

    for (int i = 1; i <= 11; ++i) {
        fence();
        uint64_t len = 1 << i;
        uint64_t reps = 1024*1024 >> i;

        mcycle_start = get_mcycle();

        *((volatile uint32_t*)(void*)(uintptr_t)(0x010000d4)) = 1;

        sys_dma_2d_blk_memcpy(dma_dst, (uintptr_t)(void*)dma_src, len, 0,
                              0, reps, DMA_CONF_DECOUPLE_NONE);
        mcycle_tot = get_mcycle() - mcycle_start;
    }

    return 0;
}
