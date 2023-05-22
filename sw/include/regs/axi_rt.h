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
// Number of masters
#define AXI_RT_PARAM_NUM_MST 24

// Register width
#define AXI_RT_PARAM_REG_WIDTH 32

// Enable RT feature on master (common parameters)
#define AXI_RT_RT_ENABLE_ENABLE_FIELD_WIDTH 1
#define AXI_RT_RT_ENABLE_ENABLE_FIELDS_PER_REG 32
#define AXI_RT_RT_ENABLE_MULTIREG_COUNT 1

// Enable RT feature on master
#define AXI_RT_RT_ENABLE_REG_OFFSET 0x0
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
#define AXI_RT_RT_ENABLE_ENABLE_16_BIT 16
#define AXI_RT_RT_ENABLE_ENABLE_17_BIT 17
#define AXI_RT_RT_ENABLE_ENABLE_18_BIT 18
#define AXI_RT_RT_ENABLE_ENABLE_19_BIT 19
#define AXI_RT_RT_ENABLE_ENABLE_20_BIT 20
#define AXI_RT_RT_ENABLE_ENABLE_21_BIT 21
#define AXI_RT_RT_ENABLE_ENABLE_22_BIT 22
#define AXI_RT_RT_ENABLE_ENABLE_23_BIT 23

// Is the RT inactive? (common parameters)
#define AXI_RT_RT_BYPASSED_BYPASSED_FIELD_WIDTH 1
#define AXI_RT_RT_BYPASSED_BYPASSED_FIELDS_PER_REG 32
#define AXI_RT_RT_BYPASSED_MULTIREG_COUNT 1

// Is the RT inactive?
#define AXI_RT_RT_BYPASSED_REG_OFFSET 0x4
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
#define AXI_RT_RT_BYPASSED_BYPASSED_16_BIT 16
#define AXI_RT_RT_BYPASSED_BYPASSED_17_BIT 17
#define AXI_RT_RT_BYPASSED_BYPASSED_18_BIT 18
#define AXI_RT_RT_BYPASSED_BYPASSED_19_BIT 19
#define AXI_RT_RT_BYPASSED_BYPASSED_20_BIT 20
#define AXI_RT_RT_BYPASSED_BYPASSED_21_BIT 21
#define AXI_RT_RT_BYPASSED_BYPASSED_22_BIT 22
#define AXI_RT_RT_BYPASSED_BYPASSED_23_BIT 23

// Fragmentation of the bursts in beats. (common parameters)
#define AXI_RT_LEN_LIMIT_LEN_FIELD_WIDTH 8
#define AXI_RT_LEN_LIMIT_LEN_FIELDS_PER_REG 4
#define AXI_RT_LEN_LIMIT_MULTIREG_COUNT 6

// Fragmentation of the bursts in beats.
#define AXI_RT_LEN_LIMIT_0_REG_OFFSET 0x8
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
#define AXI_RT_LEN_LIMIT_1_REG_OFFSET 0xc
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
#define AXI_RT_LEN_LIMIT_2_REG_OFFSET 0x10
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
#define AXI_RT_LEN_LIMIT_3_REG_OFFSET 0x14
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

// Fragmentation of the bursts in beats.
#define AXI_RT_LEN_LIMIT_4_REG_OFFSET 0x18
#define AXI_RT_LEN_LIMIT_4_LEN_16_MASK 0xff
#define AXI_RT_LEN_LIMIT_4_LEN_16_OFFSET 0
#define AXI_RT_LEN_LIMIT_4_LEN_16_FIELD \
  ((bitfield_field32_t) { .mask = AXI_RT_LEN_LIMIT_4_LEN_16_MASK, .index = AXI_RT_LEN_LIMIT_4_LEN_16_OFFSET })
#define AXI_RT_LEN_LIMIT_4_LEN_17_MASK 0xff
#define AXI_RT_LEN_LIMIT_4_LEN_17_OFFSET 8
#define AXI_RT_LEN_LIMIT_4_LEN_17_FIELD \
  ((bitfield_field32_t) { .mask = AXI_RT_LEN_LIMIT_4_LEN_17_MASK, .index = AXI_RT_LEN_LIMIT_4_LEN_17_OFFSET })
#define AXI_RT_LEN_LIMIT_4_LEN_18_MASK 0xff
#define AXI_RT_LEN_LIMIT_4_LEN_18_OFFSET 16
#define AXI_RT_LEN_LIMIT_4_LEN_18_FIELD \
  ((bitfield_field32_t) { .mask = AXI_RT_LEN_LIMIT_4_LEN_18_MASK, .index = AXI_RT_LEN_LIMIT_4_LEN_18_OFFSET })
