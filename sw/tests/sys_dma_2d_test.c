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
#include "printf.h"

#define NUM_INITIALIZED_VALUES 100

int main(void) {

//    // Disable D-Cache
//    asm volatile(
//	    "addi t0, x0, 1\n   \
//	     csrrc x0, 0x701, t0\n"
//	     ::: "t0"
//    );

    // Size of transfer
    uint32_t size_bytes = 64;
    // Source stride
    uint32_t src_stride = 64;
    // Destination stride
    uint32_t dst_stride = 64;
    // Number of repetitions
    uint32_t num_reps = 8;

    volatile uint64_t *spm_free = 0x10000000 + 0x4000000;
    volatile uint64_t *dram_free = 0x80000000; //+ 0x4000000;
    volatile uint64_t *spm_expected = spm_free;

    PRINTF("Initialize src and destination pointers\r\n");
    // Initialize spm and dram free regions
    for(int i = 0; i < NUM_INITIALIZED_VALUES; i++)
    {
	spm_free[i] = 0xcafedeadbaadf00d + i;
	spm_expected[i] = spm_free[i]; // golden values
    }

    PRINTF("2D sys DMA blocking memcpy from LLC-SPM to DDR3 on genesys2\r\n");
    // write from spm to dram (blocking)
    sys_dma_2d_blk_memcpy(dram_free, spm_free, size_bytes, dst_stride, src_stride, num_reps);
    fence();

    PRINTF("2D sys DMA blocking memcpy from DDR3 to LLC-SPM on genesys2\r\n");
    // write from dram to spm (blocking)
    sys_dma_2d_blk_memcpy(spm_free, dram_free, size_bytes, dst_stride, src_stride, num_reps);
    fence();

    // check spm destination against expected

    // if something went wrong in the W/R journey towards dram, data
    // will be different

    for(volatile int i = 0; i < NUM_INITIALIZED_VALUES; i++)
    {
	CHECK_ASSERT(1, spm_free[i] == spm_expected[i]);
	PRINTF("Got spm_free: %lx, dram_free: %lx, expected %lx\r\n", spm_free[i], dram_free[i], spm_expected[i]);
    }

}
