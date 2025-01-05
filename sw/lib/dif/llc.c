// Copyright 2022 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Cyril Koenig <cykoenig@iis.ee.ethz.ch>

#include "dif/axi_llc.h"
#include "regs/axi_llc.h"
#include "util.h"
#include "params.h"

void llc_enable() {
    *reg32(&__base_llc, AXI_LLC_CFG_SPM_LOW_REG_OFFSET ) = 0x00000000;
    *reg32(&__base_llc, AXI_LLC_CFG_SPM_HIGH_REG_OFFSET) = 0x00000000;
    fence();
    *reg32(&__base_llc, AXI_LLC_COMMIT_CFG_REG_OFFSET) = 0x1;
    fence();
}

void llc_flush() {
    *reg32(&__base_llc, AXI_LLC_CFG_FLUSH_LOW_REG_OFFSET ) = 0xffffffff;
    *reg32(&__base_llc, AXI_LLC_CFG_FLUSH_HIGH_REG_OFFSET) = 0xffffffff;
    fence();
    *reg32(&__base_llc, AXI_LLC_COMMIT_CFG_REG_OFFSET) = 0x1;
    fence();
    while(*reg32(&__base_llc, AXI_LLC_CFG_FLUSH_LOW_REG_OFFSET) != 0);
    while(*reg32(&__base_llc, AXI_LLC_CFG_FLUSH_HIGH_REG_OFFSET) != 0);
}

void llc_disable() {
    *reg32(&__base_llc, AXI_LLC_CFG_SPM_LOW_REG_OFFSET ) = 0xffffffff;
    *reg32(&__base_llc, AXI_LLC_CFG_SPM_HIGH_REG_OFFSET) = 0xffffffff;
    *reg32(&__base_llc, AXI_LLC_CFG_FLUSH_LOW_REG_OFFSET ) = 0xffffffff;
    *reg32(&__base_llc, AXI_LLC_CFG_FLUSH_HIGH_REG_OFFSET) = 0xffffffff;
    fence();
    *reg32(&__base_llc, AXI_LLC_COMMIT_CFG_REG_OFFSET) = 0x1;
    fence();
}