#define AXI_RT_LEN_LIMIT_4_LEN_19_MASK 0xff
#define AXI_RT_LEN_LIMIT_4_LEN_19_OFFSET 24
#define AXI_RT_LEN_LIMIT_4_LEN_19_FIELD \
  ((bitfield_field32_t) { .mask = AXI_RT_LEN_LIMIT_4_LEN_19_MASK, .index = AXI_RT_LEN_LIMIT_4_LEN_19_OFFSET })

// Fragmentation of the bursts in beats.
#define AXI_RT_LEN_LIMIT_5_REG_OFFSET 0x1c
#define AXI_RT_LEN_LIMIT_5_LEN_20_MASK 0xff
#define AXI_RT_LEN_LIMIT_5_LEN_20_OFFSET 0
#define AXI_RT_LEN_LIMIT_5_LEN_20_FIELD \
  ((bitfield_field32_t) { .mask = AXI_RT_LEN_LIMIT_5_LEN_20_MASK, .index = AXI_RT_LEN_LIMIT_5_LEN_20_OFFSET })
#define AXI_RT_LEN_LIMIT_5_LEN_21_MASK 0xff
#define AXI_RT_LEN_LIMIT_5_LEN_21_OFFSET 8
#define AXI_RT_LEN_LIMIT_5_LEN_21_FIELD \
  ((bitfield_field32_t) { .mask = AXI_RT_LEN_LIMIT_5_LEN_21_MASK, .index = AXI_RT_LEN_LIMIT_5_LEN_21_OFFSET })
#define AXI_RT_LEN_LIMIT_5_LEN_22_MASK 0xff
#define AXI_RT_LEN_LIMIT_5_LEN_22_OFFSET 16
#define AXI_RT_LEN_LIMIT_5_LEN_22_FIELD \
  ((bitfield_field32_t) { .mask = AXI_RT_LEN_LIMIT_5_LEN_22_MASK, .index = AXI_RT_LEN_LIMIT_5_LEN_22_OFFSET })
#define AXI_RT_LEN_LIMIT_5_LEN_23_MASK 0xff
#define AXI_RT_LEN_LIMIT_5_LEN_23_OFFSET 24
#define AXI_RT_LEN_LIMIT_5_LEN_23_FIELD \
  ((bitfield_field32_t) { .mask = AXI_RT_LEN_LIMIT_5_LEN_23_MASK, .index = AXI_RT_LEN_LIMIT_5_LEN_23_OFFSET })

// Enables the IMTU. (common parameters)
#define AXI_RT_IMTU_ENABLE_ENABLE_FIELD_WIDTH 1
#define AXI_RT_IMTU_ENABLE_ENABLE_FIELDS_PER_REG 32
#define AXI_RT_IMTU_ENABLE_MULTIREG_COUNT 1

// Enables the IMTU.
#define AXI_RT_IMTU_ENABLE_REG_OFFSET 0x20
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
#define AXI_RT_IMTU_ENABLE_ENABLE_16_BIT 16
#define AXI_RT_IMTU_ENABLE_ENABLE_17_BIT 17
#define AXI_RT_IMTU_ENABLE_ENABLE_18_BIT 18
#define AXI_RT_IMTU_ENABLE_ENABLE_19_BIT 19
#define AXI_RT_IMTU_ENABLE_ENABLE_20_BIT 20
#define AXI_RT_IMTU_ENABLE_ENABLE_21_BIT 21
#define AXI_RT_IMTU_ENABLE_ENABLE_22_BIT 22
#define AXI_RT_IMTU_ENABLE_ENABLE_23_BIT 23

// Resets both the period and the budget. (common parameters)
#define AXI_RT_IMTU_ABORT_ABORT_FIELD_WIDTH 1
#define AXI_RT_IMTU_ABORT_ABORT_FIELDS_PER_REG 32
#define AXI_RT_IMTU_ABORT_MULTIREG_COUNT 1

// Resets both the period and the budget.
#define AXI_RT_IMTU_ABORT_REG_OFFSET 0x24
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
#define AXI_RT_IMTU_ABORT_ABORT_16_BIT 16
#define AXI_RT_IMTU_ABORT_ABORT_17_BIT 17
#define AXI_RT_IMTU_ABORT_ABORT_18_BIT 18
#define AXI_RT_IMTU_ABORT_ABORT_19_BIT 19
#define AXI_RT_IMTU_ABORT_ABORT_20_BIT 20
#define AXI_RT_IMTU_ABORT_ABORT_21_BIT 21
#define AXI_RT_IMTU_ABORT_ABORT_22_BIT 22
#define AXI_RT_IMTU_ABORT_ABORT_23_BIT 23

