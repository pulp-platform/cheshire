// Copyright 2022 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Thomas Benz <tbenz@iis.ee.ethz.ch>

#include "regs/axi_rt.h"
#include "axirt.h"
#include "util.h"
#include "params.h"

// functions accessing guard unit
void __axirt_claim(bool read_excl, bool write_excl) {
    uint8_t flags = 4 | (read_excl << 1) | write_excl;
    *reg8(&__base_axirtgrd, 0) = flags;
}

void __axirt_release() {
    *reg32(&__base_axirtgrd, 0) = 0;
}

// setter functions
void __axirt_set_len_limit(uint8_t limit, uint8_t mgr_id) {
    *reg8(&__base_axirt, AXI_RT_LEN_LIMIT_0_REG_OFFSET + mgr_id) = limit;
}

void __axirt_set_region(uint64_t start_addr, uint64_t end_addr, uint8_t region_id, uint8_t mgr_id) {

    *reg32(&__base_axirt, AXI_RT_END_ADDR_SUB_HIGH_0_REG_OFFSET +
                              AXI_RT_PARAM_NUM_SUB * mgr_id * 4 + region_id * 4) = end_addr >> 32;
    *reg32(&__base_axirt, AXI_RT_END_ADDR_SUB_LOW_0_REG_OFFSET + AXI_RT_PARAM_NUM_SUB * mgr_id * 4 +
                              region_id * 4) = end_addr & 0xffffffff;

    *reg32(&__base_axirt, AXI_RT_START_ADDR_SUB_LOW_0_REG_OFFSET +
                              AXI_RT_PARAM_NUM_SUB * mgr_id * 4 + region_id * 4) =
        start_addr & 0xffffffff;
    *reg32(&__base_axirt, AXI_RT_START_ADDR_SUB_HIGH_0_REG_OFFSET +
                              AXI_RT_PARAM_NUM_SUB * mgr_id * 4 + region_id * 4) = start_addr >> 32;
}

void __axirt_set_period(uint32_t period, uint8_t region_id, uint8_t mgr_id) {
    *reg32(&__base_axirt, AXI_RT_WRITE_PERIOD_0_REG_OFFSET + AXI_RT_PARAM_NUM_SUB * mgr_id * 4 +
                              region_id * 4) = period;
    *reg32(&__base_axirt, AXI_RT_READ_PERIOD_0_REG_OFFSET + AXI_RT_PARAM_NUM_SUB * mgr_id * 4 +
                              region_id * 4) = period;
}

void __axirt_set_budget(uint32_t budget, uint8_t region_id, uint8_t mgr_id) {
    *reg32(&__base_axirt, AXI_RT_WRITE_BUDGET_0_REG_OFFSET + AXI_RT_PARAM_NUM_SUB * mgr_id * 4 +
                              region_id * 4) = budget;
    *reg32(&__base_axirt, AXI_RT_READ_BUDGET_0_REG_OFFSET + AXI_RT_PARAM_NUM_SUB * mgr_id * 4 +
                              region_id * 4) = budget;
}

// config functions
void __axirt_enable(uint32_t enable) {
    *reg32(&__base_axirt, AXI_RT_RT_ENABLE_REG_OFFSET) = enable;
    *reg32(&__base_axirt, AXI_RT_IMTU_ENABLE_REG_OFFSET) = enable;
}

void __axirt_disable() {
    *reg32(&__base_axirt, AXI_RT_IMTU_ENABLE_REG_OFFSET) = 0;
    *reg32(&__base_axirt, AXI_RT_RT_ENABLE_REG_OFFSET) = 0;
}
