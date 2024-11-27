// Copyright 2023 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Thomas Benz <tbenz@iis.ee.ethz.ch>
// Alessandro Ottaviano <aottaviano@iis.ee.ethz.ch>
//
// Validate the budget functionality of AXI-REALM

#include "axirt.h"
#include "dif/dma.h"
#include "params.h"
#include "regs/axi_rt.h"
#include "regs/cheshire.h"
#include "util.h"
#include "printf.h"

// transfer
#define SIZE_BEAT_BYTES 8
#define DMA_NUM_BEATS 128
#define DMA_NUM_REPS 1
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
#define DMA_ALLOCATED_BUDGET 0x10000000
#define DMA_ALLOCATED_PERIOD 0x10000000
#define FRAGMENTATION_SIZE_BEATS 0 // Max fragmentation applied to bursts

int main(void) {

    // Immediately return an error if DMA is not present in cheshire
    CHECK_ASSERT(-1, chs_hw_feature_present(CHESHIRE_HW_FEATURES_DMA_BIT));

    uint32_t cheshire_num_harts = *reg32(&__base_regs, CHESHIRE_NUM_INT_HARTS_REG_OFFSET);

    volatile uint64_t *dma_src = (volatile uint64_t *)(DMA_SRC_ADDRESS);
    volatile uint64_t *dma_dst = (volatile uint64_t *)(DMA_DST_ADDRESS);

    uint64_t golden[DMA_NUM_BEATS]; // Declare non-volatile array for golden values

    // Enable and configure axi rt
    __axirt_claim(1, 1);
    __axirt_set_len_limit_group(FRAGMENTATION_SIZE_BEATS, 0);
    __axirt_set_len_limit_group(FRAGMENTATION_SIZE_BEATS, 1);
    fence();

    // Configure RT unit for all the CVA6 cores
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
        golden[i] = 0xcafedeadbaadf00dULL + i; // Compute golden values
        dma_src[i] = golden[i];                // Initialize source memory
        fence();
    }

    // Launch blocking DMA transfer
    sys_dma_2d_blk_memcpy((uintptr_t)(void *)dma_dst, (uintptr_t)(void *)dma_src, DMA_SIZE_BYTES, DMA_DST_STRIDE,
                          DMA_SRC_STRIDE, DMA_NUM_REPS);

    // Check DMA transfers against gold.
    for (volatile int i = 0; i < DMA_NUM_BEATS; i++) {
        CHECK_ASSERT(20, dma_dst[i] == golden[i]);
    }

    // Read budget registers for dma and compare
    volatile uint32_t dma_read_budget_left =
        *reg32(&__base_axirt, AXI_RT_READ_BUDGET_LEFT_4_REG_OFFSET);
    volatile uint32_t dma_write_budget_left =
        *reg32(&__base_axirt, AXI_RT_WRITE_BUDGET_LEFT_4_REG_OFFSET);

    // Check budget: return 0 if (initial budget - final budget) matches the
    // number of transferred bytes, otherwise return 1
    volatile uint8_t dma_r_difference =
        (DMA_ALLOCATED_BUDGET - dma_read_budget_left) != DMA_TOTAL_SIZE_BYTES;
    volatile uint8_t dma_w_difference =
        (DMA_ALLOCATED_BUDGET - dma_write_budget_left) != DMA_TOTAL_SIZE_BYTES;
    // W and R are symmetric on the dma: left budgets should be equal
    volatile uint8_t dma_rw_mismatch = dma_read_budget_left != dma_write_budget_left;

    return (dma_rw_mismatch | dma_r_difference | dma_w_difference);
}
