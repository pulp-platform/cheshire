// Generated register defines for idma_desc64

// Copyright information found in source file:
// Copyright 2023 ETH Zurich and University of Bologna.

// Licensing information found in source file:
// 
// SPDX-License-Identifier: SHL-0.51

#ifndef _IDMA_DESC64_REG_DEFS_
#define _IDMA_DESC64_REG_DEFS_

#ifdef __cplusplus
extern "C" {
#endif
// Register width
#define IDMA_DESC64_PARAM_REG_WIDTH 64

// This register specifies the bus address at which the first transfer
#define IDMA_DESC64_DESC_ADDR_REG_OFFSET 0x0

// This register contains status information for the DMA.
#define IDMA_DESC64_STATUS_REG_OFFSET 0x8
#define IDMA_DESC64_STATUS_BUSY_BIT 0
#define IDMA_DESC64_STATUS_FIFO_FULL_BIT 1

#ifdef __cplusplus
}  // extern "C"
#endif
#endif  // _IDMA_DESC64_REG_DEFS_
// End generated register defines for idma_desc64
