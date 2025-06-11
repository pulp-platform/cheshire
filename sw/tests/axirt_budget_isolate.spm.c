// Copyright 2023 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Alessandro Ottaviano <aottaviano@iis.ee.ethz.ch>
//
// Validate the isolation functionality of AXI-REALM.

#include "axirt.h"
#include "dif/dma.h"
#include "params.h"
#include "regs/axi_rt.h"
#include "regs/cheshire.h"
#include "util.h"

#define CVA6_BASE_MGR_ID 0
#define CVA6_ALLOCATED_BUDGET 0x10000000
#define CVA6_ALLOCATED_PERIOD 0x10000000
#define DMA_NUM_BEATS 32 // We assume 64b AXI data width here
#define DMA_NUM_REPS 8
// Set DMA budget as half of the number of bytes to transfer.
// This is done intentionally to test isolation capabilities.
#define DMA_ALLOCATED_BUDGET (8 * DMA_NUM_BEATS * DMA_NUM_REPS / 2)
#define DMA_ALLOCATED_PERIOD 0x10000000
#define FRAGMENTATION_SIZE_BEATS 0 // Max fragmentation applied to bursts

int main(void) {
    // Immediately return an error if AXI_REALM or DMA are not present
    CHECK_ASSERT(-1, chs_hw_feature_present(CHESHIRE_HW_FEATURES_AXIRT_BIT));
    CHECK_ASSERT(-2, chs_hw_feature_present(CHESHIRE_HW_FEATURES_DMA_BIT));

    // This test requires at least two subordinate regions
    CHECK_ASSERT(-3, AXI_RT_PARAM_NUM_SUB >= 2);

    // Get internal hart count
    int num_int_harts = *reg32(&__base_regs, CHESHIRE_NUM_INT_HARTS_REG_OFFSET);

    // Allocate DMA buffers
    volatile uint64_t dma_src_cached[DMA_NUM_BEATS];
    volatile uint64_t dma_dst_cached[DMA_NUM_BEATS];

    // Use pointers to uncached buffers allocated in SPM
    volatile uint64_t *dma_src = dma_src_cached + (0x04000000 / sizeof(uint64_t));
    volatile uint64_t *dma_dst = dma_dst_cached + (0x04000000 / sizeof(uint64_t));

    // Enable and configure axi rt
    __axirt_claim(1, 1);
    __axirt_set_len_limit_group(FRAGMENTATION_SIZE_BEATS, 0);
    __axirt_set_len_limit_group(FRAGMENTATION_SIZE_BEATS, 1);
    fence();

    // Configure RT unit for all the CVA6 cores (adapt ID if needed).
    for (int id = CVA6_BASE_MGR_ID; id < num_int_harts; id++) {
        __axirt_set_region(0, 0xffffffff, 0, id);
        __axirt_set_region(0x100000000, 0xffffffffffffffff, 1, id);
        __axirt_set_budget(CVA6_ALLOCATED_BUDGET, 0, id);
        __axirt_set_budget(CVA6_ALLOCATED_BUDGET, 1, id);
        __axirt_set_period(CVA6_ALLOCATED_PERIOD, 0, id);
        __axirt_set_period(CVA6_ALLOCATED_PERIOD, 1, id);
        fence();
    }

    // Configure RT unit for the DMA
    int chs_dma_id = CVA6_BASE_MGR_ID + num_int_harts + 1;
    __axirt_set_region(0, 0xffffffff, 0, chs_dma_id);
    __axirt_set_region(0x100000000, 0xffffffffffffffff, 1, chs_dma_id);
    __axirt_set_budget(DMA_ALLOCATED_BUDGET, 0, chs_dma_id);
    __axirt_set_budget(DMA_ALLOCATED_BUDGET, 1, chs_dma_id);
    __axirt_set_period(DMA_ALLOCATED_PERIOD, 0, chs_dma_id);
    __axirt_set_period(DMA_ALLOCATED_PERIOD, 1, chs_dma_id);
    fence();

    // Enable RT unit for all the cores
    __axirt_enable(BIT_MASK(num_int_harts));

    // Enable RT unit for the DMA
    __axirt_enable(BIT(chs_dma_id));
    fence();

    // Initialize src region and golden values
    for (int i = 0; i < DMA_NUM_BEATS; i++) dma_src[i] = 0xcafedeadbaadf00dULL + i;

    // Wait for writes, then launch non-blocking DMA transfer
    fence();
    sys_dma_2d_memcpy((uintptr_t)(void *)dma_dst, (uintptr_t)(void *)dma_src,
                      sizeof(dma_src_cached), 0, 0, DMA_NUM_REPS, DMA_CONF_DECOUPLE_ALL);

    // Wait 5000 cycles for isolation to kick in
    uint64_t end_wait_cycles = get_mcycle() + 5000;
    while (end_wait_cycles > get_mcycle())
        ;

    // Check isolate to check if AXI-REALM isolates the dma when the budget is
    // exceeded. Should return 1 if dma is isolated.
    int isolate_status = (*reg32(&__base_axirt, AXI_RT_ISOLATED_REG_OFFSET) >> chs_dma_id) & 1;

    // Return 0 if manager was correctly isolated
    return !isolate_status;
}
