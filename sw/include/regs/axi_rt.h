// Generated register defines for axi_rt

// Copyright information found in source file:
// Copyright 2022 ETH Zurich and University of Bologna.

// Licensing information found in source file:
// Licensed under Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51

#ifndef _AXI_RT_REG_DEFS_
#define _AXI_RT_REG_DEFS_

#ifdef __cplusplus
extern "C" {
#endif
// Maximum number of managers.
#define AXI_RT_PARAM_NUM_MRG 8

// Configured number of subordinate regions.
#define AXI_RT_PARAM_NUM_SUB 2

// Configured number of required registers.
#define AXI_RT_PARAM_NUM_REG 16

// Register width
#define AXI_RT_PARAM_REG_WIDTH 32

// Value of the major_version.
#define AXI_RT_MAJOR_VERSION_REG_OFFSET 0x0

// Value of the minor_version.
#define AXI_RT_MINOR_VERSION_REG_OFFSET 0x4

// Value of the patch_version.
#define AXI_RT_PATCH_VERSION_REG_OFFSET 0x8

// Enable RT feature on master (common parameters)
#define AXI_RT_RT_ENABLE_ENABLE_FIELD_WIDTH 1
#define AXI_RT_RT_ENABLE_ENABLE_FIELDS_PER_REG 32
#define AXI_RT_RT_ENABLE_MULTIREG_COUNT 1

// Enable RT feature on master
#define AXI_RT_RT_ENABLE_REG_OFFSET 0xc
#define AXI_RT_RT_ENABLE_ENABLE_0_BIT 0
#define AXI_RT_RT_ENABLE_ENABLE_1_BIT 1
#define AXI_RT_RT_ENABLE_ENABLE_2_BIT 2
#define AXI_RT_RT_ENABLE_ENABLE_3_BIT 3
#define AXI_RT_RT_ENABLE_ENABLE_4_BIT 4
#define AXI_RT_RT_ENABLE_ENABLE_5_BIT 5
#define AXI_RT_RT_ENABLE_ENABLE_6_BIT 6
#define AXI_RT_RT_ENABLE_ENABLE_7_BIT 7

// Is the RT inactive? (common parameters)
#define AXI_RT_RT_BYPASSED_BYPASSED_FIELD_WIDTH 1
#define AXI_RT_RT_BYPASSED_BYPASSED_FIELDS_PER_REG 32
#define AXI_RT_RT_BYPASSED_MULTIREG_COUNT 1

// Is the RT inactive?
#define AXI_RT_RT_BYPASSED_REG_OFFSET 0x10
#define AXI_RT_RT_BYPASSED_BYPASSED_0_BIT 0
#define AXI_RT_RT_BYPASSED_BYPASSED_1_BIT 1
#define AXI_RT_RT_BYPASSED_BYPASSED_2_BIT 2
#define AXI_RT_RT_BYPASSED_BYPASSED_3_BIT 3
#define AXI_RT_RT_BYPASSED_BYPASSED_4_BIT 4
#define AXI_RT_RT_BYPASSED_BYPASSED_5_BIT 5
#define AXI_RT_RT_BYPASSED_BYPASSED_6_BIT 6
#define AXI_RT_RT_BYPASSED_BYPASSED_7_BIT 7

// Fragmentation of the bursts in beats. (common parameters)
#define AXI_RT_LEN_LIMIT_LEN_FIELD_WIDTH 8
#define AXI_RT_LEN_LIMIT_LEN_FIELDS_PER_REG 4
#define AXI_RT_LEN_LIMIT_MULTIREG_COUNT 2

// Fragmentation of the bursts in beats.
#define AXI_RT_LEN_LIMIT_0_REG_OFFSET 0x14
#define AXI_RT_LEN_LIMIT_0_LEN_0_MASK 0xff
#define AXI_RT_LEN_LIMIT_0_LEN_0_OFFSET 0
#define AXI_RT_LEN_LIMIT_0_LEN_0_FIELD \
  ((bitfield_field32_t) { .mask = AXI_RT_LEN_LIMIT_0_LEN_0_MASK, .index = AXI_RT_LEN_LIMIT_0_LEN_0_OFFSET })
#define AXI_RT_LEN_LIMIT_0_LEN_1_MASK 0xff
#define AXI_RT_LEN_LIMIT_0_LEN_1_OFFSET 8
#define AXI_RT_LEN_LIMIT_0_LEN_1_FIELD \
  ((bitfield_field32_t) { .mask = AXI_RT_LEN_LIMIT_0_LEN_1_MASK, .index = AXI_RT_LEN_LIMIT_0_LEN_1_OFFSET })
#define AXI_RT_LEN_LIMIT_0_LEN_2_MASK 0xff
#define AXI_RT_LEN_LIMIT_0_LEN_2_OFFSET 16
#define AXI_RT_LEN_LIMIT_0_LEN_2_FIELD \
  ((bitfield_field32_t) { .mask = AXI_RT_LEN_LIMIT_0_LEN_2_MASK, .index = AXI_RT_LEN_LIMIT_0_LEN_2_OFFSET })
#define AXI_RT_LEN_LIMIT_0_LEN_3_MASK 0xff
#define AXI_RT_LEN_LIMIT_0_LEN_3_OFFSET 24
#define AXI_RT_LEN_LIMIT_0_LEN_3_FIELD \
  ((bitfield_field32_t) { .mask = AXI_RT_LEN_LIMIT_0_LEN_3_MASK, .index = AXI_RT_LEN_LIMIT_0_LEN_3_OFFSET })

// Fragmentation of the bursts in beats.
#define AXI_RT_LEN_LIMIT_1_REG_OFFSET 0x18
#define AXI_RT_LEN_LIMIT_1_LEN_4_MASK 0xff
#define AXI_RT_LEN_LIMIT_1_LEN_4_OFFSET 0
#define AXI_RT_LEN_LIMIT_1_LEN_4_FIELD \
  ((bitfield_field32_t) { .mask = AXI_RT_LEN_LIMIT_1_LEN_4_MASK, .index = AXI_RT_LEN_LIMIT_1_LEN_4_OFFSET })
#define AXI_RT_LEN_LIMIT_1_LEN_5_MASK 0xff
#define AXI_RT_LEN_LIMIT_1_LEN_5_OFFSET 8
#define AXI_RT_LEN_LIMIT_1_LEN_5_FIELD \
  ((bitfield_field32_t) { .mask = AXI_RT_LEN_LIMIT_1_LEN_5_MASK, .index = AXI_RT_LEN_LIMIT_1_LEN_5_OFFSET })
#define AXI_RT_LEN_LIMIT_1_LEN_6_MASK 0xff
#define AXI_RT_LEN_LIMIT_1_LEN_6_OFFSET 16
#define AXI_RT_LEN_LIMIT_1_LEN_6_FIELD \
  ((bitfield_field32_t) { .mask = AXI_RT_LEN_LIMIT_1_LEN_6_MASK, .index = AXI_RT_LEN_LIMIT_1_LEN_6_OFFSET })
#define AXI_RT_LEN_LIMIT_1_LEN_7_MASK 0xff
#define AXI_RT_LEN_LIMIT_1_LEN_7_OFFSET 24
#define AXI_RT_LEN_LIMIT_1_LEN_7_FIELD \
  ((bitfield_field32_t) { .mask = AXI_RT_LEN_LIMIT_1_LEN_7_MASK, .index = AXI_RT_LEN_LIMIT_1_LEN_7_OFFSET })

// Enables the IMTU. (common parameters)
#define AXI_RT_IMTU_ENABLE_ENABLE_FIELD_WIDTH 1
#define AXI_RT_IMTU_ENABLE_ENABLE_FIELDS_PER_REG 32
#define AXI_RT_IMTU_ENABLE_MULTIREG_COUNT 1

// Enables the IMTU.
#define AXI_RT_IMTU_ENABLE_REG_OFFSET 0x1c
#define AXI_RT_IMTU_ENABLE_ENABLE_0_BIT 0
#define AXI_RT_IMTU_ENABLE_ENABLE_1_BIT 1
#define AXI_RT_IMTU_ENABLE_ENABLE_2_BIT 2
#define AXI_RT_IMTU_ENABLE_ENABLE_3_BIT 3
#define AXI_RT_IMTU_ENABLE_ENABLE_4_BIT 4
#define AXI_RT_IMTU_ENABLE_ENABLE_5_BIT 5
#define AXI_RT_IMTU_ENABLE_ENABLE_6_BIT 6
#define AXI_RT_IMTU_ENABLE_ENABLE_7_BIT 7

// Resets both the period and the budget. (common parameters)
#define AXI_RT_IMTU_ABORT_ABORT_FIELD_WIDTH 1
#define AXI_RT_IMTU_ABORT_ABORT_FIELDS_PER_REG 32
#define AXI_RT_IMTU_ABORT_MULTIREG_COUNT 1

// Resets both the period and the budget.
#define AXI_RT_IMTU_ABORT_REG_OFFSET 0x20
#define AXI_RT_IMTU_ABORT_ABORT_0_BIT 0
#define AXI_RT_IMTU_ABORT_ABORT_1_BIT 1
#define AXI_RT_IMTU_ABORT_ABORT_2_BIT 2
#define AXI_RT_IMTU_ABORT_ABORT_3_BIT 3
#define AXI_RT_IMTU_ABORT_ABORT_4_BIT 4
#define AXI_RT_IMTU_ABORT_ABORT_5_BIT 5
#define AXI_RT_IMTU_ABORT_ABORT_6_BIT 6
#define AXI_RT_IMTU_ABORT_ABORT_7_BIT 7

// The lower 32bit of the start address. (common parameters)
#define AXI_RT_START_ADDR_SUB_LOW_WRITE_BUDGET_FIELD_WIDTH 32
#define AXI_RT_START_ADDR_SUB_LOW_WRITE_BUDGET_FIELDS_PER_REG 1
#define AXI_RT_START_ADDR_SUB_LOW_MULTIREG_COUNT 16

// The lower 32bit of the start address.
#define AXI_RT_START_ADDR_SUB_LOW_0_REG_OFFSET 0x24

// The lower 32bit of the start address.
#define AXI_RT_START_ADDR_SUB_LOW_1_REG_OFFSET 0x28

// The lower 32bit of the start address.
#define AXI_RT_START_ADDR_SUB_LOW_2_REG_OFFSET 0x2c

// The lower 32bit of the start address.
#define AXI_RT_START_ADDR_SUB_LOW_3_REG_OFFSET 0x30

// The lower 32bit of the start address.
#define AXI_RT_START_ADDR_SUB_LOW_4_REG_OFFSET 0x34

// The lower 32bit of the start address.
#define AXI_RT_START_ADDR_SUB_LOW_5_REG_OFFSET 0x38

// The lower 32bit of the start address.
#define AXI_RT_START_ADDR_SUB_LOW_6_REG_OFFSET 0x3c

// The lower 32bit of the start address.
#define AXI_RT_START_ADDR_SUB_LOW_7_REG_OFFSET 0x40

// The lower 32bit of the start address.
#define AXI_RT_START_ADDR_SUB_LOW_8_REG_OFFSET 0x44

// The lower 32bit of the start address.
#define AXI_RT_START_ADDR_SUB_LOW_9_REG_OFFSET 0x48

// The lower 32bit of the start address.
#define AXI_RT_START_ADDR_SUB_LOW_10_REG_OFFSET 0x4c

// The lower 32bit of the start address.
#define AXI_RT_START_ADDR_SUB_LOW_11_REG_OFFSET 0x50

// The lower 32bit of the start address.
#define AXI_RT_START_ADDR_SUB_LOW_12_REG_OFFSET 0x54

// The lower 32bit of the start address.
#define AXI_RT_START_ADDR_SUB_LOW_13_REG_OFFSET 0x58

// The lower 32bit of the start address.
#define AXI_RT_START_ADDR_SUB_LOW_14_REG_OFFSET 0x5c

// The lower 32bit of the start address.
#define AXI_RT_START_ADDR_SUB_LOW_15_REG_OFFSET 0x60

// The higher 32bit of the start address. (common parameters)
#define AXI_RT_START_ADDR_SUB_HIGH_WRITE_BUDGET_FIELD_WIDTH 32
#define AXI_RT_START_ADDR_SUB_HIGH_WRITE_BUDGET_FIELDS_PER_REG 1
#define AXI_RT_START_ADDR_SUB_HIGH_MULTIREG_COUNT 16

// The higher 32bit of the start address.
#define AXI_RT_START_ADDR_SUB_HIGH_0_REG_OFFSET 0x64

// The higher 32bit of the start address.
#define AXI_RT_START_ADDR_SUB_HIGH_1_REG_OFFSET 0x68

// The higher 32bit of the start address.
#define AXI_RT_START_ADDR_SUB_HIGH_2_REG_OFFSET 0x6c

// The higher 32bit of the start address.
#define AXI_RT_START_ADDR_SUB_HIGH_3_REG_OFFSET 0x70

// The higher 32bit of the start address.
#define AXI_RT_START_ADDR_SUB_HIGH_4_REG_OFFSET 0x74

// The higher 32bit of the start address.
#define AXI_RT_START_ADDR_SUB_HIGH_5_REG_OFFSET 0x78

// The higher 32bit of the start address.
#define AXI_RT_START_ADDR_SUB_HIGH_6_REG_OFFSET 0x7c

// The higher 32bit of the start address.
#define AXI_RT_START_ADDR_SUB_HIGH_7_REG_OFFSET 0x80

// The higher 32bit of the start address.
#define AXI_RT_START_ADDR_SUB_HIGH_8_REG_OFFSET 0x84

// The higher 32bit of the start address.
#define AXI_RT_START_ADDR_SUB_HIGH_9_REG_OFFSET 0x88

// The higher 32bit of the start address.
#define AXI_RT_START_ADDR_SUB_HIGH_10_REG_OFFSET 0x8c

// The higher 32bit of the start address.
#define AXI_RT_START_ADDR_SUB_HIGH_11_REG_OFFSET 0x90

// The higher 32bit of the start address.
#define AXI_RT_START_ADDR_SUB_HIGH_12_REG_OFFSET 0x94

// The higher 32bit of the start address.
#define AXI_RT_START_ADDR_SUB_HIGH_13_REG_OFFSET 0x98

// The higher 32bit of the start address.
#define AXI_RT_START_ADDR_SUB_HIGH_14_REG_OFFSET 0x9c

// The higher 32bit of the start address.
#define AXI_RT_START_ADDR_SUB_HIGH_15_REG_OFFSET 0xa0

// The lower 32bit of the end address. (common parameters)
#define AXI_RT_END_ADDR_SUB_LOW_WRITE_BUDGET_FIELD_WIDTH 32
#define AXI_RT_END_ADDR_SUB_LOW_WRITE_BUDGET_FIELDS_PER_REG 1
#define AXI_RT_END_ADDR_SUB_LOW_MULTIREG_COUNT 16

// The lower 32bit of the end address.
#define AXI_RT_END_ADDR_SUB_LOW_0_REG_OFFSET 0xa4

// The lower 32bit of the end address.
#define AXI_RT_END_ADDR_SUB_LOW_1_REG_OFFSET 0xa8

// The lower 32bit of the end address.
#define AXI_RT_END_ADDR_SUB_LOW_2_REG_OFFSET 0xac

// The lower 32bit of the end address.
#define AXI_RT_END_ADDR_SUB_LOW_3_REG_OFFSET 0xb0

// The lower 32bit of the end address.
#define AXI_RT_END_ADDR_SUB_LOW_4_REG_OFFSET 0xb4

// The lower 32bit of the end address.
#define AXI_RT_END_ADDR_SUB_LOW_5_REG_OFFSET 0xb8

// The lower 32bit of the end address.
#define AXI_RT_END_ADDR_SUB_LOW_6_REG_OFFSET 0xbc

// The lower 32bit of the end address.
#define AXI_RT_END_ADDR_SUB_LOW_7_REG_OFFSET 0xc0

// The lower 32bit of the end address.
#define AXI_RT_END_ADDR_SUB_LOW_8_REG_OFFSET 0xc4

// The lower 32bit of the end address.
#define AXI_RT_END_ADDR_SUB_LOW_9_REG_OFFSET 0xc8

// The lower 32bit of the end address.
#define AXI_RT_END_ADDR_SUB_LOW_10_REG_OFFSET 0xcc

// The lower 32bit of the end address.
#define AXI_RT_END_ADDR_SUB_LOW_11_REG_OFFSET 0xd0

// The lower 32bit of the end address.
#define AXI_RT_END_ADDR_SUB_LOW_12_REG_OFFSET 0xd4

// The lower 32bit of the end address.
#define AXI_RT_END_ADDR_SUB_LOW_13_REG_OFFSET 0xd8

// The lower 32bit of the end address.
#define AXI_RT_END_ADDR_SUB_LOW_14_REG_OFFSET 0xdc

// The lower 32bit of the end address.
#define AXI_RT_END_ADDR_SUB_LOW_15_REG_OFFSET 0xe0

// The higher 32bit of the end address. (common parameters)
#define AXI_RT_END_ADDR_SUB_HIGH_WRITE_BUDGET_FIELD_WIDTH 32
#define AXI_RT_END_ADDR_SUB_HIGH_WRITE_BUDGET_FIELDS_PER_REG 1
#define AXI_RT_END_ADDR_SUB_HIGH_MULTIREG_COUNT 16

// The higher 32bit of the end address.
#define AXI_RT_END_ADDR_SUB_HIGH_0_REG_OFFSET 0xe4

// The higher 32bit of the end address.
#define AXI_RT_END_ADDR_SUB_HIGH_1_REG_OFFSET 0xe8

// The higher 32bit of the end address.
#define AXI_RT_END_ADDR_SUB_HIGH_2_REG_OFFSET 0xec

// The higher 32bit of the end address.
#define AXI_RT_END_ADDR_SUB_HIGH_3_REG_OFFSET 0xf0

// The higher 32bit of the end address.
#define AXI_RT_END_ADDR_SUB_HIGH_4_REG_OFFSET 0xf4

// The higher 32bit of the end address.
#define AXI_RT_END_ADDR_SUB_HIGH_5_REG_OFFSET 0xf8

// The higher 32bit of the end address.
#define AXI_RT_END_ADDR_SUB_HIGH_6_REG_OFFSET 0xfc

// The higher 32bit of the end address.
#define AXI_RT_END_ADDR_SUB_HIGH_7_REG_OFFSET 0x100

// The higher 32bit of the end address.
#define AXI_RT_END_ADDR_SUB_HIGH_8_REG_OFFSET 0x104

// The higher 32bit of the end address.
#define AXI_RT_END_ADDR_SUB_HIGH_9_REG_OFFSET 0x108

// The higher 32bit of the end address.
#define AXI_RT_END_ADDR_SUB_HIGH_10_REG_OFFSET 0x10c

// The higher 32bit of the end address.
#define AXI_RT_END_ADDR_SUB_HIGH_11_REG_OFFSET 0x110

// The higher 32bit of the end address.
#define AXI_RT_END_ADDR_SUB_HIGH_12_REG_OFFSET 0x114

// The higher 32bit of the end address.
#define AXI_RT_END_ADDR_SUB_HIGH_13_REG_OFFSET 0x118

// The higher 32bit of the end address.
#define AXI_RT_END_ADDR_SUB_HIGH_14_REG_OFFSET 0x11c

// The higher 32bit of the end address.
#define AXI_RT_END_ADDR_SUB_HIGH_15_REG_OFFSET 0x120

// The budget for writes. (common parameters)
#define AXI_RT_WRITE_BUDGET_WRITE_BUDGET_FIELD_WIDTH 32
#define AXI_RT_WRITE_BUDGET_WRITE_BUDGET_FIELDS_PER_REG 1
#define AXI_RT_WRITE_BUDGET_MULTIREG_COUNT 16

// The budget for writes.
#define AXI_RT_WRITE_BUDGET_0_REG_OFFSET 0x124

// The budget for writes.
#define AXI_RT_WRITE_BUDGET_1_REG_OFFSET 0x128

// The budget for writes.
#define AXI_RT_WRITE_BUDGET_2_REG_OFFSET 0x12c

// The budget for writes.
#define AXI_RT_WRITE_BUDGET_3_REG_OFFSET 0x130

// The budget for writes.
#define AXI_RT_WRITE_BUDGET_4_REG_OFFSET 0x134

// The budget for writes.
#define AXI_RT_WRITE_BUDGET_5_REG_OFFSET 0x138

// The budget for writes.
#define AXI_RT_WRITE_BUDGET_6_REG_OFFSET 0x13c

// The budget for writes.
#define AXI_RT_WRITE_BUDGET_7_REG_OFFSET 0x140

// The budget for writes.
#define AXI_RT_WRITE_BUDGET_8_REG_OFFSET 0x144

// The budget for writes.
#define AXI_RT_WRITE_BUDGET_9_REG_OFFSET 0x148

// The budget for writes.
#define AXI_RT_WRITE_BUDGET_10_REG_OFFSET 0x14c

// The budget for writes.
#define AXI_RT_WRITE_BUDGET_11_REG_OFFSET 0x150

// The budget for writes.
#define AXI_RT_WRITE_BUDGET_12_REG_OFFSET 0x154

// The budget for writes.
#define AXI_RT_WRITE_BUDGET_13_REG_OFFSET 0x158

// The budget for writes.
#define AXI_RT_WRITE_BUDGET_14_REG_OFFSET 0x15c

// The budget for writes.
#define AXI_RT_WRITE_BUDGET_15_REG_OFFSET 0x160

// The budget for reads. (common parameters)
#define AXI_RT_READ_BUDGET_READ_BUDGET_FIELD_WIDTH 32
#define AXI_RT_READ_BUDGET_READ_BUDGET_FIELDS_PER_REG 1
#define AXI_RT_READ_BUDGET_MULTIREG_COUNT 16

// The budget for reads.
#define AXI_RT_READ_BUDGET_0_REG_OFFSET 0x164

// The budget for reads.
#define AXI_RT_READ_BUDGET_1_REG_OFFSET 0x168

// The budget for reads.
#define AXI_RT_READ_BUDGET_2_REG_OFFSET 0x16c

// The budget for reads.
#define AXI_RT_READ_BUDGET_3_REG_OFFSET 0x170

// The budget for reads.
#define AXI_RT_READ_BUDGET_4_REG_OFFSET 0x174

// The budget for reads.
#define AXI_RT_READ_BUDGET_5_REG_OFFSET 0x178

// The budget for reads.
#define AXI_RT_READ_BUDGET_6_REG_OFFSET 0x17c

// The budget for reads.
#define AXI_RT_READ_BUDGET_7_REG_OFFSET 0x180

// The budget for reads.
#define AXI_RT_READ_BUDGET_8_REG_OFFSET 0x184

// The budget for reads.
#define AXI_RT_READ_BUDGET_9_REG_OFFSET 0x188

// The budget for reads.
#define AXI_RT_READ_BUDGET_10_REG_OFFSET 0x18c

// The budget for reads.
#define AXI_RT_READ_BUDGET_11_REG_OFFSET 0x190

// The budget for reads.
#define AXI_RT_READ_BUDGET_12_REG_OFFSET 0x194

// The budget for reads.
#define AXI_RT_READ_BUDGET_13_REG_OFFSET 0x198

// The budget for reads.
#define AXI_RT_READ_BUDGET_14_REG_OFFSET 0x19c

// The budget for reads.
#define AXI_RT_READ_BUDGET_15_REG_OFFSET 0x1a0

// The period for writes. (common parameters)
#define AXI_RT_WRITE_PERIOD_WRITE_PERIOD_FIELD_WIDTH 32
#define AXI_RT_WRITE_PERIOD_WRITE_PERIOD_FIELDS_PER_REG 1
#define AXI_RT_WRITE_PERIOD_MULTIREG_COUNT 16

// The period for writes.
#define AXI_RT_WRITE_PERIOD_0_REG_OFFSET 0x1a4

// The period for writes.
#define AXI_RT_WRITE_PERIOD_1_REG_OFFSET 0x1a8

// The period for writes.
#define AXI_RT_WRITE_PERIOD_2_REG_OFFSET 0x1ac

// The period for writes.
#define AXI_RT_WRITE_PERIOD_3_REG_OFFSET 0x1b0

// The period for writes.
#define AXI_RT_WRITE_PERIOD_4_REG_OFFSET 0x1b4

// The period for writes.
#define AXI_RT_WRITE_PERIOD_5_REG_OFFSET 0x1b8

// The period for writes.
#define AXI_RT_WRITE_PERIOD_6_REG_OFFSET 0x1bc

// The period for writes.
#define AXI_RT_WRITE_PERIOD_7_REG_OFFSET 0x1c0

// The period for writes.
#define AXI_RT_WRITE_PERIOD_8_REG_OFFSET 0x1c4

// The period for writes.
#define AXI_RT_WRITE_PERIOD_9_REG_OFFSET 0x1c8

// The period for writes.
#define AXI_RT_WRITE_PERIOD_10_REG_OFFSET 0x1cc

// The period for writes.
#define AXI_RT_WRITE_PERIOD_11_REG_OFFSET 0x1d0

// The period for writes.
#define AXI_RT_WRITE_PERIOD_12_REG_OFFSET 0x1d4

// The period for writes.
#define AXI_RT_WRITE_PERIOD_13_REG_OFFSET 0x1d8

// The period for writes.
#define AXI_RT_WRITE_PERIOD_14_REG_OFFSET 0x1dc

// The period for writes.
#define AXI_RT_WRITE_PERIOD_15_REG_OFFSET 0x1e0

// The period for reads. (common parameters)
#define AXI_RT_READ_PERIOD_READ_PERIOD_FIELD_WIDTH 32
#define AXI_RT_READ_PERIOD_READ_PERIOD_FIELDS_PER_REG 1
#define AXI_RT_READ_PERIOD_MULTIREG_COUNT 16

// The period for reads.
#define AXI_RT_READ_PERIOD_0_REG_OFFSET 0x1e4

// The period for reads.
#define AXI_RT_READ_PERIOD_1_REG_OFFSET 0x1e8

// The period for reads.
#define AXI_RT_READ_PERIOD_2_REG_OFFSET 0x1ec

// The period for reads.
#define AXI_RT_READ_PERIOD_3_REG_OFFSET 0x1f0

// The period for reads.
#define AXI_RT_READ_PERIOD_4_REG_OFFSET 0x1f4

// The period for reads.
#define AXI_RT_READ_PERIOD_5_REG_OFFSET 0x1f8

// The period for reads.
#define AXI_RT_READ_PERIOD_6_REG_OFFSET 0x1fc

// The period for reads.
#define AXI_RT_READ_PERIOD_7_REG_OFFSET 0x200

// The period for reads.
#define AXI_RT_READ_PERIOD_8_REG_OFFSET 0x204

// The period for reads.
#define AXI_RT_READ_PERIOD_9_REG_OFFSET 0x208

// The period for reads.
#define AXI_RT_READ_PERIOD_10_REG_OFFSET 0x20c

// The period for reads.
#define AXI_RT_READ_PERIOD_11_REG_OFFSET 0x210

// The period for reads.
#define AXI_RT_READ_PERIOD_12_REG_OFFSET 0x214

// The period for reads.
#define AXI_RT_READ_PERIOD_13_REG_OFFSET 0x218

// The period for reads.
#define AXI_RT_READ_PERIOD_14_REG_OFFSET 0x21c

// The period for reads.
#define AXI_RT_READ_PERIOD_15_REG_OFFSET 0x220

// The budget left for writes. (common parameters)
#define AXI_RT_WRITE_BUDGET_LEFT_WRITE_BUDGET_LEFT_FIELD_WIDTH 32
#define AXI_RT_WRITE_BUDGET_LEFT_WRITE_BUDGET_LEFT_FIELDS_PER_REG 1
#define AXI_RT_WRITE_BUDGET_LEFT_MULTIREG_COUNT 16

// The budget left for writes.
#define AXI_RT_WRITE_BUDGET_LEFT_0_REG_OFFSET 0x224

// The budget left for writes.
#define AXI_RT_WRITE_BUDGET_LEFT_1_REG_OFFSET 0x228

// The budget left for writes.
#define AXI_RT_WRITE_BUDGET_LEFT_2_REG_OFFSET 0x22c

// The budget left for writes.
#define AXI_RT_WRITE_BUDGET_LEFT_3_REG_OFFSET 0x230

// The budget left for writes.
#define AXI_RT_WRITE_BUDGET_LEFT_4_REG_OFFSET 0x234

// The budget left for writes.
#define AXI_RT_WRITE_BUDGET_LEFT_5_REG_OFFSET 0x238

// The budget left for writes.
#define AXI_RT_WRITE_BUDGET_LEFT_6_REG_OFFSET 0x23c

// The budget left for writes.
#define AXI_RT_WRITE_BUDGET_LEFT_7_REG_OFFSET 0x240

// The budget left for writes.
#define AXI_RT_WRITE_BUDGET_LEFT_8_REG_OFFSET 0x244

// The budget left for writes.
#define AXI_RT_WRITE_BUDGET_LEFT_9_REG_OFFSET 0x248

// The budget left for writes.
#define AXI_RT_WRITE_BUDGET_LEFT_10_REG_OFFSET 0x24c

// The budget left for writes.
#define AXI_RT_WRITE_BUDGET_LEFT_11_REG_OFFSET 0x250

// The budget left for writes.
#define AXI_RT_WRITE_BUDGET_LEFT_12_REG_OFFSET 0x254

// The budget left for writes.
#define AXI_RT_WRITE_BUDGET_LEFT_13_REG_OFFSET 0x258

// The budget left for writes.
#define AXI_RT_WRITE_BUDGET_LEFT_14_REG_OFFSET 0x25c

// The budget left for writes.
#define AXI_RT_WRITE_BUDGET_LEFT_15_REG_OFFSET 0x260

// The budget left for reads. (common parameters)
#define AXI_RT_READ_BUDGET_LEFT_READ_BUDGET_LEFT_FIELD_WIDTH 32
#define AXI_RT_READ_BUDGET_LEFT_READ_BUDGET_LEFT_FIELDS_PER_REG 1
#define AXI_RT_READ_BUDGET_LEFT_MULTIREG_COUNT 16

// The budget left for reads.
#define AXI_RT_READ_BUDGET_LEFT_0_REG_OFFSET 0x264

// The budget left for reads.
#define AXI_RT_READ_BUDGET_LEFT_1_REG_OFFSET 0x268

// The budget left for reads.
#define AXI_RT_READ_BUDGET_LEFT_2_REG_OFFSET 0x26c

// The budget left for reads.
#define AXI_RT_READ_BUDGET_LEFT_3_REG_OFFSET 0x270

// The budget left for reads.
#define AXI_RT_READ_BUDGET_LEFT_4_REG_OFFSET 0x274

// The budget left for reads.
#define AXI_RT_READ_BUDGET_LEFT_5_REG_OFFSET 0x278

// The budget left for reads.
#define AXI_RT_READ_BUDGET_LEFT_6_REG_OFFSET 0x27c

// The budget left for reads.
#define AXI_RT_READ_BUDGET_LEFT_7_REG_OFFSET 0x280

// The budget left for reads.
#define AXI_RT_READ_BUDGET_LEFT_8_REG_OFFSET 0x284

// The budget left for reads.
#define AXI_RT_READ_BUDGET_LEFT_9_REG_OFFSET 0x288

// The budget left for reads.
#define AXI_RT_READ_BUDGET_LEFT_10_REG_OFFSET 0x28c

// The budget left for reads.
#define AXI_RT_READ_BUDGET_LEFT_11_REG_OFFSET 0x290

// The budget left for reads.
#define AXI_RT_READ_BUDGET_LEFT_12_REG_OFFSET 0x294

// The budget left for reads.
#define AXI_RT_READ_BUDGET_LEFT_13_REG_OFFSET 0x298

// The budget left for reads.
#define AXI_RT_READ_BUDGET_LEFT_14_REG_OFFSET 0x29c

// The budget left for reads.
#define AXI_RT_READ_BUDGET_LEFT_15_REG_OFFSET 0x2a0

// The period left for writes. (common parameters)
#define AXI_RT_WRITE_PERIOD_LEFT_WRITE_PERIOD_LEFT_FIELD_WIDTH 32
#define AXI_RT_WRITE_PERIOD_LEFT_WRITE_PERIOD_LEFT_FIELDS_PER_REG 1
#define AXI_RT_WRITE_PERIOD_LEFT_MULTIREG_COUNT 16

// The period left for writes.
#define AXI_RT_WRITE_PERIOD_LEFT_0_REG_OFFSET 0x2a4

// The period left for writes.
#define AXI_RT_WRITE_PERIOD_LEFT_1_REG_OFFSET 0x2a8

// The period left for writes.
#define AXI_RT_WRITE_PERIOD_LEFT_2_REG_OFFSET 0x2ac

// The period left for writes.
#define AXI_RT_WRITE_PERIOD_LEFT_3_REG_OFFSET 0x2b0

// The period left for writes.
#define AXI_RT_WRITE_PERIOD_LEFT_4_REG_OFFSET 0x2b4

// The period left for writes.
#define AXI_RT_WRITE_PERIOD_LEFT_5_REG_OFFSET 0x2b8

// The period left for writes.
#define AXI_RT_WRITE_PERIOD_LEFT_6_REG_OFFSET 0x2bc

// The period left for writes.
#define AXI_RT_WRITE_PERIOD_LEFT_7_REG_OFFSET 0x2c0

// The period left for writes.
#define AXI_RT_WRITE_PERIOD_LEFT_8_REG_OFFSET 0x2c4

// The period left for writes.
#define AXI_RT_WRITE_PERIOD_LEFT_9_REG_OFFSET 0x2c8

// The period left for writes.
#define AXI_RT_WRITE_PERIOD_LEFT_10_REG_OFFSET 0x2cc

// The period left for writes.
#define AXI_RT_WRITE_PERIOD_LEFT_11_REG_OFFSET 0x2d0

// The period left for writes.
#define AXI_RT_WRITE_PERIOD_LEFT_12_REG_OFFSET 0x2d4

// The period left for writes.
#define AXI_RT_WRITE_PERIOD_LEFT_13_REG_OFFSET 0x2d8

// The period left for writes.
#define AXI_RT_WRITE_PERIOD_LEFT_14_REG_OFFSET 0x2dc

// The period left for writes.
#define AXI_RT_WRITE_PERIOD_LEFT_15_REG_OFFSET 0x2e0

// The period left for reads. (common parameters)
#define AXI_RT_READ_PERIOD_LEFT_READ_PERIOD_LEFT_FIELD_WIDTH 32
#define AXI_RT_READ_PERIOD_LEFT_READ_PERIOD_LEFT_FIELDS_PER_REG 1
#define AXI_RT_READ_PERIOD_LEFT_MULTIREG_COUNT 16

// The period left for reads.
#define AXI_RT_READ_PERIOD_LEFT_0_REG_OFFSET 0x2e4

// The period left for reads.
#define AXI_RT_READ_PERIOD_LEFT_1_REG_OFFSET 0x2e8

// The period left for reads.
#define AXI_RT_READ_PERIOD_LEFT_2_REG_OFFSET 0x2ec

// The period left for reads.
#define AXI_RT_READ_PERIOD_LEFT_3_REG_OFFSET 0x2f0

// The period left for reads.
#define AXI_RT_READ_PERIOD_LEFT_4_REG_OFFSET 0x2f4

// The period left for reads.
#define AXI_RT_READ_PERIOD_LEFT_5_REG_OFFSET 0x2f8

// The period left for reads.
#define AXI_RT_READ_PERIOD_LEFT_6_REG_OFFSET 0x2fc

// The period left for reads.
#define AXI_RT_READ_PERIOD_LEFT_7_REG_OFFSET 0x300

// The period left for reads.
#define AXI_RT_READ_PERIOD_LEFT_8_REG_OFFSET 0x304

// The period left for reads.
#define AXI_RT_READ_PERIOD_LEFT_9_REG_OFFSET 0x308

// The period left for reads.
#define AXI_RT_READ_PERIOD_LEFT_10_REG_OFFSET 0x30c

// The period left for reads.
#define AXI_RT_READ_PERIOD_LEFT_11_REG_OFFSET 0x310

// The period left for reads.
#define AXI_RT_READ_PERIOD_LEFT_12_REG_OFFSET 0x314

// The period left for reads.
#define AXI_RT_READ_PERIOD_LEFT_13_REG_OFFSET 0x318

// The period left for reads.
#define AXI_RT_READ_PERIOD_LEFT_14_REG_OFFSET 0x31c

// The period left for reads.
#define AXI_RT_READ_PERIOD_LEFT_15_REG_OFFSET 0x320

// Is the interface requested to be isolated? (common parameters)
#define AXI_RT_ISOLATE_ISOLATE_FIELD_WIDTH 1
#define AXI_RT_ISOLATE_ISOLATE_FIELDS_PER_REG 32
#define AXI_RT_ISOLATE_MULTIREG_COUNT 1

// Is the interface requested to be isolated?
#define AXI_RT_ISOLATE_REG_OFFSET 0x324
#define AXI_RT_ISOLATE_ISOLATE_0_BIT 0
#define AXI_RT_ISOLATE_ISOLATE_1_BIT 1
#define AXI_RT_ISOLATE_ISOLATE_2_BIT 2
#define AXI_RT_ISOLATE_ISOLATE_3_BIT 3
#define AXI_RT_ISOLATE_ISOLATE_4_BIT 4
#define AXI_RT_ISOLATE_ISOLATE_5_BIT 5
#define AXI_RT_ISOLATE_ISOLATE_6_BIT 6
#define AXI_RT_ISOLATE_ISOLATE_7_BIT 7

// Is the interface isolated? (common parameters)
#define AXI_RT_ISOLATED_ISOLATED_FIELD_WIDTH 1
#define AXI_RT_ISOLATED_ISOLATED_FIELDS_PER_REG 32
#define AXI_RT_ISOLATED_MULTIREG_COUNT 1

// Is the interface isolated?
#define AXI_RT_ISOLATED_REG_OFFSET 0x328
#define AXI_RT_ISOLATED_ISOLATED_0_BIT 0
#define AXI_RT_ISOLATED_ISOLATED_1_BIT 1
#define AXI_RT_ISOLATED_ISOLATED_2_BIT 2
#define AXI_RT_ISOLATED_ISOLATED_3_BIT 3
#define AXI_RT_ISOLATED_ISOLATED_4_BIT 4
#define AXI_RT_ISOLATED_ISOLATED_5_BIT 5
#define AXI_RT_ISOLATED_ISOLATED_6_BIT 6
#define AXI_RT_ISOLATED_ISOLATED_7_BIT 7

// Value of the num_managers parameter.
#define AXI_RT_NUM_MANAGERS_REG_OFFSET 0x32c

// Value of the addr_width parameter.
#define AXI_RT_ADDR_WIDTH_REG_OFFSET 0x330

// Value of the data_width parameter.
#define AXI_RT_DATA_WIDTH_REG_OFFSET 0x334

// Value of the id_width parameter.
#define AXI_RT_ID_WIDTH_REG_OFFSET 0x338

// Value of the user_width parameter.
#define AXI_RT_USER_WIDTH_REG_OFFSET 0x33c

// Value of the num_pending parameter.
#define AXI_RT_NUM_PENDING_REG_OFFSET 0x340

// Value of the w_buffer_depth parameter.
#define AXI_RT_W_BUFFER_DEPTH_REG_OFFSET 0x344

// Value of the num_addr_regions parameter.
#define AXI_RT_NUM_ADDR_REGIONS_REG_OFFSET 0x348

// Value of the period_width parameter.
#define AXI_RT_PERIOD_WIDTH_REG_OFFSET 0x34c

// Value of the budget_width parameter.
#define AXI_RT_BUDGET_WIDTH_REG_OFFSET 0x350

// Value of the max_num_managers parameter.
#define AXI_RT_MAX_NUM_MANAGERS_REG_OFFSET 0x354

#ifdef __cplusplus
}  // extern "C"
#endif
#endif  // _AXI_RT_REG_DEFS_
// End generated register defines for axi_rt