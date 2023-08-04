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
#define AXI_RT_PARAM_NUM_MRG 16

// Configured number of subordinate regions.
#define AXI_RT_PARAM_NUM_SUB 2

// Configured number of required registers.
#define AXI_RT_PARAM_NUM_REG 32

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
#define AXI_RT_RT_ENABLE_ENABLE_8_BIT 8
#define AXI_RT_RT_ENABLE_ENABLE_9_BIT 9
#define AXI_RT_RT_ENABLE_ENABLE_10_BIT 10
#define AXI_RT_RT_ENABLE_ENABLE_11_BIT 11
#define AXI_RT_RT_ENABLE_ENABLE_12_BIT 12
#define AXI_RT_RT_ENABLE_ENABLE_13_BIT 13
#define AXI_RT_RT_ENABLE_ENABLE_14_BIT 14
#define AXI_RT_RT_ENABLE_ENABLE_15_BIT 15

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
#define AXI_RT_RT_BYPASSED_BYPASSED_8_BIT 8
#define AXI_RT_RT_BYPASSED_BYPASSED_9_BIT 9
#define AXI_RT_RT_BYPASSED_BYPASSED_10_BIT 10
#define AXI_RT_RT_BYPASSED_BYPASSED_11_BIT 11
#define AXI_RT_RT_BYPASSED_BYPASSED_12_BIT 12
#define AXI_RT_RT_BYPASSED_BYPASSED_13_BIT 13
#define AXI_RT_RT_BYPASSED_BYPASSED_14_BIT 14
#define AXI_RT_RT_BYPASSED_BYPASSED_15_BIT 15

// Fragmentation of the bursts in beats. (common parameters)
#define AXI_RT_LEN_LIMIT_LEN_FIELD_WIDTH 8
#define AXI_RT_LEN_LIMIT_LEN_FIELDS_PER_REG 4
#define AXI_RT_LEN_LIMIT_MULTIREG_COUNT 4

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

// Fragmentation of the bursts in beats.
#define AXI_RT_LEN_LIMIT_2_REG_OFFSET 0x1c
#define AXI_RT_LEN_LIMIT_2_LEN_8_MASK 0xff
#define AXI_RT_LEN_LIMIT_2_LEN_8_OFFSET 0
#define AXI_RT_LEN_LIMIT_2_LEN_8_FIELD \
  ((bitfield_field32_t) { .mask = AXI_RT_LEN_LIMIT_2_LEN_8_MASK, .index = AXI_RT_LEN_LIMIT_2_LEN_8_OFFSET })
#define AXI_RT_LEN_LIMIT_2_LEN_9_MASK 0xff
#define AXI_RT_LEN_LIMIT_2_LEN_9_OFFSET 8
#define AXI_RT_LEN_LIMIT_2_LEN_9_FIELD \
  ((bitfield_field32_t) { .mask = AXI_RT_LEN_LIMIT_2_LEN_9_MASK, .index = AXI_RT_LEN_LIMIT_2_LEN_9_OFFSET })
#define AXI_RT_LEN_LIMIT_2_LEN_10_MASK 0xff
#define AXI_RT_LEN_LIMIT_2_LEN_10_OFFSET 16
#define AXI_RT_LEN_LIMIT_2_LEN_10_FIELD \
  ((bitfield_field32_t) { .mask = AXI_RT_LEN_LIMIT_2_LEN_10_MASK, .index = AXI_RT_LEN_LIMIT_2_LEN_10_OFFSET })
#define AXI_RT_LEN_LIMIT_2_LEN_11_MASK 0xff
#define AXI_RT_LEN_LIMIT_2_LEN_11_OFFSET 24
#define AXI_RT_LEN_LIMIT_2_LEN_11_FIELD \
  ((bitfield_field32_t) { .mask = AXI_RT_LEN_LIMIT_2_LEN_11_MASK, .index = AXI_RT_LEN_LIMIT_2_LEN_11_OFFSET })

// Fragmentation of the bursts in beats.
#define AXI_RT_LEN_LIMIT_3_REG_OFFSET 0x20
#define AXI_RT_LEN_LIMIT_3_LEN_12_MASK 0xff
#define AXI_RT_LEN_LIMIT_3_LEN_12_OFFSET 0
#define AXI_RT_LEN_LIMIT_3_LEN_12_FIELD \
  ((bitfield_field32_t) { .mask = AXI_RT_LEN_LIMIT_3_LEN_12_MASK, .index = AXI_RT_LEN_LIMIT_3_LEN_12_OFFSET })
#define AXI_RT_LEN_LIMIT_3_LEN_13_MASK 0xff
#define AXI_RT_LEN_LIMIT_3_LEN_13_OFFSET 8
#define AXI_RT_LEN_LIMIT_3_LEN_13_FIELD \
  ((bitfield_field32_t) { .mask = AXI_RT_LEN_LIMIT_3_LEN_13_MASK, .index = AXI_RT_LEN_LIMIT_3_LEN_13_OFFSET })
#define AXI_RT_LEN_LIMIT_3_LEN_14_MASK 0xff
#define AXI_RT_LEN_LIMIT_3_LEN_14_OFFSET 16
#define AXI_RT_LEN_LIMIT_3_LEN_14_FIELD \
  ((bitfield_field32_t) { .mask = AXI_RT_LEN_LIMIT_3_LEN_14_MASK, .index = AXI_RT_LEN_LIMIT_3_LEN_14_OFFSET })
#define AXI_RT_LEN_LIMIT_3_LEN_15_MASK 0xff
#define AXI_RT_LEN_LIMIT_3_LEN_15_OFFSET 24
#define AXI_RT_LEN_LIMIT_3_LEN_15_FIELD \
  ((bitfield_field32_t) { .mask = AXI_RT_LEN_LIMIT_3_LEN_15_MASK, .index = AXI_RT_LEN_LIMIT_3_LEN_15_OFFSET })

// Enables the IMTU. (common parameters)
#define AXI_RT_IMTU_ENABLE_ENABLE_FIELD_WIDTH 1
#define AXI_RT_IMTU_ENABLE_ENABLE_FIELDS_PER_REG 32
#define AXI_RT_IMTU_ENABLE_MULTIREG_COUNT 1

// Enables the IMTU.
#define AXI_RT_IMTU_ENABLE_REG_OFFSET 0x24
#define AXI_RT_IMTU_ENABLE_ENABLE_0_BIT 0
#define AXI_RT_IMTU_ENABLE_ENABLE_1_BIT 1
#define AXI_RT_IMTU_ENABLE_ENABLE_2_BIT 2
#define AXI_RT_IMTU_ENABLE_ENABLE_3_BIT 3
#define AXI_RT_IMTU_ENABLE_ENABLE_4_BIT 4
#define AXI_RT_IMTU_ENABLE_ENABLE_5_BIT 5
#define AXI_RT_IMTU_ENABLE_ENABLE_6_BIT 6
#define AXI_RT_IMTU_ENABLE_ENABLE_7_BIT 7
#define AXI_RT_IMTU_ENABLE_ENABLE_8_BIT 8
#define AXI_RT_IMTU_ENABLE_ENABLE_9_BIT 9
#define AXI_RT_IMTU_ENABLE_ENABLE_10_BIT 10
#define AXI_RT_IMTU_ENABLE_ENABLE_11_BIT 11
#define AXI_RT_IMTU_ENABLE_ENABLE_12_BIT 12
#define AXI_RT_IMTU_ENABLE_ENABLE_13_BIT 13
#define AXI_RT_IMTU_ENABLE_ENABLE_14_BIT 14
#define AXI_RT_IMTU_ENABLE_ENABLE_15_BIT 15

// Resets both the period and the budget. (common parameters)
#define AXI_RT_IMTU_ABORT_ABORT_FIELD_WIDTH 1
#define AXI_RT_IMTU_ABORT_ABORT_FIELDS_PER_REG 32
#define AXI_RT_IMTU_ABORT_MULTIREG_COUNT 1