// The budget for the writes. (common parameters)
#define AXI_RT_WRITE_BUDGET_WRITE_BUDGET_FIELD_WIDTH 32
#define AXI_RT_WRITE_BUDGET_WRITE_BUDGET_FIELDS_PER_REG 1
#define AXI_RT_WRITE_BUDGET_MULTIREG_COUNT 24

// The budget for the writes.
#define AXI_RT_WRITE_BUDGET_0_REG_OFFSET 0x28

// The budget for the writes.
#define AXI_RT_WRITE_BUDGET_1_REG_OFFSET 0x2c

// The budget for the writes.
#define AXI_RT_WRITE_BUDGET_2_REG_OFFSET 0x30

// The budget for the writes.
#define AXI_RT_WRITE_BUDGET_3_REG_OFFSET 0x34

// The budget for the writes.
#define AXI_RT_WRITE_BUDGET_4_REG_OFFSET 0x38

// The budget for the writes.
#define AXI_RT_WRITE_BUDGET_5_REG_OFFSET 0x3c

// The budget for the writes.
#define AXI_RT_WRITE_BUDGET_6_REG_OFFSET 0x40

// The budget for the writes.
#define AXI_RT_WRITE_BUDGET_7_REG_OFFSET 0x44

// The budget for the writes.
#define AXI_RT_WRITE_BUDGET_8_REG_OFFSET 0x48

// The budget for the writes.
#define AXI_RT_WRITE_BUDGET_9_REG_OFFSET 0x4c

// The budget for the writes.
#define AXI_RT_WRITE_BUDGET_10_REG_OFFSET 0x50

// The budget for the writes.
#define AXI_RT_WRITE_BUDGET_11_REG_OFFSET 0x54

// The budget for the writes.
#define AXI_RT_WRITE_BUDGET_12_REG_OFFSET 0x58

// The budget for the writes.
#define AXI_RT_WRITE_BUDGET_13_REG_OFFSET 0x5c

// The budget for the writes.
#define AXI_RT_WRITE_BUDGET_14_REG_OFFSET 0x60

// The budget for the writes.
#define AXI_RT_WRITE_BUDGET_15_REG_OFFSET 0x64

// The budget for the writes.
#define AXI_RT_WRITE_BUDGET_16_REG_OFFSET 0x68

// The budget for the writes.
#define AXI_RT_WRITE_BUDGET_17_REG_OFFSET 0x6c

// The budget for the writes.
#define AXI_RT_WRITE_BUDGET_18_REG_OFFSET 0x70

// The budget for the writes.
#define AXI_RT_WRITE_BUDGET_19_REG_OFFSET 0x74

// The budget for the writes.
#define AXI_RT_WRITE_BUDGET_20_REG_OFFSET 0x78

// The budget for the writes.
#define AXI_RT_WRITE_BUDGET_21_REG_OFFSET 0x7c

// The budget for the writes.
#define AXI_RT_WRITE_BUDGET_22_REG_OFFSET 0x80

// The budget for the writes.
#define AXI_RT_WRITE_BUDGET_23_REG_OFFSET 0x84

// The budget for the reads. (common parameters)
#define AXI_RT_READ_BUDGET_READ_BUDGET_FIELD_WIDTH 32
#define AXI_RT_READ_BUDGET_READ_BUDGET_FIELDS_PER_REG 1
#define AXI_RT_READ_BUDGET_MULTIREG_COUNT 24

// The budget for the reads.
#define AXI_RT_READ_BUDGET_0_REG_OFFSET 0x88

// The budget for the reads.
#define AXI_RT_READ_BUDGET_1_REG_OFFSET 0x8c

// The budget for the reads.
#define AXI_RT_READ_BUDGET_2_REG_OFFSET 0x90

// The budget for the reads.
#define AXI_RT_READ_BUDGET_3_REG_OFFSET 0x94

// The budget for the reads.
#define AXI_RT_READ_BUDGET_4_REG_OFFSET 0x98

// The budget for the reads.
#define AXI_RT_READ_BUDGET_5_REG_OFFSET 0x9c

// The budget for the reads.
#define AXI_RT_READ_BUDGET_6_REG_OFFSET 0xa0

// The budget for the reads.
#define AXI_RT_READ_BUDGET_7_REG_OFFSET 0xa4

// The budget for the reads.
#define AXI_RT_READ_BUDGET_8_REG_OFFSET 0xa8

// The budget for the reads.
#define AXI_RT_READ_BUDGET_9_REG_OFFSET 0xac

// The budget for the reads.
#define AXI_RT_READ_BUDGET_10_REG_OFFSET 0xb0

// The budget for the reads.
#define AXI_RT_READ_BUDGET_11_REG_OFFSET 0xb4

