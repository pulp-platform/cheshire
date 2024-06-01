// Copyright 2023 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Thomas Benz <tbenz@iis.ee.ethz.ch>
//
// Validate the budget functionality of AXI RT

#include "axirt.h"
#include "dif/dma.h"
#include "regs/axi_rt.h"
#include "params.h"
#include "util.h"

// transfer
#define SIZE_BYTES 256
#define SRC_STRIDE 0
#define DST_STRIDE 0
#define NUM_REPS 8
#define SRC_ADDR 0x0000000010000000
#define DST_ADDR 0x0000000080000000

#define TOTAL_SIZE (SIZE_BYTES * NUM_REPS)

int main(void) {

    // enable and configure axi rt with fragmentation of 8 beats
    __axirt_claim(1, 1);
    __axirt_set_len_limit_group(7, 0);

    // configure CVA6
    __axirt_set_region(0, 0xffffffff, 0, 0);
    __axirt_set_region(0x100000000, 0xffffffffffffffff, 1, 0);
    __axirt_set_budget(0x10000000, 0, 0);
    __axirt_set_budget(0x10000000, 1, 0);
    __axirt_set_period(0x10000000, 0, 0);
    __axirt_set_period(0x10000000, 1, 0);

    // configure DMA
    __axirt_set_region(0, 0xffffffff, 0, 2);
    __axirt_set_region(0x100000000, 0xffffffffffffffff, 1, 2);
    __axirt_set_budget(0x10000000, 0, 2);
    __axirt_set_budget(0x10000000, 1, 2);
    __axirt_set_period(0x10000000, 0, 2);
    __axirt_set_period(0x10000000, 1, 2);

    // enable RT unit for DMA and CVA6
    __axirt_enable(0x5);

    // launch DMA transfer
    sys_dma_2d_blk_memcpy(DST_ADDR, SRC_ADDR, SIZE_BYTES, DST_STRIDE, SRC_STRIDE, NUM_REPS);

    // read budget registers and compare
    volatile uint32_t read_budget = *reg32(&__base_axirt, AXI_RT_READ_BUDGET_LEFT_2_REG_OFFSET);
    volatile uint32_t write_budget = *reg32(&__base_axirt, AXI_RT_WRITE_BUDGET_LEFT_2_REG_OFFSET);

    // check
    volatile uint8_t difference = (TOTAL_SIZE - read_budget) + (TOTAL_SIZE - write_budget);
    volatile uint8_t mismatch = read_budget != write_budget;

    return mismatch | (difference << 1);
}