// Resets both the period and the budget.
#define AXI_RT_IMTU_ABORT_REG_OFFSET 0x28
#define AXI_RT_IMTU_ABORT_ABORT_0_BIT 0
#define AXI_RT_IMTU_ABORT_ABORT_1_BIT 1
#define AXI_RT_IMTU_ABORT_ABORT_2_BIT 2
#define AXI_RT_IMTU_ABORT_ABORT_3_BIT 3
#define AXI_RT_IMTU_ABORT_ABORT_4_BIT 4
#define AXI_RT_IMTU_ABORT_ABORT_5_BIT 5
#define AXI_RT_IMTU_ABORT_ABORT_6_BIT 6
#define AXI_RT_IMTU_ABORT_ABORT_7_BIT 7
#define AXI_RT_IMTU_ABORT_ABORT_8_BIT 8
#define AXI_RT_IMTU_ABORT_ABORT_9_BIT 9
#define AXI_RT_IMTU_ABORT_ABORT_10_BIT 10
#define AXI_RT_IMTU_ABORT_ABORT_11_BIT 11
#define AXI_RT_IMTU_ABORT_ABORT_12_BIT 12
#define AXI_RT_IMTU_ABORT_ABORT_13_BIT 13
#define AXI_RT_IMTU_ABORT_ABORT_14_BIT 14
#define AXI_RT_IMTU_ABORT_ABORT_15_BIT 15

// The lower 32bit of the start address. (common parameters)
#define AXI_RT_START_ADDR_SUB_LOW_WRITE_BUDGET_FIELD_WIDTH 32
#define AXI_RT_START_ADDR_SUB_LOW_WRITE_BUDGET_FIELDS_PER_REG 1
#define AXI_RT_START_ADDR_SUB_LOW_MULTIREG_COUNT 32

// The lower 32bit of the start address.
#define AXI_RT_START_ADDR_SUB_LOW_0_REG_OFFSET 0x2c

// The lower 32bit of the start address.
#define AXI_RT_START_ADDR_SUB_LOW_1_REG_OFFSET 0x30

// The lower 32bit of the start address.
#define AXI_RT_START_ADDR_SUB_LOW_2_REG_OFFSET 0x34

// The lower 32bit of the start address.
#define AXI_RT_START_ADDR_SUB_LOW_3_REG_OFFSET 0x38

// The lower 32bit of the start address.
#define AXI_RT_START_ADDR_SUB_LOW_4_REG_OFFSET 0x3c

// The lower 32bit of the start address.
#define AXI_RT_START_ADDR_SUB_LOW_5_REG_OFFSET 0x40

// The lower 32bit of the start address.
#define AXI_RT_START_ADDR_SUB_LOW_6_REG_OFFSET 0x44

// The lower 32bit of the start address.
#define AXI_RT_START_ADDR_SUB_LOW_7_REG_OFFSET 0x48

// The lower 32bit of the start address.
#define AXI_RT_START_ADDR_SUB_LOW_8_REG_OFFSET 0x4c

// The lower 32bit of the start address.
#define AXI_RT_START_ADDR_SUB_LOW_9_REG_OFFSET 0x50

// The lower 32bit of the start address.
#define AXI_RT_START_ADDR_SUB_LOW_10_REG_OFFSET 0x54

// The lower 32bit of the start address.
#define AXI_RT_START_ADDR_SUB_LOW_11_REG_OFFSET 0x58

// The lower 32bit of the start address.
#define AXI_RT_START_ADDR_SUB_LOW_12_REG_OFFSET 0x5c

// The lower 32bit of the start address.
#define AXI_RT_START_ADDR_SUB_LOW_13_REG_OFFSET 0x60

// The lower 32bit of the start address.
#define AXI_RT_START_ADDR_SUB_LOW_14_REG_OFFSET 0x64

// The lower 32bit of the start address.
#define AXI_RT_START_ADDR_SUB_LOW_15_REG_OFFSET 0x68

// The lower 32bit of the start address.
#define AXI_RT_START_ADDR_SUB_LOW_16_REG_OFFSET 0x6c

// The lower 32bit of the start address.
#define AXI_RT_START_ADDR_SUB_LOW_17_REG_OFFSET 0x70

// The lower 32bit of the start address.
#define AXI_RT_START_ADDR_SUB_LOW_18_REG_OFFSET 0x74

// The lower 32bit of the start address.
#define AXI_RT_START_ADDR_SUB_LOW_19_REG_OFFSET 0x78

// The lower 32bit of the start address.
#define AXI_RT_START_ADDR_SUB_LOW_20_REG_OFFSET 0x7c

// The lower 32bit of the start address.
#define AXI_RT_START_ADDR_SUB_LOW_21_REG_OFFSET 0x80

// The lower 32bit of the start address.
#define AXI_RT_START_ADDR_SUB_LOW_22_REG_OFFSET 0x84

// The lower 32bit of the start address.
#define AXI_RT_START_ADDR_SUB_LOW_23_REG_OFFSET 0x88

// The lower 32bit of the start address.
#define AXI_RT_START_ADDR_SUB_LOW_24_REG_OFFSET 0x8c

// The lower 32bit of the start address.
#define AXI_RT_START_ADDR_SUB_LOW_25_REG_OFFSET 0x90

// The lower 32bit of the start address.
#define AXI_RT_START_ADDR_SUB_LOW_26_REG_OFFSET 0x94

// The lower 32bit of the start address.
#define AXI_RT_START_ADDR_SUB_LOW_27_REG_OFFSET 0x98

// The lower 32bit of the start address.
#define AXI_RT_START_ADDR_SUB_LOW_28_REG_OFFSET 0x9c

// The lower 32bit of the start address.
#define AXI_RT_START_ADDR_SUB_LOW_29_REG_OFFSET 0xa0

// The lower 32bit of the start address.
#define AXI_RT_START_ADDR_SUB_LOW_30_REG_OFFSET 0xa4

// The lower 32bit of the start address.
#define AXI_RT_START_ADDR_SUB_LOW_31_REG_OFFSET 0xa8

// The higher 32bit of the start address. (common parameters)
#define AXI_RT_START_ADDR_SUB_HIGH_WRITE_BUDGET_FIELD_WIDTH 32
#define AXI_RT_START_ADDR_SUB_HIGH_WRITE_BUDGET_FIELDS_PER_REG 1
#define AXI_RT_START_ADDR_SUB_HIGH_MULTIREG_COUNT 32

// The higher 32bit of the start address.
#define AXI_RT_START_ADDR_SUB_HIGH_0_REG_OFFSET 0xac

// The higher 32bit of the start address.
#define AXI_RT_START_ADDR_SUB_HIGH_1_REG_OFFSET 0xb0

// The higher 32bit of the start address.
#define AXI_RT_START_ADDR_SUB_HIGH_2_REG_OFFSET 0xb4

// The higher 32bit of the start address.
#define AXI_RT_START_ADDR_SUB_HIGH_3_REG_OFFSET 0xb8

// The higher 32bit of the start address.
#define AXI_RT_START_ADDR_SUB_HIGH_4_REG_OFFSET 0xbc

// The higher 32bit of the start address.
#define AXI_RT_START_ADDR_SUB_HIGH_5_REG_OFFSET 0xc0

// The higher 32bit of the start address.
#define AXI_RT_START_ADDR_SUB_HIGH_6_REG_OFFSET 0xc4

// The higher 32bit of the start address.
#define AXI_RT_START_ADDR_SUB_HIGH_7_REG_OFFSET 0xc8

// The higher 32bit of the start address.
#define AXI_RT_START_ADDR_SUB_HIGH_8_REG_OFFSET 0xcc

// The higher 32bit of the start address.
#define AXI_RT_START_ADDR_SUB_HIGH_9_REG_OFFSET 0xd0

// The higher 32bit of the start address.
#define AXI_RT_START_ADDR_SUB_HIGH_10_REG_OFFSET 0xd4

// The higher 32bit of the start address.
#define AXI_RT_START_ADDR_SUB_HIGH_11_REG_OFFSET 0xd8

// The higher 32bit of the start address.
#define AXI_RT_START_ADDR_SUB_HIGH_12_REG_OFFSET 0xdc

// The higher 32bit of the start address.
#define AXI_RT_START_ADDR_SUB_HIGH_13_REG_OFFSET 0xe0