// The budget for the reads.
#define AXI_RT_READ_BUDGET_12_REG_OFFSET 0xb8

// The budget for the reads.
#define AXI_RT_READ_BUDGET_13_REG_OFFSET 0xbc

// The budget for the reads.
#define AXI_RT_READ_BUDGET_14_REG_OFFSET 0xc0

// The budget for the reads.
#define AXI_RT_READ_BUDGET_15_REG_OFFSET 0xc4

// The budget for the reads.
#define AXI_RT_READ_BUDGET_16_REG_OFFSET 0xc8

// The budget for the reads.
#define AXI_RT_READ_BUDGET_17_REG_OFFSET 0xcc

// The budget for the reads.
#define AXI_RT_READ_BUDGET_18_REG_OFFSET 0xd0

// The budget for the reads.
#define AXI_RT_READ_BUDGET_19_REG_OFFSET 0xd4

// The budget for the reads.
#define AXI_RT_READ_BUDGET_20_REG_OFFSET 0xd8

// The budget for the reads.
#define AXI_RT_READ_BUDGET_21_REG_OFFSET 0xdc

// The budget for the reads.
#define AXI_RT_READ_BUDGET_22_REG_OFFSET 0xe0

// The budget for the reads.
#define AXI_RT_READ_BUDGET_23_REG_OFFSET 0xe4

// The period for the writes. (common parameters)
#define AXI_RT_WRITE_PERIOD_WRITE_PERIOD_FIELD_WIDTH 32
#define AXI_RT_WRITE_PERIOD_WRITE_PERIOD_FIELDS_PER_REG 1
#define AXI_RT_WRITE_PERIOD_MULTIREG_COUNT 24

// The period for the writes.
#define AXI_RT_WRITE_PERIOD_0_REG_OFFSET 0xe8

// The period for the writes.
#define AXI_RT_WRITE_PERIOD_1_REG_OFFSET 0xec

// The period for the writes.
#define AXI_RT_WRITE_PERIOD_2_REG_OFFSET 0xf0

// The period for the writes.
#define AXI_RT_WRITE_PERIOD_3_REG_OFFSET 0xf4

// The period for the writes.
#define AXI_RT_WRITE_PERIOD_4_REG_OFFSET 0xf8

// The period for the writes.
#define AXI_RT_WRITE_PERIOD_5_REG_OFFSET 0xfc

// The period for the writes.
#define AXI_RT_WRITE_PERIOD_6_REG_OFFSET 0x100

// The period for the writes.
#define AXI_RT_WRITE_PERIOD_7_REG_OFFSET 0x104

// The period for the writes.
#define AXI_RT_WRITE_PERIOD_8_REG_OFFSET 0x108

// The period for the writes.
#define AXI_RT_WRITE_PERIOD_9_REG_OFFSET 0x10c

// The period for the writes.
#define AXI_RT_WRITE_PERIOD_10_REG_OFFSET 0x110

// The period for the writes.
#define AXI_RT_WRITE_PERIOD_11_REG_OFFSET 0x114

// The period for the writes.
#define AXI_RT_WRITE_PERIOD_12_REG_OFFSET 0x118

// The period for the writes.
#define AXI_RT_WRITE_PERIOD_13_REG_OFFSET 0x11c

// The period for the writes.
#define AXI_RT_WRITE_PERIOD_14_REG_OFFSET 0x120

// The period for the writes.
#define AXI_RT_WRITE_PERIOD_15_REG_OFFSET 0x124

// The period for the writes.
#define AXI_RT_WRITE_PERIOD_16_REG_OFFSET 0x128

// The period for the writes.
#define AXI_RT_WRITE_PERIOD_17_REG_OFFSET 0x12c

// The period for the writes.
#define AXI_RT_WRITE_PERIOD_18_REG_OFFSET 0x130

// The period for the writes.
#define AXI_RT_WRITE_PERIOD_19_REG_OFFSET 0x134

// The period for the writes.
#define AXI_RT_WRITE_PERIOD_20_REG_OFFSET 0x138

// The period for the writes.
#define AXI_RT_WRITE_PERIOD_21_REG_OFFSET 0x13c

// The period for the writes.
#define AXI_RT_WRITE_PERIOD_22_REG_OFFSET 0x140

// The period for the writes.
#define AXI_RT_WRITE_PERIOD_23_REG_OFFSET 0x144

// The period for the reads. (common parameters)
#define AXI_RT_READ_PERIOD_READ_PERIOD_FIELD_WIDTH 32
#define AXI_RT_READ_PERIOD_READ_PERIOD_FIELDS_PER_REG 1
#define AXI_RT_READ_PERIOD_MULTIREG_COUNT 24

