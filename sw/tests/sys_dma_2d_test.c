// Copyright 2023 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Alessandro Ottaviano <aottaviano@iis.ee.ethz.ch>
//

#include "io.h"
#include "dif/clint.h"
#include "dif/uart.h"
#include "params.h"
#include "regs/cheshire.h"
#include "dma.h"
#include "util.h"

#define NUM_INITIALIZED_VALUES 400

int main(void) {

    // Disable D-Cache
    asm volatile(
	    "addi t0, x0, 1\n   \
	     csrrc x0, 0x701, t0\n"
	     ::: "t0"
    );

    // Size of transfer
    uint32_t size_bytes = 64;
    // Source stride
    uint32_t src_stride = 64;
    // Destination stride
    uint32_t dst_stride = 64;
    // Number of repetitions
    uint32_t num_reps = 8;

    volatile uint64_t *spm_free = 0x10000000 + 0x4000000;
    volatile uint64_t *dram_free = 0x80000000 + 0x4000000;
    volatile uint64_t *spm_expected = spm_free;

    // Initialize spm and dram free regions
    for(int i = 0; i < NUM_INITIALIZED_VALUES; i++)
    {
	spm_free[i] = 0xcafedeadbaadf00d + i;
	spm_expected[i] = spm_free[i]; // golden values
    }

    // write from spm to dram (blocking)
    sys_dma_2d_blk_memcpy(dram_free, spm_free, size_bytes, dst_stride, src_stride, num_reps);

    // write from dram to spm (blocking)
    sys_dma_2d_blk_memcpy(spm_free, dram_free, size_bytes, dst_stride, src_stride, num_reps);

    // check spm destination against expected

    // if something went wrong in the W/R journey towards dram, data
    // will be different

    for(int i = 0; i < NUM_INITIALIZED_VALUES; i++)
    {
	CHECK_ASSERT(1, spm_free[i] == spm_expected[i]);
    }

}
