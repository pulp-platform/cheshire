// Copyright 2023 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Alessandro Ottaviano <aottaviano@iis.ee.ethz.ch>
//
// Validate the isolation functionality of AXI-REALM

#include "axirt.h"
#include "dif/dma.h"
#include "params.h"
#include "regs/axi_rt.h"
#include "regs/cheshire.h"
#include "util.h"

// transfer
#define SIZE_BEAT_BYTES 8
#define DMA_NUM_BEATS 32
#define DMA_NUM_REPS 8
#define DMA_SIZE_BYTES (SIZE_BEAT_BYTES * DMA_NUM_BEATS)
#define DMA_TOTAL_SIZE_BYTES (DMA_SIZE_BYTES * DMA_NUM_REPS)
#define DMA_SRC_STRIDE 0
#define DMA_DST_STRIDE 0
#define DMA_SRC_ADDRESS 0x10008000
#define DMA_DST_ADDRESS 0x80008000

// AXI-REALM
#define CVA6_ALLOCATED_BUDGET 0x10000000
#define CVA6_ALLOCATED_PERIOD 0x10000000
#define DMA_ALLOCATED_BUDGET \
    (DMA_TOTAL_SIZE_BYTES / 2) // Set budget as half of the number of bytes to
                               // transfer. This is done intentionally to test
                               // isolation capabilities.
#define DMA_ALLOCATED_PERIOD 0x10000000
#define FRAGMENTATION_SIZE_BEATS 0 // Max fragmentation applied to bursts

int main(void) {

    uint32_t cheshire_num_harts = *reg32(&__base_regs, CHESHIRE_NUM_INT_HARTS_REG_OFFSET);

    volatile uint64_t *dma_src = (volatile uint64_t *)(DMA_SRC_ADDRESS);
    volatile uint64_t *dma_dst = (volatile uint64_t *)(DMA_DST_ADDRESS);

    // enable and configure axi rt
    __axirt_claim(1, 1);
    __axirt_set_len_limit_group(FRAGMENTATION_SIZE_BEATS, 0);
    __axirt_set_len_limit_group(FRAGMENTATION_SIZE_BEATS, 1);
    fence();

    // configure RT unit for all the CVA6 cores. At least one RV64 core is
    // always present, so no need to check if the feature is there or not.
    uint32_t chs_core0_id = get_chs_mngr_id_from_hw_feature(CHS_MNGR_CORE0);
    for (uint32_t id = chs_core0_id; id < cheshire_num_harts; id++) {
        __axirt_set_region(0, 0xffffffff, 0, id);
        __axirt_set_region(0x100000000, 0xffffffffffffffff, 1, id);
        __axirt_set_budget(CVA6_ALLOCATED_BUDGET, 0, id);
        __axirt_set_budget(CVA6_ALLOCATED_BUDGET, 1, id);
        __axirt_set_period(CVA6_ALLOCATED_PERIOD, 0, id);
        __axirt_set_period(CVA6_ALLOCATED_PERIOD, 1, id);
        fence();
    }

    // configure RT unit for the DMA
    uint32_t chs_dma_id = get_chs_mngr_id_from_hw_feature(CHS_MNGR_DMA);
    // immediately return an error if DMA is not present in cheshire
    CHECK_ASSERT(HW_IMPL_ERR, (chs_dma_id != HW_IMPL_ERR));

    __axirt_set_region(0, 0xffffffff, 0, chs_dma_id);
    __axirt_set_region(0x100000000, 0xffffffffffffffff, 1, chs_dma_id);
    __axirt_set_budget(DMA_ALLOCATED_BUDGET, 0, chs_dma_id);
    __axirt_set_budget(DMA_ALLOCATED_BUDGET, 1, chs_dma_id);
    __axirt_set_period(DMA_ALLOCATED_PERIOD, 0, chs_dma_id);
    __axirt_set_period(DMA_ALLOCATED_PERIOD, 1, chs_dma_id);
    fence();

    // enable RT unit for all the cores
    __axirt_enable(BIT_MASK(cheshire_num_harts));

    // enable RT unit for the DMA
    __axirt_enable(BIT(chs_dma_id));
    fence();

    // initialize src region and golden values
    for (int i = 0; i < DMA_NUM_BEATS; i++) {
        dma_src[i] = 0xcafedeadbaadf00dULL + i;
        fence();
    }

    // launch blocking DMA transfer
    sys_dma_2d_blk_memcpy((uint64_t *)dma_dst, (uint64_t *)dma_src, DMA_SIZE_BYTES, DMA_DST_STRIDE,
                          DMA_SRC_STRIDE, DMA_NUM_REPS);

    // poll isolate to check if AXI-REALM isolates the dma when the budget is
    // exceeded. Should return 1 if dma is isolated.
    uint8_t isolate_status = __axirt_poll_isolate(chs_dma_id);

    // return 0 if manager was correctly isolated
    return !isolate_status;
}