// The period for the reads.
#define AXI_RT_READ_PERIOD_0_REG_OFFSET 0x148

// The period for the reads.
#define AXI_RT_READ_PERIOD_1_REG_OFFSET 0x14c

// The period for the reads.
#define AXI_RT_READ_PERIOD_2_REG_OFFSET 0x150

// The period for the reads.
#define AXI_RT_READ_PERIOD_3_REG_OFFSET 0x154

// The period for the reads.
#define AXI_RT_READ_PERIOD_4_REG_OFFSET 0x158

// The period for the reads.
#define AXI_RT_READ_PERIOD_5_REG_OFFSET 0x15c

// The period for the reads.
#define AXI_RT_READ_PERIOD_6_REG_OFFSET 0x160

// The period for the reads.
#define AXI_RT_READ_PERIOD_7_REG_OFFSET 0x164

// The period for the reads.
#define AXI_RT_READ_PERIOD_8_REG_OFFSET 0x168

// The period for the reads.
#define AXI_RT_READ_PERIOD_9_REG_OFFSET 0x16c

// The period for the reads.
#define AXI_RT_READ_PERIOD_10_REG_OFFSET 0x170

// The period for the reads.
#define AXI_RT_READ_PERIOD_11_REG_OFFSET 0x174

// The period for the reads.
#define AXI_RT_READ_PERIOD_12_REG_OFFSET 0x178

// The period for the reads.
#define AXI_RT_READ_PERIOD_13_REG_OFFSET 0x17c

// The period for the reads.
#define AXI_RT_READ_PERIOD_14_REG_OFFSET 0x180

// The period for the reads.
#define AXI_RT_READ_PERIOD_15_REG_OFFSET 0x184

// The period for the reads.
#define AXI_RT_READ_PERIOD_16_REG_OFFSET 0x188

// The period for the reads.
#define AXI_RT_READ_PERIOD_17_REG_OFFSET 0x18c

// The period for the reads.
#define AXI_RT_READ_PERIOD_18_REG_OFFSET 0x190

// The period for the reads.
#define AXI_RT_READ_PERIOD_19_REG_OFFSET 0x194

// The period for the reads.
#define AXI_RT_READ_PERIOD_20_REG_OFFSET 0x198

// The period for the reads.
#define AXI_RT_READ_PERIOD_21_REG_OFFSET 0x19c

// The period for the reads.
#define AXI_RT_READ_PERIOD_22_REG_OFFSET 0x1a0

// The period for the reads.
#define AXI_RT_READ_PERIOD_23_REG_OFFSET 0x1a4

// The budget left for the writes. (common parameters)
#define AXI_RT_WRITE_BUDGET_LEFT_WRITE_BUDGET_LEFT_FIELD_WIDTH 32
#define AXI_RT_WRITE_BUDGET_LEFT_WRITE_BUDGET_LEFT_FIELDS_PER_REG 1
#define AXI_RT_WRITE_BUDGET_LEFT_MULTIREG_COUNT 24

// The budget left for the writes.
#define AXI_RT_WRITE_BUDGET_LEFT_0_REG_OFFSET 0x1a8

// The budget left for the writes.
#define AXI_RT_WRITE_BUDGET_LEFT_1_REG_OFFSET 0x1ac

// The budget left for the writes.
#define AXI_RT_WRITE_BUDGET_LEFT_2_REG_OFFSET 0x1b0

// The budget left for the writes.
#define AXI_RT_WRITE_BUDGET_LEFT_3_REG_OFFSET 0x1b4

// The budget left for the writes.
#define AXI_RT_WRITE_BUDGET_LEFT_4_REG_OFFSET 0x1b8

// The budget left for the writes.
#define AXI_RT_WRITE_BUDGET_LEFT_5_REG_OFFSET 0x1bc

// The budget left for the writes.
#define AXI_RT_WRITE_BUDGET_LEFT_6_REG_OFFSET 0x1c0

// The budget left for the writes.
#define AXI_RT_WRITE_BUDGET_LEFT_7_REG_OFFSET 0x1c4

// The budget left for the writes.
#define AXI_RT_WRITE_BUDGET_LEFT_8_REG_OFFSET 0x1c8

// The budget left for the writes.
#define AXI_RT_WRITE_BUDGET_LEFT_9_REG_OFFSET 0x1cc

// The budget left for the writes.
#define AXI_RT_WRITE_BUDGET_LEFT_10_REG_OFFSET 0x1d0

// The budget left for the writes.
#define AXI_RT_WRITE_BUDGET_LEFT_11_REG_OFFSET 0x1d4