// The higher 32bit of the start address.
#define AXI_RT_START_ADDR_SUB_HIGH_14_REG_OFFSET 0xe4

// The higher 32bit of the start address.
#define AXI_RT_START_ADDR_SUB_HIGH_15_REG_OFFSET 0xe8

// The higher 32bit of the start address.
#define AXI_RT_START_ADDR_SUB_HIGH_16_REG_OFFSET 0xec

// The higher 32bit of the start address.
#define AXI_RT_START_ADDR_SUB_HIGH_17_REG_OFFSET 0xf0

// The higher 32bit of the start address.
#define AXI_RT_START_ADDR_SUB_HIGH_18_REG_OFFSET 0xf4

// The higher 32bit of the start address.
#define AXI_RT_START_ADDR_SUB_HIGH_19_REG_OFFSET 0xf8

// The higher 32bit of the start address.
#define AXI_RT_START_ADDR_SUB_HIGH_20_REG_OFFSET 0xfc

// The higher 32bit of the start address.
#define AXI_RT_START_ADDR_SUB_HIGH_21_REG_OFFSET 0x100

// The higher 32bit of the start address.
#define AXI_RT_START_ADDR_SUB_HIGH_22_REG_OFFSET 0x104

// The higher 32bit of the start address.
#define AXI_RT_START_ADDR_SUB_HIGH_23_REG_OFFSET 0x108

// The higher 32bit of the start address.
#define AXI_RT_START_ADDR_SUB_HIGH_24_REG_OFFSET 0x10c

// The higher 32bit of the start address.
#define AXI_RT_START_ADDR_SUB_HIGH_25_REG_OFFSET 0x110

// The higher 32bit of the start address.
#define AXI_RT_START_ADDR_SUB_HIGH_26_REG_OFFSET 0x114

// The higher 32bit of the start address.
#define AXI_RT_START_ADDR_SUB_HIGH_27_REG_OFFSET 0x118

// The higher 32bit of the start address.
#define AXI_RT_START_ADDR_SUB_HIGH_28_REG_OFFSET 0x11c

// The higher 32bit of the start address.
#define AXI_RT_START_ADDR_SUB_HIGH_29_REG_OFFSET 0x120

// The higher 32bit of the start address.
#define AXI_RT_START_ADDR_SUB_HIGH_30_REG_OFFSET 0x124

// The higher 32bit of the start address.
#define AXI_RT_START_ADDR_SUB_HIGH_31_REG_OFFSET 0x128

// The lower 32bit of the end address. (common parameters)
#define AXI_RT_END_ADDR_SUB_LOW_WRITE_BUDGET_FIELD_WIDTH 32
#define AXI_RT_END_ADDR_SUB_LOW_WRITE_BUDGET_FIELDS_PER_REG 1
#define AXI_RT_END_ADDR_SUB_LOW_MULTIREG_COUNT 32

// The lower 32bit of the end address.
#define AXI_RT_END_ADDR_SUB_LOW_0_REG_OFFSET 0x12c

// The lower 32bit of the end address.
#define AXI_RT_END_ADDR_SUB_LOW_1_REG_OFFSET 0x130

// The lower 32bit of the end address.
#define AXI_RT_END_ADDR_SUB_LOW_2_REG_OFFSET 0x134

// The lower 32bit of the end address.
#define AXI_RT_END_ADDR_SUB_LOW_3_REG_OFFSET 0x138

// The lower 32bit of the end address.
#define AXI_RT_END_ADDR_SUB_LOW_4_REG_OFFSET 0x13c

// The lower 32bit of the end address.
#define AXI_RT_END_ADDR_SUB_LOW_5_REG_OFFSET 0x140

// The lower 32bit of the end address.
#define AXI_RT_END_ADDR_SUB_LOW_6_REG_OFFSET 0x144

// The lower 32bit of the end address.
#define AXI_RT_END_ADDR_SUB_LOW_7_REG_OFFSET 0x148

// The lower 32bit of the end address.
#define AXI_RT_END_ADDR_SUB_LOW_8_REG_OFFSET 0x14c

// The lower 32bit of the end address.
#define AXI_RT_END_ADDR_SUB_LOW_9_REG_OFFSET 0x150

// The lower 32bit of the end address.
#define AXI_RT_END_ADDR_SUB_LOW_10_REG_OFFSET 0x154

// The lower 32bit of the end address.
#define AXI_RT_END_ADDR_SUB_LOW_11_REG_OFFSET 0x158

// The lower 32bit of the end address.
#define AXI_RT_END_ADDR_SUB_LOW_12_REG_OFFSET 0x15c

// The lower 32bit of the end address.
#define AXI_RT_END_ADDR_SUB_LOW_13_REG_OFFSET 0x160

// The lower 32bit of the end address.
#define AXI_RT_END_ADDR_SUB_LOW_14_REG_OFFSET 0x164

// The lower 32bit of the end address.
#define AXI_RT_END_ADDR_SUB_LOW_15_REG_OFFSET 0x168

// The lower 32bit of the end address.
#define AXI_RT_END_ADDR_SUB_LOW_16_REG_OFFSET 0x16c

// The lower 32bit of the end address.
#define AXI_RT_END_ADDR_SUB_LOW_17_REG_OFFSET 0x170

// The lower 32bit of the end address.
#define AXI_RT_END_ADDR_SUB_LOW_18_REG_OFFSET 0x174

// The lower 32bit of the end address.
#define AXI_RT_END_ADDR_SUB_LOW_19_REG_OFFSET 0x178

// The lower 32bit of the end address.
#define AXI_RT_END_ADDR_SUB_LOW_20_REG_OFFSET 0x17c

// The lower 32bit of the end address.
#define AXI_RT_END_ADDR_SUB_LOW_21_REG_OFFSET 0x180

// The lower 32bit of the end address.
#define AXI_RT_END_ADDR_SUB_LOW_22_REG_OFFSET 0x184

// The lower 32bit of the end address.
#define AXI_RT_END_ADDR_SUB_LOW_23_REG_OFFSET 0x188

// The lower 32bit of the end address.
#define AXI_RT_END_ADDR_SUB_LOW_24_REG_OFFSET 0x18c

// The lower 32bit of the end address.
#define AXI_RT_END_ADDR_SUB_LOW_25_REG_OFFSET 0x190

// The lower 32bit of the end address.
#define AXI_RT_END_ADDR_SUB_LOW_26_REG_OFFSET 0x194

// The lower 32bit of the end address.
#define AXI_RT_END_ADDR_SUB_LOW_27_REG_OFFSET 0x198

// The lower 32bit of the end address.
#define AXI_RT_END_ADDR_SUB_LOW_28_REG_OFFSET 0x19c

// The lower 32bit of the end address.
#define AXI_RT_END_ADDR_SUB_LOW_29_REG_OFFSET 0x1a0

// The lower 32bit of the end address.
#define AXI_RT_END_ADDR_SUB_LOW_30_REG_OFFSET 0x1a4

// The lower 32bit of the end address.
#define AXI_RT_END_ADDR_SUB_LOW_31_REG_OFFSET 0x1a8

// The higher 32bit of the end address. (common parameters)
#define AXI_RT_END_ADDR_SUB_HIGH_WRITE_BUDGET_FIELD_WIDTH 32
#define AXI_RT_END_ADDR_SUB_HIGH_WRITE_BUDGET_FIELDS_PER_REG 1
#define AXI_RT_END_ADDR_SUB_HIGH_MULTIREG_COUNT 32

// The higher 32bit of the end address.
#define AXI_RT_END_ADDR_SUB_HIGH_0_REG_OFFSET 0x1ac

// The higher 32bit of the end address.
#define AXI_RT_END_ADDR_SUB_HIGH_1_REG_OFFSET 0x1b0

// The higher 32bit of the end address.
#define AXI_RT_END_ADDR_SUB_HIGH_2_REG_OFFSET 0x1b4

// The higher 32bit of the end address.
#define AXI_RT_END_ADDR_SUB_HIGH_3_REG_OFFSET 0x1b8

// The higher 32bit of the end address.
#define AXI_RT_END_ADDR_SUB_HIGH_4_REG_OFFSET 0x1bc

