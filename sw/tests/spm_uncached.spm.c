// Copyright 2025 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Paul Scheffler <paulsc@iis.ee.ethz.ch>
//
// Simple test to check that execution from uncached SPM is possible and indeed uncached.

#include "dif/dma.h"
#include "regs/cheshire.h"
#include "util.h"

typedef void (*fptr)(volatile int *volatile);

void __attribute__((aligned(64))) __attribute__((visibility("hidden"))) __attribute__((noinline))
payload1(volatile int *volatile ret) {
    *ret = 1;
}

void __attribute__((aligned(64))) __attribute__((visibility("hidden"))) __attribute__((noinline))
payload2(volatile int *volatile ret) {
    *ret = 2;
}

int main(void) {
    // Immediately return an error if DMA is not present
    CHECK_ASSERT(-1, chs_hw_feature_present(CHESHIRE_HW_FEATURES_DMA_BIT));

    // Execute payload1; this should cache it.
    volatile int outcome1;
    payload1(&outcome1);

    // Copy payload2 to payload1 using the DMA, overwriting it.
    sys_dma_blk_memcpy((uintptr_t)(void *)(&payload1), (uintptr_t)(void *)(&payload2), 64,
                       DMA_CONF_DECOUPLE_ALL);

    // Execute payload1 again from uncached SPM.
    // Since this region is uncached, the DMA-overwritten code should run and 2 should be returned.
    fptr payload1_unc = (void *)(&payload1) + 0x04000000;
    volatile int outcome2;
    payload1_unc(&outcome2);

    // Check that the outcomes were as expected.
    return (outcome1 + outcome2 != 3);
}