// The budget left for the writes.
#define AXI_RT_WRITE_BUDGET_LEFT_12_REG_OFFSET 0x1d8

// The budget left for the writes.
#define AXI_RT_WRITE_BUDGET_LEFT_13_REG_OFFSET 0x1dc

// The budget left for the writes.
#define AXI_RT_WRITE_BUDGET_LEFT_14_REG_OFFSET 0x1e0

// The budget left for the writes.
#define AXI_RT_WRITE_BUDGET_LEFT_15_REG_OFFSET 0x1e4

// The budget left for the writes.
#define AXI_RT_WRITE_BUDGET_LEFT_16_REG_OFFSET 0x1e8

// The budget left for the writes.
#define AXI_RT_WRITE_BUDGET_LEFT_17_REG_OFFSET 0x1ec

// The budget left for the writes.
#define AXI_RT_WRITE_BUDGET_LEFT_18_REG_OFFSET 0x1f0

// The budget left for the writes.
#define AXI_RT_WRITE_BUDGET_LEFT_19_REG_OFFSET 0x1f4

// The budget left for the writes.
#define AXI_RT_WRITE_BUDGET_LEFT_20_REG_OFFSET 0x1f8

// The budget left for the writes.
#define AXI_RT_WRITE_BUDGET_LEFT_21_REG_OFFSET 0x1fc

// The budget left for the writes.
#define AXI_RT_WRITE_BUDGET_LEFT_22_REG_OFFSET 0x200

// The budget left for the writes.
#define AXI_RT_WRITE_BUDGET_LEFT_23_REG_OFFSET 0x204

// The budget left for the reads. (common parameters)
#define AXI_RT_READ_BUDGET_LEFT_READ_BUDGET_LEFT_FIELD_WIDTH 32
#define AXI_RT_READ_BUDGET_LEFT_READ_BUDGET_LEFT_FIELDS_PER_REG 1
#define AXI_RT_READ_BUDGET_LEFT_MULTIREG_COUNT 24

// The budget left for the reads.
#define AXI_RT_READ_BUDGET_LEFT_0_REG_OFFSET 0x208

// The budget left for the reads.
#define AXI_RT_READ_BUDGET_LEFT_1_REG_OFFSET 0x20c

// The budget left for the reads.
#define AXI_RT_READ_BUDGET_LEFT_2_REG_OFFSET 0x210

// The budget left for the reads.
#define AXI_RT_READ_BUDGET_LEFT_3_REG_OFFSET 0x214

// The budget left for the reads.
#define AXI_RT_READ_BUDGET_LEFT_4_REG_OFFSET 0x218

// The budget left for the reads.
#define AXI_RT_READ_BUDGET_LEFT_5_REG_OFFSET 0x21c

// The budget left for the reads.
#define AXI_RT_READ_BUDGET_LEFT_6_REG_OFFSET 0x220

// The budget left for the reads.
#define AXI_RT_READ_BUDGET_LEFT_7_REG_OFFSET 0x224

// The budget left for the reads.
#define AXI_RT_READ_BUDGET_LEFT_8_REG_OFFSET 0x228

// The budget left for the reads.
#define AXI_RT_READ_BUDGET_LEFT_9_REG_OFFSET 0x22c

// The budget left for the reads.
#define AXI_RT_READ_BUDGET_LEFT_10_REG_OFFSET 0x230

// The budget left for the reads.
#define AXI_RT_READ_BUDGET_LEFT_11_REG_OFFSET 0x234

// The budget left for the reads.
#define AXI_RT_READ_BUDGET_LEFT_12_REG_OFFSET 0x238

// The budget left for the reads.
#define AXI_RT_READ_BUDGET_LEFT_13_REG_OFFSET 0x23c

// The budget left for the reads.
#define AXI_RT_READ_BUDGET_LEFT_14_REG_OFFSET 0x240

// The budget left for the reads.
#define AXI_RT_READ_BUDGET_LEFT_15_REG_OFFSET 0x244

// The budget left for the reads.
#define AXI_RT_READ_BUDGET_LEFT_16_REG_OFFSET 0x248

// The budget left for the reads.
#define AXI_RT_READ_BUDGET_LEFT_17_REG_OFFSET 0x24c

// The budget left for the reads.
#define AXI_RT_READ_BUDGET_LEFT_18_REG_OFFSET 0x250

// The budget left for the reads.
#define AXI_RT_READ_BUDGET_LEFT_19_REG_OFFSET 0x254

// The budget left for the reads.
#define AXI_RT_READ_BUDGET_LEFT_20_REG_OFFSET 0x258

// The budget left for the reads.
#define AXI_RT_READ_BUDGET_LEFT_21_REG_OFFSET 0x25c

