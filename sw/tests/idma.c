// Copyright 2024 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Chaoqun Liang <chaoqun.liang@unibo.it>
//
// Simple payload to test iDMA

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

#include "iommu_tests.h"
#include "command_queue.h"
#include "fault_queue.h"
#include "device_contexts.h"
#include "msi_pts.h"
#include "iommu_pts.h"
#include "hpm.h"
#include "rvh_test.h"
#include "rv_iommu.h"

#include "util.h"
#include "printf.h"

#define IDMA_BASE 0x01000000
#define SRC_ADDR 0x14000000
#define DST_ADDR 0x14000100

#define IDMA_SRC_ADDR_OFFSET 0x000000d8
#define IDMA_DST_ADDR_OFFSET 0x000000d0
#define IDMA_LENGTH_OFFSET 0x000000e0
#define IDMA_NEXT_ID_OFFSET 0x00000044
#define IDMA_REPS_2 0x000000f8
#define IDMA_CONF 0x00000000

int main(void) {

    fencei();
    init_iommu();
    set_iommu_bare();

    int err = 0;
    volatile uint64_t src_data[8] = {0x1032207098001032, 0x3210E20020709800, 0x1716151413121110,
                                     0x2726252423222120, 0x3736353433323130, 0x4746454443424140,
                                     0x5756555453525150, 0x6766656463626160};
    // load data into src address
    for (int i = 0; i < 8; ++i) {
        volatile uint64_t *src_addr = (volatile uint64_t *)(SRC_ADDR + i * sizeof(uint64_t));
        *src_addr = src_data[i];
    }
    *reg32(IDMA_BASE, IDMA_SRC_ADDR_OFFSET) = SRC_ADDR;
    *reg32(IDMA_BASE, IDMA_DST_ADDR_OFFSET) = DST_ADDR;
    *reg32(IDMA_BASE, IDMA_LENGTH_OFFSET) = 0x00000040;
    *reg32(IDMA_BASE, IDMA_CONF) = 0x1 << 10;
    *reg32(IDMA_BASE, IDMA_REPS_2) = 0x00000001;
    // ID has to be read to make it work
    uint32_t id = *reg32(IDMA_BASE, IDMA_NEXT_ID_OFFSET);
    for (int i = 0; i < 8; ++i) {
        volatile uint64_t *dst_addr = (volatile uint64_t *)(DST_ADDR + i * sizeof(uint64_t));
        uint64_t dst_data = *dst_addr;
        if (dst_data != src_data[i]) {
            err++;
        }
    }

    if (err != 0) printf("idma failed\n");

    return err;
}
