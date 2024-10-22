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
#define SRC_ADDR 0x0000000078000000 // L2
#define DST_ADDR 0x0000000080000000 // DRAM

// AXI-REALM
#define CVA6_ALLOCATED_BUDGET 0x10000000
#define CVA6_ALLOCATED_PERIOD 0x10000000
#define DMA_ALLOCATED_BUDGET \
    (DMA_TOTAL_SIZE_BYTES / 2) // Set budget as half of the number of bytes to
                               // transfer intentionally
#define DMA_ALLOCATED_PERIOD 0x10000000
#define FRAGMENTATION_SIZE_BEATS 256 // No fragmentation applied to bursts

int main(void) {

    uint32_t cheshire_num_harts = *reg32(&__base_regs, CHESHIRE_NUM_INT_HARTS_REG_OFFSET);

    // enable and configure axi rt with fragmentation of 8 beats
    __axirt_claim(1, 1);
    __axirt_set_len_limit_group(FRAGMENTATION_SIZE_BEATS, 0);
    __axirt_set_len_limit_group(FRAGMENTATION_SIZE_BEATS, 1);
    fence();

    // configure CVA6 cores
    for (enum axirealm_mngr_id id = AXIREALM_MNGR_ID_CVA60; id <= cheshire_num_harts; id++) {
        __axirt_set_region(0, 0xffffffff, 0, id);
        __axirt_set_region(0x100000000, 0xffffffffffffffff, 1, id);
        __axirt_set_budget(CVA6_ALLOCATED_BUDGET, 0, id);
        __axirt_set_budget(CVA6_ALLOCATED_BUDGET, 1, id);
        __axirt_set_period(CVA6_ALLOCATED_PERIOD, 0, id);
        __axirt_set_period(CVA6_ALLOCATED_PERIOD, 1, id);
        fence();
    }

    // configure DMA
    __axirt_set_region(0, 0xffffffff, 0, AXIREALM_MNGR_ID_DMA);
    __axirt_set_region(0x100000000, 0xffffffffffffffff, 1, AXIREALM_MNGR_ID_DMA);
    __axirt_set_budget(DMA_ALLOCATED_BUDGET, 0, AXIREALM_MNGR_ID_DMA);
    __axirt_set_budget(DMA_ALLOCATED_BUDGET, 1, AXIREALM_MNGR_ID_DMA);
    __axirt_set_period(DMA_ALLOCATED_PERIOD, 0, AXIREALM_MNGR_ID_DMA);
    __axirt_set_period(DMA_ALLOCATED_PERIOD, 1, AXIREALM_MNGR_ID_DMA);
    fence();

    // enable RT unit for DMA and CVA6 cores
    __axirt_enable((BIT(AXIREALM_MNGR_ID_CVA60) | BIT(AXIREALM_MNGR_ID_DMA)));
    fence();

    volatile uint64_t *sys_src = (volatile uint64_t *)SRC_ADDR;

    // initialize src region
    for (int i = 0; i < DMA_NUM_BEATS; i++) {
        sys_src[i] = 0xcafedeadbaadf00d + i;
        fence();
    }

    // launch non-blocking DMA transfer
    sys_dma_2d_memcpy(DST_ADDR, SRC_ADDR, DMA_SIZE_BYTES, DMA_DST_STRIDE, DMA_SRC_STRIDE,
                      DMA_NUM_REPS);

    // Poll isolate to check if AXI-REALM isolates the dma when the budget is exceeded. Should
    // return 1 if dma is isolated.
    uint8_t isolate_status = __axirt_poll_isolate(AXIREALM_MNGR_ID_DMA);

    // return 0 if manager was correctly isolated
    return !isolate_status;
}