// The higher 32bit of the end address.
#define AXI_RT_END_ADDR_SUB_HIGH_5_REG_OFFSET 0x1c0

// The higher 32bit of the end address.
#define AXI_RT_END_ADDR_SUB_HIGH_6_REG_OFFSET 0x1c4

// The higher 32bit of the end address.
#define AXI_RT_END_ADDR_SUB_HIGH_7_REG_OFFSET 0x1c8

// The higher 32bit of the end address.
#define AXI_RT_END_ADDR_SUB_HIGH_8_REG_OFFSET 0x1cc

// The higher 32bit of the end address.
#define AXI_RT_END_ADDR_SUB_HIGH_9_REG_OFFSET 0x1d0

// The higher 32bit of the end address.
#define AXI_RT_END_ADDR_SUB_HIGH_10_REG_OFFSET 0x1d4

// The higher 32bit of the end address.
#define AXI_RT_END_ADDR_SUB_HIGH_11_REG_OFFSET 0x1d8

// The higher 32bit of the end address.
#define AXI_RT_END_ADDR_SUB_HIGH_12_REG_OFFSET 0x1dc

// The higher 32bit of the end address.
#define AXI_RT_END_ADDR_SUB_HIGH_13_REG_OFFSET 0x1e0

// The higher 32bit of the end address.
#define AXI_RT_END_ADDR_SUB_HIGH_14_REG_OFFSET 0x1e4

// The higher 32bit of the end address.
#define AXI_RT_END_ADDR_SUB_HIGH_15_REG_OFFSET 0x1e8

// The higher 32bit of the end address.
#define AXI_RT_END_ADDR_SUB_HIGH_16_REG_OFFSET 0x1ec

// The higher 32bit of the end address.
#define AXI_RT_END_ADDR_SUB_HIGH_17_REG_OFFSET 0x1f0

// The higher 32bit of the end address.
#define AXI_RT_END_ADDR_SUB_HIGH_18_REG_OFFSET 0x1f4

// The higher 32bit of the end address.
#define AXI_RT_END_ADDR_SUB_HIGH_19_REG_OFFSET 0x1f8

// The higher 32bit of the end address.
#define AXI_RT_END_ADDR_SUB_HIGH_20_REG_OFFSET 0x1fc

// The higher 32bit of the end address.
#define AXI_RT_END_ADDR_SUB_HIGH_21_REG_OFFSET 0x200

// The higher 32bit of the end address.
#define AXI_RT_END_ADDR_SUB_HIGH_22_REG_OFFSET 0x204

// The higher 32bit of the end address.
#define AXI_RT_END_ADDR_SUB_HIGH_23_REG_OFFSET 0x208

// The higher 32bit of the end address.
#define AXI_RT_END_ADDR_SUB_HIGH_24_REG_OFFSET 0x20c

// The higher 32bit of the end address.
#define AXI_RT_END_ADDR_SUB_HIGH_25_REG_OFFSET 0x210

// The higher 32bit of the end address.
#define AXI_RT_END_ADDR_SUB_HIGH_26_REG_OFFSET 0x214

// The higher 32bit of the end address.
#define AXI_RT_END_ADDR_SUB_HIGH_27_REG_OFFSET 0x218

// The higher 32bit of the end address.
#define AXI_RT_END_ADDR_SUB_HIGH_28_REG_OFFSET 0x21c

// The higher 32bit of the end address.
#define AXI_RT_END_ADDR_SUB_HIGH_29_REG_OFFSET 0x220

// The higher 32bit of the end address.
#define AXI_RT_END_ADDR_SUB_HIGH_30_REG_OFFSET 0x224

// The higher 32bit of the end address.
#define AXI_RT_END_ADDR_SUB_HIGH_31_REG_OFFSET 0x228

// The budget for writes. (common parameters)
#define AXI_RT_WRITE_BUDGET_WRITE_BUDGET_FIELD_WIDTH 32
#define AXI_RT_WRITE_BUDGET_WRITE_BUDGET_FIELDS_PER_REG 1
#define AXI_RT_WRITE_BUDGET_MULTIREG_COUNT 32

// The budget for writes.
#define AXI_RT_WRITE_BUDGET_0_REG_OFFSET 0x22c

// The budget for writes.
#define AXI_RT_WRITE_BUDGET_1_REG_OFFSET 0x230

// The budget for writes.
#define AXI_RT_WRITE_BUDGET_2_REG_OFFSET 0x234

// The budget for writes.
#define AXI_RT_WRITE_BUDGET_3_REG_OFFSET 0x238

// The budget for writes.
#define AXI_RT_WRITE_BUDGET_4_REG_OFFSET 0x23c

// The budget for writes.
#define AXI_RT_WRITE_BUDGET_5_REG_OFFSET 0x240

// The budget for writes.
#define AXI_RT_WRITE_BUDGET_6_REG_OFFSET 0x244

// The budget for writes.
#define AXI_RT_WRITE_BUDGET_7_REG_OFFSET 0x248

// The budget for writes.
#define AXI_RT_WRITE_BUDGET_8_REG_OFFSET 0x24c

// The budget for writes.
#define AXI_RT_WRITE_BUDGET_9_REG_OFFSET 0x250

// The budget for writes.
#define AXI_RT_WRITE_BUDGET_10_REG_OFFSET 0x254

// The budget for writes.
#define AXI_RT_WRITE_BUDGET_11_REG_OFFSET 0x258

// The budget for writes.
#define AXI_RT_WRITE_BUDGET_12_REG_OFFSET 0x25c

// The budget for writes.
#define AXI_RT_WRITE_BUDGET_13_REG_OFFSET 0x260

// The budget for writes.
#define AXI_RT_WRITE_BUDGET_14_REG_OFFSET 0x264

// The budget for writes.
#define AXI_RT_WRITE_BUDGET_15_REG_OFFSET 0x268

// The budget for writes.
#define AXI_RT_WRITE_BUDGET_16_REG_OFFSET 0x26c

// The budget for writes.
#define AXI_RT_WRITE_BUDGET_17_REG_OFFSET 0x270

// The budget for writes.
#define AXI_RT_WRITE_BUDGET_18_REG_OFFSET 0x274

// The budget for writes.
#define AXI_RT_WRITE_BUDGET_19_REG_OFFSET 0x278

// The budget for writes.
#define AXI_RT_WRITE_BUDGET_20_REG_OFFSET 0x27c

// The budget for writes.
#define AXI_RT_WRITE_BUDGET_21_REG_OFFSET 0x280

// The budget for writes.
#define AXI_RT_WRITE_BUDGET_22_REG_OFFSET 0x284

// The budget for writes.
#define AXI_RT_WRITE_BUDGET_23_REG_OFFSET 0x288

// The budget for writes.
#define AXI_RT_WRITE_BUDGET_24_REG_OFFSET 0x28c

// The budget for writes.
#define AXI_RT_WRITE_BUDGET_25_REG_OFFSET 0x290

// The budget for writes.
#define AXI_RT_WRITE_BUDGET_26_REG_OFFSET 0x294

// The budget for writes.
#define AXI_RT_WRITE_BUDGET_27_REG_OFFSET 0x298

// The budget for writes.
#define AXI_RT_WRITE_BUDGET_28_REG_OFFSET 0x29c

// The budget for writes.
#define AXI_RT_WRITE_BUDGET_29_REG_OFFSET 0x2a0

// The budget for writes.
#define AXI_RT_WRITE_BUDGET_30_REG_OFFSET 0x2a4

// The budget for writes.
#define AXI_RT_WRITE_BUDGET_31_REG_OFFSET 0x2a8

// The budget for reads. (common parameters)
#define AXI_RT_READ_BUDGET_READ_BUDGET_FIELD_WIDTH 32
#define AXI_RT_READ_BUDGET_READ_BUDGET_FIELDS_PER_REG 1
#define AXI_RT_READ_BUDGET_MULTIREG_COUNT 32

// The budget for reads.
#define AXI_RT_READ_BUDGET_0_REG_OFFSET 0x2ac

// The budget for reads.
#define AXI_RT_READ_BUDGET_1_REG_OFFSET 0x2b0

// The budget for reads.
#define AXI_RT_READ_BUDGET_2_REG_OFFSET 0x2b4

