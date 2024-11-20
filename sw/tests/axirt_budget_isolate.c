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

// Transfer
#define SIZE_BEAT_BYTES 8
#define DMA_NUM_BEATS 32
#define DMA_NUM_REPS 8
#define DMA_SIZE_BYTES (SIZE_BEAT_BYTES * DMA_NUM_BEATS)
#define DMA_TOTAL_SIZE_BYTES (DMA_SIZE_BYTES * DMA_NUM_REPS)
#define DMA_SRC_STRIDE 0
#define DMA_DST_STRIDE 0
#define DMA_SRC_ADDRESS 0x10008000
#define DMA_DST_ADDRESS 0x80008000

// AXI-REALM (IDs assume default config; adapt as needed)
#define CVA6_BASE_MGR_ID 0
#define CVA6_ALLOCATED_BUDGET 0x10000000
#define CVA6_ALLOCATED_PERIOD 0x10000000
#define DMA_ALLOCATED_BUDGET \
    (DMA_TOTAL_SIZE_BYTES / 2) // Set budget as half of the number of bytes to
                               // transfer. This is done intentionally to test
                               // isolation capabilities.
#define DMA_ALLOCATED_PERIOD 0x10000000
#define FRAGMENTATION_SIZE_BEATS 0 // Max fragmentation applied to bursts

int main(void) {

    // Immediately return an error if DMA is not present in cheshire
    CHECK_ASSERT(-1, !chs_hw_feature_present(CHESHIRE_HW_FEATURES_DMA_BIT));

    uint32_t cheshire_num_harts = *reg32(&__base_regs, CHESHIRE_NUM_INT_HARTS_REG_OFFSET);

    volatile uint64_t *dma_src = (volatile uint64_t *)(DMA_SRC_ADDRESS);
    volatile uint64_t *dma_dst = (volatile uint64_t *)(DMA_DST_ADDRESS);

    // Enable and configure axi rt
    __axirt_claim(1, 1);
    __axirt_set_len_limit_group(FRAGMENTATION_SIZE_BEATS, 0);
    __axirt_set_len_limit_group(FRAGMENTATION_SIZE_BEATS, 1);
    fence();

    // Configure RT unit for all the CVA6 cores (adapt ID if needed).
    for (uint32_t id = CVA6_BASE_MGR_ID; id < cheshire_num_harts; id++) {
        __axirt_set_region(0, 0xffffffff, 0, id);
        __axirt_set_region(0x100000000, 0xffffffffffffffff, 1, id);
        __axirt_set_budget(CVA6_ALLOCATED_BUDGET, 0, id);
        __axirt_set_budget(CVA6_ALLOCATED_BUDGET, 1, id);
        __axirt_set_period(CVA6_ALLOCATED_PERIOD, 0, id);
        __axirt_set_period(CVA6_ALLOCATED_PERIOD, 1, id);
        fence();
    }

    // Configure RT unit for the DMA
    uint32_t chs_dma_id = CVA6_BASE_MGR_ID + cheshire_num_harts + 1;

    __axirt_set_region(0, 0xffffffff, 0, chs_dma_id);
    __axirt_set_region(0x100000000, 0xffffffffffffffff, 1, chs_dma_id);
    __axirt_set_budget(DMA_ALLOCATED_BUDGET, 0, chs_dma_id);
    __axirt_set_budget(DMA_ALLOCATED_BUDGET, 1, chs_dma_id);
    __axirt_set_period(DMA_ALLOCATED_PERIOD, 0, chs_dma_id);
    __axirt_set_period(DMA_ALLOCATED_PERIOD, 1, chs_dma_id);
    fence();

    // Enable RT unit for all the cores
    __axirt_enable(BIT_MASK(cheshire_num_harts));

    // Enable RT unit for the DMA
    __axirt_enable(BIT(chs_dma_id));
    fence();

    // Initialize src region and golden values
    for (int i = 0; i < DMA_NUM_BEATS; i++) {
        dma_src[i] = 0xcafedeadbaadf00dULL + i;
        fence();
    }

    // Launch blocking DMA transfer
    sys_dma_2d_blk_memcpy((uint64_t *)dma_dst, (uint64_t *)dma_src, DMA_SIZE_BYTES, DMA_DST_STRIDE,
                          DMA_SRC_STRIDE, DMA_NUM_REPS);

    // Poll isolate to check if AXI-REALM isolates the dma when the budget is
    // exceeded. Should return 1 if dma is isolated.
    uint8_t isolate_status = __axirt_poll_isolate(chs_dma_id);

    // Return 0 if manager was correctly isolated
    return !isolate_status;
}
