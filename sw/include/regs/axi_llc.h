// Generated register defines for axi_llc

// Copyright information found in source file:
// Copyright 2018-2021 ETH Zurich and University of Bologna.

// Licensing information found in source file:
// 
// SPDX-License-Identifier: SHL-0.51

#ifndef _AXI_LLC_REG_DEFS_
#define _AXI_LLC_REG_DEFS_

#ifdef __cplusplus
extern "C" {
#endif
// Register width
#define AXI_LLC_PARAM_REG_WIDTH 32

// SPM Configuration (lower 32 bit)
#define AXI_LLC_CFG_SPM_LOW_REG_OFFSET 0x0

// SPM Configuration (upper 32 bit)
#define AXI_LLC_CFG_SPM_HIGH_REG_OFFSET 0x4

// Flush Configuration (lower 32 bit)
#define AXI_LLC_CFG_FLUSH_LOW_REG_OFFSET 0x8

// Flush Configuration (upper 32 bit)
#define AXI_LLC_CFG_FLUSH_HIGH_REG_OFFSET 0xc

// Commit the configuration
#define AXI_LLC_COMMIT_CFG_REG_OFFSET 0x10
#define AXI_LLC_COMMIT_CFG_COMMIT_BIT 0

// Flushed Flag (lower 32 bit)
#define AXI_LLC_FLUSHED_LOW_REG_OFFSET 0x18

// Flushed Flag (upper 32 bit)
#define AXI_LLC_FLUSHED_HIGH_REG_OFFSET 0x1c

// Tag Storage BIST Result (lower 32 bit)
#define AXI_LLC_BIST_OUT_LOW_REG_OFFSET 0x20

// Tag Storage BIST Result (upper 32 bit)
#define AXI_LLC_BIST_OUT_HIGH_REG_OFFSET 0x24

// Instantiated Set-Associativity (lower 32 bit)
#define AXI_LLC_SET_ASSO_LOW_REG_OFFSET 0x28

// Instantiated Set-Associativity (upper 32 bit)
#define AXI_LLC_SET_ASSO_HIGH_REG_OFFSET 0x2c

// Instantiated Number of Cache-Lines (lower 32 bit)
#define AXI_LLC_NUM_LINES_LOW_REG_OFFSET 0x30

// Instantiated Number of Cache-Lines (upper 32 bit)
#define AXI_LLC_NUM_LINES_HIGH_REG_OFFSET 0x34

// Instantiated Number of Blocks (lower 32 bit)
#define AXI_LLC_NUM_BLOCKS_LOW_REG_OFFSET 0x38

// Instantiated Number of Blocks (upper 32 bit)
#define AXI_LLC_NUM_BLOCKS_HIGH_REG_OFFSET 0x3c

// AXI LLC Version (lower 32 bit)
#define AXI_LLC_VERSION_LOW_REG_OFFSET 0x40

// AXI LLC Version (upper 32 bit)
#define AXI_LLC_VERSION_HIGH_REG_OFFSET 0x44

// Status register of the BIST
#define AXI_LLC_BIST_STATUS_REG_OFFSET 0x48
#define AXI_LLC_BIST_STATUS_DONE_BIT 0

// Index-based Partition Flush Configuration [31:0] (lower 32 bit)
#define AXI_LLC_CFG_FLUSH_PARTITION_LOW_REG_OFFSET 0x4c

// Index-based Partition Flush Configuration [63:32] (upper 32 bit)
#define AXI_LLC_CFG_FLUSH_PARTITION_HIGH_REG_OFFSET 0x50

// Index-based Partition Configuration [31:0] (lower 32 bit) (common
// parameters)
#define AXI_LLC_CFG_SET_PARTITION_LOW_LOW_FIELD_WIDTH 32
#define AXI_LLC_CFG_SET_PARTITION_LOW_LOW_FIELDS_PER_REG 1
#define AXI_LLC_CFG_SET_PARTITION_LOW_MULTIREG_COUNT 2

// Index-based Partition Configuration [31:0] (lower 32 bit)
#define AXI_LLC_CFG_SET_PARTITION_LOW_0_REG_OFFSET 0x54

// Index-based Partition Configuration [31:0] (lower 32 bit)
#define AXI_LLC_CFG_SET_PARTITION_LOW_1_REG_OFFSET 0x58

// Index-based Partition Configuration [63:32] (higher 32 bit) (common
// parameters)
#define AXI_LLC_CFG_SET_PARTITION_HIGH_HIGH_FIELD_WIDTH 32
#define AXI_LLC_CFG_SET_PARTITION_HIGH_HIGH_FIELDS_PER_REG 1
#define AXI_LLC_CFG_SET_PARTITION_HIGH_MULTIREG_COUNT 2

// Index-based Partition Configuration [63:32] (higher 32 bit)
#define AXI_LLC_CFG_SET_PARTITION_HIGH_0_REG_OFFSET 0x5c

// Index-based Partition Configuration [63:32] (higher 32 bit)
#define AXI_LLC_CFG_SET_PARTITION_HIGH_1_REG_OFFSET 0x60

// Commit the set partition configuration
#define AXI_LLC_COMMIT_PARTITION_CFG_REG_OFFSET 0x64
#define AXI_LLC_COMMIT_PARTITION_CFG_COMMIT_BIT 0

// Index-based Flushed Flag (lower 32 bit) (common parameters)
#define AXI_LLC_FLUSHED_SET_LOW_LOW_FIELD_WIDTH 32
#define AXI_LLC_FLUSHED_SET_LOW_LOW_FIELDS_PER_REG 1
#define AXI_LLC_FLUSHED_SET_LOW_MULTIREG_COUNT 4

// Index-based Flushed Flag (lower 32 bit)
#define AXI_LLC_FLUSHED_SET_LOW_0_REG_OFFSET 0x6c

// Index-based Flushed Flag (lower 32 bit)
#define AXI_LLC_FLUSHED_SET_LOW_1_REG_OFFSET 0x70

// Index-based Flushed Flag (lower 32 bit)
#define AXI_LLC_FLUSHED_SET_LOW_2_REG_OFFSET 0x74

// Index-based Flushed Flag (lower 32 bit)
#define AXI_LLC_FLUSHED_SET_LOW_3_REG_OFFSET 0x78

// Index-based Flushed Flag (upper 32 bit) (common parameters)
#define AXI_LLC_FLUSHED_SET_HIGH_HIGH_FIELD_WIDTH 32
#define AXI_LLC_FLUSHED_SET_HIGH_HIGH_FIELDS_PER_REG 1
#define AXI_LLC_FLUSHED_SET_HIGH_MULTIREG_COUNT 4

// Index-based Flushed Flag (upper 32 bit)
#define AXI_LLC_FLUSHED_SET_HIGH_0_REG_OFFSET 0x7c

// Index-based Flushed Flag (upper 32 bit)
#define AXI_LLC_FLUSHED_SET_HIGH_1_REG_OFFSET 0x80

// Index-based Flushed Flag (upper 32 bit)
#define AXI_LLC_FLUSHED_SET_HIGH_2_REG_OFFSET 0x84

// Index-based Flushed Flag (upper 32 bit)
#define AXI_LLC_FLUSHED_SET_HIGH_3_REG_OFFSET 0x88

#ifdef __cplusplus
}  // extern "C"
#endif
#endif  // _AXI_LLC_REG_DEFS_
// End generated register defines for axi_llc