// Copyright 2024 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Paul Scheffler <paulsc@iis.ee.ethz.ch>
//
// Simple 1D test for iDMA accessing a remote memory over the serial link.
// This is intended *only for execution from SPM*.

#include "util.h"
#include "dif/clint.h"
#include "dif/dma.h"

int main(void) {
    // Immediately return an error if DMA or Serial Link are not present
    CHECK_ASSERT(-1, chs_hw_feature_present(CHESHIRE_HW_FEATURES_DMA_BIT));
    CHECK_ASSERT(-2, chs_hw_feature_present(CHESHIRE_HW_FEATURES_SERIAL_LINK_BIT));

    volatile char src_cached[] = "This is a DMA test";
    volatile char gold[] = "This is a DMA test!";

    // Allocate destination memory in SPM
    volatile char dst_cached[sizeof(gold)];

    // Get pointer to uncached SPM destination
    volatile char *dst = dst_cached + 0x04000000;

    // Remote pointer to other device on serial link (assume Cheshire-like, with SPM)
    volatile char *rem = dst + 0x100000000;

    // Copy from cached source to uncached remote using core
    for (unsigned i = 0; i < sizeof(src_cached); ++i) rem[i] = src_cached[i];

    // Pre-write finishing "!\0" to guard against overlength transfers
    dst[sizeof(gold) - 2] = '!';
    dst[sizeof(gold) - 1] = '\0';

    // Issue blocking memcpy from rem to dst (exclude null terminator from source)
    sys_dma_blk_memcpy((uintptr_t)(void *)dst, (uintptr_t)(void *)rem, sizeof(src_cached) - 1,
                       DMA_CONF_DECOUPLE_NONE);

    // Check destination string
    int errors = sizeof(gold);
    for (unsigned i = 0; i < sizeof(gold); ++i) errors -= (dst[i] == gold[i]);

    return errors;
}