// The budget for reads.
#define AXI_RT_READ_BUDGET_3_REG_OFFSET 0x2b8

// The budget for reads.
#define AXI_RT_READ_BUDGET_4_REG_OFFSET 0x2bc

// The budget for reads.
#define AXI_RT_READ_BUDGET_5_REG_OFFSET 0x2c0

// The budget for reads.
#define AXI_RT_READ_BUDGET_6_REG_OFFSET 0x2c4

// The budget for reads.
#define AXI_RT_READ_BUDGET_7_REG_OFFSET 0x2c8

// The budget for reads.
#define AXI_RT_READ_BUDGET_8_REG_OFFSET 0x2cc

// The budget for reads.
#define AXI_RT_READ_BUDGET_9_REG_OFFSET 0x2d0

// The budget for reads.
#define AXI_RT_READ_BUDGET_10_REG_OFFSET 0x2d4

// The budget for reads.
#define AXI_RT_READ_BUDGET_11_REG_OFFSET 0x2d8

// The budget for reads.
#define AXI_RT_READ_BUDGET_12_REG_OFFSET 0x2dc

// The budget for reads.
#define AXI_RT_READ_BUDGET_13_REG_OFFSET 0x2e0

// The budget for reads.
#define AXI_RT_READ_BUDGET_14_REG_OFFSET 0x2e4

// The budget for reads.
#define AXI_RT_READ_BUDGET_15_REG_OFFSET 0x2e8

// The budget for reads.
#define AXI_RT_READ_BUDGET_16_REG_OFFSET 0x2ec

// The budget for reads.
#define AXI_RT_READ_BUDGET_17_REG_OFFSET 0x2f0

// The budget for reads.
#define AXI_RT_READ_BUDGET_18_REG_OFFSET 0x2f4

// The budget for reads.
#define AXI_RT_READ_BUDGET_19_REG_OFFSET 0x2f8

// The budget for reads.
#define AXI_RT_READ_BUDGET_20_REG_OFFSET 0x2fc

// The budget for reads.
#define AXI_RT_READ_BUDGET_21_REG_OFFSET 0x300

// The budget for reads.
#define AXI_RT_READ_BUDGET_22_REG_OFFSET 0x304

// The budget for reads.
#define AXI_RT_READ_BUDGET_23_REG_OFFSET 0x308

// The budget for reads.
#define AXI_RT_READ_BUDGET_24_REG_OFFSET 0x30c

// The budget for reads.
#define AXI_RT_READ_BUDGET_25_REG_OFFSET 0x310

// The budget for reads.
#define AXI_RT_READ_BUDGET_26_REG_OFFSET 0x314

// The budget for reads.
#define AXI_RT_READ_BUDGET_27_REG_OFFSET 0x318

// The budget for reads.
#define AXI_RT_READ_BUDGET_28_REG_OFFSET 0x31c

// The budget for reads.
#define AXI_RT_READ_BUDGET_29_REG_OFFSET 0x320

// The budget for reads.
#define AXI_RT_READ_BUDGET_30_REG_OFFSET 0x324

// The budget for reads.
#define AXI_RT_READ_BUDGET_31_REG_OFFSET 0x328

// The period for writes. (common parameters)
#define AXI_RT_WRITE_PERIOD_WRITE_PERIOD_FIELD_WIDTH 32
#define AXI_RT_WRITE_PERIOD_WRITE_PERIOD_FIELDS_PER_REG 1
#define AXI_RT_WRITE_PERIOD_MULTIREG_COUNT 32

// The period for writes.
#define AXI_RT_WRITE_PERIOD_0_REG_OFFSET 0x32c

// The period for writes.
#define AXI_RT_WRITE_PERIOD_1_REG_OFFSET 0x330

// The period for writes.
#define AXI_RT_WRITE_PERIOD_2_REG_OFFSET 0x334

// The period for writes.
#define AXI_RT_WRITE_PERIOD_3_REG_OFFSET 0x338

// The period for writes.
#define AXI_RT_WRITE_PERIOD_4_REG_OFFSET 0x33c

// The period for writes.
#define AXI_RT_WRITE_PERIOD_5_REG_OFFSET 0x340

// The period for writes.
#define AXI_RT_WRITE_PERIOD_6_REG_OFFSET 0x344

// The period for writes.
#define AXI_RT_WRITE_PERIOD_7_REG_OFFSET 0x348

// The period for writes.
#define AXI_RT_WRITE_PERIOD_8_REG_OFFSET 0x34c

// The period for writes.
#define AXI_RT_WRITE_PERIOD_9_REG_OFFSET 0x350

// The period for writes.
#define AXI_RT_WRITE_PERIOD_10_REG_OFFSET 0x354

// The period for writes.
#define AXI_RT_WRITE_PERIOD_11_REG_OFFSET 0x358

// The period for writes.
#define AXI_RT_WRITE_PERIOD_12_REG_OFFSET 0x35c

// The period for writes.
#define AXI_RT_WRITE_PERIOD_13_REG_OFFSET 0x360

// The period for writes.
#define AXI_RT_WRITE_PERIOD_14_REG_OFFSET 0x364

// The period for writes.
#define AXI_RT_WRITE_PERIOD_15_REG_OFFSET 0x368

// The period for writes.
#define AXI_RT_WRITE_PERIOD_16_REG_OFFSET 0x36c

// The period for writes.
#define AXI_RT_WRITE_PERIOD_17_REG_OFFSET 0x370

// The period for writes.
#define AXI_RT_WRITE_PERIOD_18_REG_OFFSET 0x374

// The period for writes.
#define AXI_RT_WRITE_PERIOD_19_REG_OFFSET 0x378

// The period for writes.
#define AXI_RT_WRITE_PERIOD_20_REG_OFFSET 0x37c

// The period for writes.
#define AXI_RT_WRITE_PERIOD_21_REG_OFFSET 0x380

// The period for writes.
#define AXI_RT_WRITE_PERIOD_22_REG_OFFSET 0x384

// The period for writes.
#define AXI_RT_WRITE_PERIOD_23_REG_OFFSET 0x388

// The period for writes.
#define AXI_RT_WRITE_PERIOD_24_REG_OFFSET 0x38c

// The period for writes.
#define AXI_RT_WRITE_PERIOD_25_REG_OFFSET 0x390

// The period for writes.
#define AXI_RT_WRITE_PERIOD_26_REG_OFFSET 0x394

// The period for writes.
#define AXI_RT_WRITE_PERIOD_27_REG_OFFSET 0x398

// The period for writes.
#define AXI_RT_WRITE_PERIOD_28_REG_OFFSET 0x39c

// The period for writes.
#define AXI_RT_WRITE_PERIOD_29_REG_OFFSET 0x3a0

// The period for writes.
#define AXI_RT_WRITE_PERIOD_30_REG_OFFSET 0x3a4

// The period for writes.
#define AXI_RT_WRITE_PERIOD_31_REG_OFFSET 0x3a8

// The period for reads. (common parameters)
#define AXI_RT_READ_PERIOD_READ_PERIOD_FIELD_WIDTH 32
#define AXI_RT_READ_PERIOD_READ_PERIOD_FIELDS_PER_REG 1
#define AXI_RT_READ_PERIOD_MULTIREG_COUNT 32

// The period for reads.
#define AXI_RT_READ_PERIOD_0_REG_OFFSET 0x3ac

// The period for reads.
#define AXI_RT_READ_PERIOD_1_REG_OFFSET 0x3b0

// The period for reads.
#define AXI_RT_READ_PERIOD_2_REG_OFFSET 0x3b4

// The period for reads.
#define AXI_RT_READ_PERIOD_3_REG_OFFSET 0x3b8

// The period for reads.
#define AXI_RT_READ_PERIOD_4_REG_OFFSET 0x3bc

// The period for reads.
#define AXI_RT_READ_PERIOD_5_REG_OFFSET 0x3c0

// The period for reads.
#define AXI_RT_READ_PERIOD_6_REG_OFFSET 0x3c4

// The period for reads.
#define AXI_RT_READ_PERIOD_7_REG_OFFSET 0x3c8

// The period for reads.
#define AXI_RT_READ_PERIOD_8_REG_OFFSET 0x3cc