// The budget left for the reads.
#define AXI_RT_READ_BUDGET_LEFT_22_REG_OFFSET 0x260

// The budget left for the reads.
#define AXI_RT_READ_BUDGET_LEFT_23_REG_OFFSET 0x264

// The period left for the writes. (common parameters)
#define AXI_RT_WRITE_PERIOD_LEFT_WRITE_PERIOD_LEFT_FIELD_WIDTH 32
#define AXI_RT_WRITE_PERIOD_LEFT_WRITE_PERIOD_LEFT_FIELDS_PER_REG 1
#define AXI_RT_WRITE_PERIOD_LEFT_MULTIREG_COUNT 24

// The period left for the writes.
#define AXI_RT_WRITE_PERIOD_LEFT_0_REG_OFFSET 0x268

// The period left for the writes.
#define AXI_RT_WRITE_PERIOD_LEFT_1_REG_OFFSET 0x26c

// The period left for the writes.
#define AXI_RT_WRITE_PERIOD_LEFT_2_REG_OFFSET 0x270

// The period left for the writes.
#define AXI_RT_WRITE_PERIOD_LEFT_3_REG_OFFSET 0x274

// The period left for the writes.
#define AXI_RT_WRITE_PERIOD_LEFT_4_REG_OFFSET 0x278

// The period left for the writes.
#define AXI_RT_WRITE_PERIOD_LEFT_5_REG_OFFSET 0x27c

// The period left for the writes.
#define AXI_RT_WRITE_PERIOD_LEFT_6_REG_OFFSET 0x280

// The period left for the writes.
#define AXI_RT_WRITE_PERIOD_LEFT_7_REG_OFFSET 0x284

// The period left for the writes.
#define AXI_RT_WRITE_PERIOD_LEFT_8_REG_OFFSET 0x288

// The period left for the writes.
#define AXI_RT_WRITE_PERIOD_LEFT_9_REG_OFFSET 0x28c

// The period left for the writes.
#define AXI_RT_WRITE_PERIOD_LEFT_10_REG_OFFSET 0x290

// The period left for the writes.
#define AXI_RT_WRITE_PERIOD_LEFT_11_REG_OFFSET 0x294

// The period left for the writes.
#define AXI_RT_WRITE_PERIOD_LEFT_12_REG_OFFSET 0x298

// The period left for the writes.
#define AXI_RT_WRITE_PERIOD_LEFT_13_REG_OFFSET 0x29c

// The period left for the writes.
#define AXI_RT_WRITE_PERIOD_LEFT_14_REG_OFFSET 0x2a0

// The period left for the writes.
#define AXI_RT_WRITE_PERIOD_LEFT_15_REG_OFFSET 0x2a4

// The period left for the writes.
#define AXI_RT_WRITE_PERIOD_LEFT_16_REG_OFFSET 0x2a8

// The period left for the writes.
#define AXI_RT_WRITE_PERIOD_LEFT_17_REG_OFFSET 0x2ac

// The period left for the writes.
#define AXI_RT_WRITE_PERIOD_LEFT_18_REG_OFFSET 0x2b0

// The period left for the writes.
#define AXI_RT_WRITE_PERIOD_LEFT_19_REG_OFFSET 0x2b4

// The period left for the writes.
#define AXI_RT_WRITE_PERIOD_LEFT_20_REG_OFFSET 0x2b8

// The period left for the writes.
#define AXI_RT_WRITE_PERIOD_LEFT_21_REG_OFFSET 0x2bc

// The period left for the writes.
#define AXI_RT_WRITE_PERIOD_LEFT_22_REG_OFFSET 0x2c0

// The period left for the writes.
#define AXI_RT_WRITE_PERIOD_LEFT_23_REG_OFFSET 0x2c4

// The period left for the reads. (common parameters)
#define AXI_RT_READ_PERIOD_LEFT_READ_PERIOD_LEFT_FIELD_WIDTH 32
#define AXI_RT_READ_PERIOD_LEFT_READ_PERIOD_LEFT_FIELDS_PER_REG 1
#define AXI_RT_READ_PERIOD_LEFT_MULTIREG_COUNT 24

// The period left for the reads.
#define AXI_RT_READ_PERIOD_LEFT_0_REG_OFFSET 0x2c8

// The period left for the reads.
#define AXI_RT_READ_PERIOD_LEFT_1_REG_OFFSET 0x2cc

// The period left for the reads.
#define AXI_RT_READ_PERIOD_LEFT_2_REG_OFFSET 0x2d0

// The period left for the reads.
#define AXI_RT_READ_PERIOD_LEFT_3_REG_OFFSET 0x2d4