// The period for reads.
#define AXI_RT_READ_PERIOD_9_REG_OFFSET 0x3d0

// The period for reads.
#define AXI_RT_READ_PERIOD_10_REG_OFFSET 0x3d4

// The period for reads.
#define AXI_RT_READ_PERIOD_11_REG_OFFSET 0x3d8

// The period for reads.
#define AXI_RT_READ_PERIOD_12_REG_OFFSET 0x3dc

// The period for reads.
#define AXI_RT_READ_PERIOD_13_REG_OFFSET 0x3e0

// The period for reads.
#define AXI_RT_READ_PERIOD_14_REG_OFFSET 0x3e4

// The period for reads.
#define AXI_RT_READ_PERIOD_15_REG_OFFSET 0x3e8

// The period for reads.
#define AXI_RT_READ_PERIOD_16_REG_OFFSET 0x3ec

// The period for reads.
#define AXI_RT_READ_PERIOD_17_REG_OFFSET 0x3f0

// The period for reads.
#define AXI_RT_READ_PERIOD_18_REG_OFFSET 0x3f4

// The period for reads.
#define AXI_RT_READ_PERIOD_19_REG_OFFSET 0x3f8

// The period for reads.
#define AXI_RT_READ_PERIOD_20_REG_OFFSET 0x3fc

// The period for reads.
#define AXI_RT_READ_PERIOD_21_REG_OFFSET 0x400

// The period for reads.
#define AXI_RT_READ_PERIOD_22_REG_OFFSET 0x404

// The period for reads.
#define AXI_RT_READ_PERIOD_23_REG_OFFSET 0x408

// The period for reads.
#define AXI_RT_READ_PERIOD_24_REG_OFFSET 0x40c

// The period for reads.
#define AXI_RT_READ_PERIOD_25_REG_OFFSET 0x410

// The period for reads.
#define AXI_RT_READ_PERIOD_26_REG_OFFSET 0x414

// The period for reads.
#define AXI_RT_READ_PERIOD_27_REG_OFFSET 0x418

// The period for reads.
#define AXI_RT_READ_PERIOD_28_REG_OFFSET 0x41c

// The period for reads.
#define AXI_RT_READ_PERIOD_29_REG_OFFSET 0x420

// The period for reads.
#define AXI_RT_READ_PERIOD_30_REG_OFFSET 0x424

// The period for reads.
#define AXI_RT_READ_PERIOD_31_REG_OFFSET 0x428

// The budget left for writes. (common parameters)
#define AXI_RT_WRITE_BUDGET_LEFT_WRITE_BUDGET_LEFT_FIELD_WIDTH 32
#define AXI_RT_WRITE_BUDGET_LEFT_WRITE_BUDGET_LEFT_FIELDS_PER_REG 1
#define AXI_RT_WRITE_BUDGET_LEFT_MULTIREG_COUNT 32

// The budget left for writes.
#define AXI_RT_WRITE_BUDGET_LEFT_0_REG_OFFSET 0x42c

// The budget left for writes.
#define AXI_RT_WRITE_BUDGET_LEFT_1_REG_OFFSET 0x430

// The budget left for writes.
#define AXI_RT_WRITE_BUDGET_LEFT_2_REG_OFFSET 0x434

// The budget left for writes.
#define AXI_RT_WRITE_BUDGET_LEFT_3_REG_OFFSET 0x438

// The budget left for writes.
#define AXI_RT_WRITE_BUDGET_LEFT_4_REG_OFFSET 0x43c

// The budget left for writes.
#define AXI_RT_WRITE_BUDGET_LEFT_5_REG_OFFSET 0x440

// The budget left for writes.
#define AXI_RT_WRITE_BUDGET_LEFT_6_REG_OFFSET 0x444

// The budget left for writes.
#define AXI_RT_WRITE_BUDGET_LEFT_7_REG_OFFSET 0x448

// The budget left for writes.
#define AXI_RT_WRITE_BUDGET_LEFT_8_REG_OFFSET 0x44c

// The budget left for writes.
#define AXI_RT_WRITE_BUDGET_LEFT_9_REG_OFFSET 0x450

// The budget left for writes.
#define AXI_RT_WRITE_BUDGET_LEFT_10_REG_OFFSET 0x454

// The budget left for writes.
#define AXI_RT_WRITE_BUDGET_LEFT_11_REG_OFFSET 0x458

// The budget left for writes.
#define AXI_RT_WRITE_BUDGET_LEFT_12_REG_OFFSET 0x45c

// The budget left for writes.
#define AXI_RT_WRITE_BUDGET_LEFT_13_REG_OFFSET 0x460

// The budget left for writes.
#define AXI_RT_WRITE_BUDGET_LEFT_14_REG_OFFSET 0x464

// The budget left for writes.
#define AXI_RT_WRITE_BUDGET_LEFT_15_REG_OFFSET 0x468

// The budget left for writes.
#define AXI_RT_WRITE_BUDGET_LEFT_16_REG_OFFSET 0x46c

// The budget left for writes.
#define AXI_RT_WRITE_BUDGET_LEFT_17_REG_OFFSET 0x470

// The budget left for writes.
#define AXI_RT_WRITE_BUDGET_LEFT_18_REG_OFFSET 0x474

// The budget left for writes.
#define AXI_RT_WRITE_BUDGET_LEFT_19_REG_OFFSET 0x478

// The budget left for writes.
#define AXI_RT_WRITE_BUDGET_LEFT_20_REG_OFFSET 0x47c

// The budget left for writes.
#define AXI_RT_WRITE_BUDGET_LEFT_21_REG_OFFSET 0x480

// The budget left for writes.
#define AXI_RT_WRITE_BUDGET_LEFT_22_REG_OFFSET 0x484

// The budget left for writes.
#define AXI_RT_WRITE_BUDGET_LEFT_23_REG_OFFSET 0x488

// The budget left for writes.
#define AXI_RT_WRITE_BUDGET_LEFT_24_REG_OFFSET 0x48c

// The budget left for writes.
#define AXI_RT_WRITE_BUDGET_LEFT_25_REG_OFFSET 0x490

// The budget left for writes.
#define AXI_RT_WRITE_BUDGET_LEFT_26_REG_OFFSET 0x494

// The budget left for writes.
#define AXI_RT_WRITE_BUDGET_LEFT_27_REG_OFFSET 0x498

// The budget left for writes.
#define AXI_RT_WRITE_BUDGET_LEFT_28_REG_OFFSET 0x49c

// The budget left for writes.
#define AXI_RT_WRITE_BUDGET_LEFT_29_REG_OFFSET 0x4a0

// The budget left for writes.
#define AXI_RT_WRITE_BUDGET_LEFT_30_REG_OFFSET 0x4a4

// The budget left for writes.
#define AXI_RT_WRITE_BUDGET_LEFT_31_REG_OFFSET 0x4a8

// The budget left for reads. (common parameters)
#define AXI_RT_READ_BUDGET_LEFT_READ_BUDGET_LEFT_FIELD_WIDTH 32
#define AXI_RT_READ_BUDGET_LEFT_READ_BUDGET_LEFT_FIELDS_PER_REG 1
#define AXI_RT_READ_BUDGET_LEFT_MULTIREG_COUNT 32

// The budget left for reads.
#define AXI_RT_READ_BUDGET_LEFT_0_REG_OFFSET 0x4ac

// The budget left for reads.
#define AXI_RT_READ_BUDGET_LEFT_1_REG_OFFSET 0x4b0

// The budget left for reads.
#define AXI_RT_READ_BUDGET_LEFT_2_REG_OFFSET 0x4b4

// The budget left for reads.
#define AXI_RT_READ_BUDGET_LEFT_3_REG_OFFSET 0x4b8

// The budget left for reads.
#define AXI_RT_READ_BUDGET_LEFT_4_REG_OFFSET 0x4bc

// The budget left for reads.
#define AXI_RT_READ_BUDGET_LEFT_5_REG_OFFSET 0x4c0

// The budget left for reads.
#define AXI_RT_READ_BUDGET_LEFT_6_REG_OFFSET 0x4c4

// The budget left for reads.
#define AXI_RT_READ_BUDGET_LEFT_7_REG_OFFSET 0x4c8

// The budget left for reads.
#define AXI_RT_READ_BUDGET_LEFT_8_REG_OFFSET 0x4cc

// The budget left for reads.
#define AXI_RT_READ_BUDGET_LEFT_9_REG_OFFSET 0x4d0

// The budget left for reads.
#define AXI_RT_READ_BUDGET_LEFT_10_REG_OFFSET 0x4d4

// The budget left for reads.
#define AXI_RT_READ_BUDGET_LEFT_11_REG_OFFSET 0x4d8

// The budget left for reads.
#define AXI_RT_READ_BUDGET_LEFT_12_REG_OFFSET 0x4dc

// The budget left for reads.
#define AXI_RT_READ_BUDGET_LEFT_13_REG_OFFSET 0x4e0

// The budget left for reads.
#define AXI_RT_READ_BUDGET_LEFT_14_REG_OFFSET 0x4e4

// The budget left for reads.
#define AXI_RT_READ_BUDGET_LEFT_15_REG_OFFSET 0x4e8

// The budget left for reads.
#define AXI_RT_READ_BUDGET_LEFT_16_REG_OFFSET 0x4ec

// The budget left for reads.
#define AXI_RT_READ_BUDGET_LEFT_17_REG_OFFSET 0x4f0

// The budget left for reads.
#define AXI_RT_READ_BUDGET_LEFT_18_REG_OFFSET 0x4f4

// The budget left for reads.
#define AXI_RT_READ_BUDGET_LEFT_19_REG_OFFSET 0x4f8

// The budget left for reads.
#define AXI_RT_READ_BUDGET_LEFT_20_REG_OFFSET 0x4fc

// The budget left for reads.
#define AXI_RT_READ_BUDGET_LEFT_21_REG_OFFSET 0x500

// The budget left for reads.
#define AXI_RT_READ_BUDGET_LEFT_22_REG_OFFSET 0x504

// The budget left for reads.
#define AXI_RT_READ_BUDGET_LEFT_23_REG_OFFSET 0x508

// The budget left for reads.
#define AXI_RT_READ_BUDGET_LEFT_24_REG_OFFSET 0x50c

// The budget left for reads.
#define AXI_RT_READ_BUDGET_LEFT_25_REG_OFFSET 0x510

// The budget left for reads.
#define AXI_RT_READ_BUDGET_LEFT_26_REG_OFFSET 0x514

// The budget left for reads.
#define AXI_RT_READ_BUDGET_LEFT_27_REG_OFFSET 0x518

// The budget left for reads.
#define AXI_RT_READ_BUDGET_LEFT_28_REG_OFFSET 0x51c

// The budget left for reads.
#define AXI_RT_READ_BUDGET_LEFT_29_REG_OFFSET 0x520

// The budget left for reads.
#define AXI_RT_READ_BUDGET_LEFT_30_REG_OFFSET 0x524

// The budget left for reads.
#define AXI_RT_READ_BUDGET_LEFT_31_REG_OFFSET 0x528

// The period left for writes. (common parameters)
#define AXI_RT_WRITE_PERIOD_LEFT_WRITE_PERIOD_LEFT_FIELD_WIDTH 32
#define AXI_RT_WRITE_PERIOD_LEFT_WRITE_PERIOD_LEFT_FIELDS_PER_REG 1
#define AXI_RT_WRITE_PERIOD_LEFT_MULTIREG_COUNT 32

// The period left for writes.
#define AXI_RT_WRITE_PERIOD_LEFT_0_REG_OFFSET 0x52c

// The period left for writes.
#define AXI_RT_WRITE_PERIOD_LEFT_1_REG_OFFSET 0x530

// The period left for writes.
#define AXI_RT_WRITE_PERIOD_LEFT_2_REG_OFFSET 0x534

// The period left for writes.
#define AXI_RT_WRITE_PERIOD_LEFT_3_REG_OFFSET 0x538

// The period left for writes.
#define AXI_RT_WRITE_PERIOD_LEFT_4_REG_OFFSET 0x53c

// The period left for writes.
#define AXI_RT_WRITE_PERIOD_LEFT_5_REG_OFFSET 0x540

// The period left for writes.
#define AXI_RT_WRITE_PERIOD_LEFT_6_REG_OFFSET 0x544

// The period left for writes.
#define AXI_RT_WRITE_PERIOD_LEFT_7_REG_OFFSET 0x548

// The period left for writes.
#define AXI_RT_WRITE_PERIOD_LEFT_8_REG_OFFSET 0x54c

// The period left for writes.
#define AXI_RT_WRITE_PERIOD_LEFT_9_REG_OFFSET 0x550

// The period left for writes.
#define AXI_RT_WRITE_PERIOD_LEFT_10_REG_OFFSET 0x554

// The period left for writes.
#define AXI_RT_WRITE_PERIOD_LEFT_11_REG_OFFSET 0x558

// The period left for writes.
#define AXI_RT_WRITE_PERIOD_LEFT_12_REG_OFFSET 0x55c

// The period left for writes.
#define AXI_RT_WRITE_PERIOD_LEFT_13_REG_OFFSET 0x560

// The period left for writes.
#define AXI_RT_WRITE_PERIOD_LEFT_14_REG_OFFSET 0x564

// The period left for writes.
#define AXI_RT_WRITE_PERIOD_LEFT_15_REG_OFFSET 0x568

// The period left for writes.
#define AXI_RT_WRITE_PERIOD_LEFT_16_REG_OFFSET 0x56c

// The period left for writes.
#define AXI_RT_WRITE_PERIOD_LEFT_17_REG_OFFSET 0x570

// The period left for writes.
#define AXI_RT_WRITE_PERIOD_LEFT_18_REG_OFFSET 0x574

// The period left for writes.
#define AXI_RT_WRITE_PERIOD_LEFT_19_REG_OFFSET 0x578

// The period left for writes.
#define AXI_RT_WRITE_PERIOD_LEFT_20_REG_OFFSET 0x57c

// The period left for writes.
#define AXI_RT_WRITE_PERIOD_LEFT_21_REG_OFFSET 0x580

// The period left for writes.
#define AXI_RT_WRITE_PERIOD_LEFT_22_REG_OFFSET 0x584

// The period left for writes.
#define AXI_RT_WRITE_PERIOD_LEFT_23_REG_OFFSET 0x588

// The period left for writes.
#define AXI_RT_WRITE_PERIOD_LEFT_24_REG_OFFSET 0x58c

// The period left for writes.
#define AXI_RT_WRITE_PERIOD_LEFT_25_REG_OFFSET 0x590

// The period left for writes.
#define AXI_RT_WRITE_PERIOD_LEFT_26_REG_OFFSET 0x594

// The period left for writes.
#define AXI_RT_WRITE_PERIOD_LEFT_27_REG_OFFSET 0x598

// The period left for writes.
#define AXI_RT_WRITE_PERIOD_LEFT_28_REG_OFFSET 0x59c

// The period left for writes.
#define AXI_RT_WRITE_PERIOD_LEFT_29_REG_OFFSET 0x5a0

// The period left for writes.
#define AXI_RT_WRITE_PERIOD_LEFT_30_REG_OFFSET 0x5a4

// The period left for writes.
#define AXI_RT_WRITE_PERIOD_LEFT_31_REG_OFFSET 0x5a8

// The period left for reads. (common parameters)
#define AXI_RT_READ_PERIOD_LEFT_READ_PERIOD_LEFT_FIELD_WIDTH 32
#define AXI_RT_READ_PERIOD_LEFT_READ_PERIOD_LEFT_FIELDS_PER_REG 1
#define AXI_RT_READ_PERIOD_LEFT_MULTIREG_COUNT 32

// The period left for reads.
#define AXI_RT_READ_PERIOD_LEFT_0_REG_OFFSET 0x5ac

// The period left for reads.
#define AXI_RT_READ_PERIOD_LEFT_1_REG_OFFSET 0x5b0

// The period left for reads.
#define AXI_RT_READ_PERIOD_LEFT_2_REG_OFFSET 0x5b4

// The period left for reads.
#define AXI_RT_READ_PERIOD_LEFT_3_REG_OFFSET 0x5b8