// The period left for the reads.
#define AXI_RT_READ_PERIOD_LEFT_4_REG_OFFSET 0x2d8

// The period left for the reads.
#define AXI_RT_READ_PERIOD_LEFT_5_REG_OFFSET 0x2dc

// The period left for the reads.
#define AXI_RT_READ_PERIOD_LEFT_6_REG_OFFSET 0x2e0

// The period left for the reads.
#define AXI_RT_READ_PERIOD_LEFT_7_REG_OFFSET 0x2e4

// The period left for the reads.
#define AXI_RT_READ_PERIOD_LEFT_8_REG_OFFSET 0x2e8

// The period left for the reads.
#define AXI_RT_READ_PERIOD_LEFT_9_REG_OFFSET 0x2ec

// The period left for the reads.
#define AXI_RT_READ_PERIOD_LEFT_10_REG_OFFSET 0x2f0

// The period left for the reads.
#define AXI_RT_READ_PERIOD_LEFT_11_REG_OFFSET 0x2f4

// The period left for the reads.
#define AXI_RT_READ_PERIOD_LEFT_12_REG_OFFSET 0x2f8

// The period left for the reads.
#define AXI_RT_READ_PERIOD_LEFT_13_REG_OFFSET 0x2fc

// The period left for the reads.
#define AXI_RT_READ_PERIOD_LEFT_14_REG_OFFSET 0x300

// The period left for the reads.
#define AXI_RT_READ_PERIOD_LEFT_15_REG_OFFSET 0x304

// The period left for the reads.
#define AXI_RT_READ_PERIOD_LEFT_16_REG_OFFSET 0x308

// The period left for the reads.
#define AXI_RT_READ_PERIOD_LEFT_17_REG_OFFSET 0x30c

// The period left for the reads.
#define AXI_RT_READ_PERIOD_LEFT_18_REG_OFFSET 0x310

// The period left for the reads.
#define AXI_RT_READ_PERIOD_LEFT_19_REG_OFFSET 0x314

// The period left for the reads.
#define AXI_RT_READ_PERIOD_LEFT_20_REG_OFFSET 0x318

// The period left for the reads.
#define AXI_RT_READ_PERIOD_LEFT_21_REG_OFFSET 0x31c

// The period left for the reads.
#define AXI_RT_READ_PERIOD_LEFT_22_REG_OFFSET 0x320

// The period left for the reads.
#define AXI_RT_READ_PERIOD_LEFT_23_REG_OFFSET 0x324

// Is the interface requested to be isolated? (common parameters)
#define AXI_RT_ISOLATE_ISOLATE_FIELD_WIDTH 1
#define AXI_RT_ISOLATE_ISOLATE_FIELDS_PER_REG 32
#define AXI_RT_ISOLATE_MULTIREG_COUNT 1

// Is the interface requested to be isolated?
#define AXI_RT_ISOLATE_REG_OFFSET 0x328
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
#define AXI_RT_ISOLATE_ISOLATE_16_BIT 16
#define AXI_RT_ISOLATE_ISOLATE_17_BIT 17
#define AXI_RT_ISOLATE_ISOLATE_18_BIT 18
#define AXI_RT_ISOLATE_ISOLATE_19_BIT 19
#define AXI_RT_ISOLATE_ISOLATE_20_BIT 20
#define AXI_RT_ISOLATE_ISOLATE_21_BIT 21
#define AXI_RT_ISOLATE_ISOLATE_22_BIT 22
#define AXI_RT_ISOLATE_ISOLATE_23_BIT 23

// Is the interface isolated? (common parameters)
#define AXI_RT_ISOLATED_ISOLATED_FIELD_WIDTH 1
#define AXI_RT_ISOLATED_ISOLATED_FIELDS_PER_REG 32
#define AXI_RT_ISOLATED_MULTIREG_COUNT 1

// Is the interface isolated?
#define AXI_RT_ISOLATED_REG_OFFSET 0x32c
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
#define AXI_RT_ISOLATED_ISOLATED_16_BIT 16
#define AXI_RT_ISOLATED_ISOLATED_17_BIT 17
#define AXI_RT_ISOLATED_ISOLATED_18_BIT 18
#define AXI_RT_ISOLATED_ISOLATED_19_BIT 19
#define AXI_RT_ISOLATED_ISOLATED_20_BIT 20
#define AXI_RT_ISOLATED_ISOLATED_21_BIT 21
#define AXI_RT_ISOLATED_ISOLATED_22_BIT 22
#define AXI_RT_ISOLATED_ISOLATED_23_BIT 23

#ifdef __cplusplus
}  // extern "C"
#endif
#endif  // _AXI_RT_REG_DEFS_
// End generated register defines for axi_rt