// The period left for reads.
#define AXI_RT_READ_PERIOD_LEFT_4_REG_OFFSET 0x5bc

// The period left for reads.
#define AXI_RT_READ_PERIOD_LEFT_5_REG_OFFSET 0x5c0

// The period left for reads.
#define AXI_RT_READ_PERIOD_LEFT_6_REG_OFFSET 0x5c4

// The period left for reads.
#define AXI_RT_READ_PERIOD_LEFT_7_REG_OFFSET 0x5c8

// The period left for reads.
#define AXI_RT_READ_PERIOD_LEFT_8_REG_OFFSET 0x5cc

// The period left for reads.
#define AXI_RT_READ_PERIOD_LEFT_9_REG_OFFSET 0x5d0

// The period left for reads.
#define AXI_RT_READ_PERIOD_LEFT_10_REG_OFFSET 0x5d4

// The period left for reads.
#define AXI_RT_READ_PERIOD_LEFT_11_REG_OFFSET 0x5d8

// The period left for reads.
#define AXI_RT_READ_PERIOD_LEFT_12_REG_OFFSET 0x5dc

// The period left for reads.
#define AXI_RT_READ_PERIOD_LEFT_13_REG_OFFSET 0x5e0

// The period left for reads.
#define AXI_RT_READ_PERIOD_LEFT_14_REG_OFFSET 0x5e4

// The period left for reads.
#define AXI_RT_READ_PERIOD_LEFT_15_REG_OFFSET 0x5e8

// The period left for reads.
#define AXI_RT_READ_PERIOD_LEFT_16_REG_OFFSET 0x5ec

// The period left for reads.
#define AXI_RT_READ_PERIOD_LEFT_17_REG_OFFSET 0x5f0

// The period left for reads.
#define AXI_RT_READ_PERIOD_LEFT_18_REG_OFFSET 0x5f4

// The period left for reads.
#define AXI_RT_READ_PERIOD_LEFT_19_REG_OFFSET 0x5f8

// The period left for reads.
#define AXI_RT_READ_PERIOD_LEFT_20_REG_OFFSET 0x5fc

// The period left for reads.
#define AXI_RT_READ_PERIOD_LEFT_21_REG_OFFSET 0x600

// The period left for reads.
#define AXI_RT_READ_PERIOD_LEFT_22_REG_OFFSET 0x604

// The period left for reads.
#define AXI_RT_READ_PERIOD_LEFT_23_REG_OFFSET 0x608

// The period left for reads.
#define AXI_RT_READ_PERIOD_LEFT_24_REG_OFFSET 0x60c

// The period left for reads.
#define AXI_RT_READ_PERIOD_LEFT_25_REG_OFFSET 0x610

// The period left for reads.
#define AXI_RT_READ_PERIOD_LEFT_26_REG_OFFSET 0x614

// The period left for reads.
#define AXI_RT_READ_PERIOD_LEFT_27_REG_OFFSET 0x618

// The period left for reads.
#define AXI_RT_READ_PERIOD_LEFT_28_REG_OFFSET 0x61c

// The period left for reads.
#define AXI_RT_READ_PERIOD_LEFT_29_REG_OFFSET 0x620

// The period left for reads.
#define AXI_RT_READ_PERIOD_LEFT_30_REG_OFFSET 0x624

// The period left for reads.
#define AXI_RT_READ_PERIOD_LEFT_31_REG_OFFSET 0x628

// Is the interface requested to be isolated? (common parameters)
#define AXI_RT_ISOLATE_ISOLATE_FIELD_WIDTH 1
#define AXI_RT_ISOLATE_ISOLATE_FIELDS_PER_REG 32
#define AXI_RT_ISOLATE_MULTIREG_COUNT 1

// Is the interface requested to be isolated?
#define AXI_RT_ISOLATE_REG_OFFSET 0x62c
#define AXI_RT_ISOLATE_ISOLATE_0_BIT 0
#define AXI_RT_ISOLATE_ISOLATE_1_BIT 1
#define AXI_RT_ISOLATE_ISOLATE_2_BIT 2
#define AXI_RT_ISOLATE_ISOLATE_3_BIT 3
#define AXI_RT_ISOLATE_ISOLATE_4_BIT 4
#define AXI_RT_ISOLATE_ISOLATE_5_BIT 5
#define AXI_RT_ISOLATE_ISOLATE_6_BIT 6
#define AXI_RT_ISOLATE_ISOLATE_7_BIT 7
#define AXI_RT_ISOLATE_ISOLATE_8_BIT 8
#define AXI_RT_ISOLATE_ISOLATE_9_BIT 9
#define AXI_RT_ISOLATE_ISOLATE_10_BIT 10
#define AXI_RT_ISOLATE_ISOLATE_11_BIT 11
#define AXI_RT_ISOLATE_ISOLATE_12_BIT 12
#define AXI_RT_ISOLATE_ISOLATE_13_BIT 13
#define AXI_RT_ISOLATE_ISOLATE_14_BIT 14
#define AXI_RT_ISOLATE_ISOLATE_15_BIT 15

// Is the interface isolated? (common parameters)
#define AXI_RT_ISOLATED_ISOLATED_FIELD_WIDTH 1
#define AXI_RT_ISOLATED_ISOLATED_FIELDS_PER_REG 32
#define AXI_RT_ISOLATED_MULTIREG_COUNT 1

// Is the interface isolated?
#define AXI_RT_ISOLATED_REG_OFFSET 0x630
#define AXI_RT_ISOLATED_ISOLATED_0_BIT 0
#define AXI_RT_ISOLATED_ISOLATED_1_BIT 1
#define AXI_RT_ISOLATED_ISOLATED_2_BIT 2
#define AXI_RT_ISOLATED_ISOLATED_3_BIT 3
#define AXI_RT_ISOLATED_ISOLATED_4_BIT 4
#define AXI_RT_ISOLATED_ISOLATED_5_BIT 5
#define AXI_RT_ISOLATED_ISOLATED_6_BIT 6
#define AXI_RT_ISOLATED_ISOLATED_7_BIT 7
#define AXI_RT_ISOLATED_ISOLATED_8_BIT 8
#define AXI_RT_ISOLATED_ISOLATED_9_BIT 9
#define AXI_RT_ISOLATED_ISOLATED_10_BIT 10
#define AXI_RT_ISOLATED_ISOLATED_11_BIT 11
#define AXI_RT_ISOLATED_ISOLATED_12_BIT 12
#define AXI_RT_ISOLATED_ISOLATED_13_BIT 13
#define AXI_RT_ISOLATED_ISOLATED_14_BIT 14
#define AXI_RT_ISOLATED_ISOLATED_15_BIT 15

// Value of the num_managers parameter.
#define AXI_RT_NUM_MANAGERS_REG_OFFSET 0x634

// Value of the addr_width parameter.
#define AXI_RT_ADDR_WIDTH_REG_OFFSET 0x638

// Value of the data_width parameter.
#define AXI_RT_DATA_WIDTH_REG_OFFSET 0x63c

// Value of the id_width parameter.
#define AXI_RT_ID_WIDTH_REG_OFFSET 0x640

// Value of the user_width parameter.
#define AXI_RT_USER_WIDTH_REG_OFFSET 0x644

// Value of the num_pending parameter.
#define AXI_RT_NUM_PENDING_REG_OFFSET 0x648

// Value of the w_buffer_depth parameter.
#define AXI_RT_W_BUFFER_DEPTH_REG_OFFSET 0x64c

// Value of the num_addr_regions parameter.
#define AXI_RT_NUM_ADDR_REGIONS_REG_OFFSET 0x650

// Value of the period_width parameter.
#define AXI_RT_PERIOD_WIDTH_REG_OFFSET 0x654

// Value of the budget_width parameter.
#define AXI_RT_BUDGET_WIDTH_REG_OFFSET 0x658

// Value of the max_num_managers parameter.
#define AXI_RT_MAX_NUM_MANAGERS_REG_OFFSET 0x65c

#ifdef __cplusplus
}  // extern "C"
#endif
#endif  // _AXI_RT_REG_DEFS_
// End generated register defines for axi_rt