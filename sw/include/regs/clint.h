// Generated register defines for CLINT

// Copyright information found in source file:
// Copyright 2020 ETH Zurich and University of Bologna.

// Licensing information found in source file:
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#ifndef _CLINT_REG_DEFS_
#define _CLINT_REG_DEFS_

#ifdef __cplusplus
extern "C" {
#endif
// Number of cores
#define CLINT_PARAM_NUM_CORES 46

// Register width
#define CLINT_PARAM_REG_WIDTH 32

// Machine Software Interrupt Pending  (common parameters)
// Machine Software Interrupt Pending
#define CLINT_MSIP_0_REG_OFFSET 0x0
#define CLINT_MSIP_0_P_0_BIT 0
#define CLINT_MSIP_0_RSVD_0_MASK 0x7fffffff
#define CLINT_MSIP_0_RSVD_0_OFFSET 1
#define CLINT_MSIP_0_RSVD_0_FIELD \
  ((bitfield_field32_t) { .mask = CLINT_MSIP_0_RSVD_0_MASK, .index = CLINT_MSIP_0_RSVD_0_OFFSET })

// Machine Software Interrupt Pending
#define CLINT_MSIP_1_REG_OFFSET 0x4
#define CLINT_MSIP_1_P_1_BIT 0
#define CLINT_MSIP_1_RSVD_1_MASK 0x7fffffff
#define CLINT_MSIP_1_RSVD_1_OFFSET 1
#define CLINT_MSIP_1_RSVD_1_FIELD \
  ((bitfield_field32_t) { .mask = CLINT_MSIP_1_RSVD_1_MASK, .index = CLINT_MSIP_1_RSVD_1_OFFSET })

// Machine Software Interrupt Pending
#define CLINT_MSIP_2_REG_OFFSET 0x8
#define CLINT_MSIP_2_P_2_BIT 0
#define CLINT_MSIP_2_RSVD_2_MASK 0x7fffffff
#define CLINT_MSIP_2_RSVD_2_OFFSET 1
#define CLINT_MSIP_2_RSVD_2_FIELD \
  ((bitfield_field32_t) { .mask = CLINT_MSIP_2_RSVD_2_MASK, .index = CLINT_MSIP_2_RSVD_2_OFFSET })

// Machine Software Interrupt Pending
#define CLINT_MSIP_3_REG_OFFSET 0xc
#define CLINT_MSIP_3_P_3_BIT 0
#define CLINT_MSIP_3_RSVD_3_MASK 0x7fffffff
#define CLINT_MSIP_3_RSVD_3_OFFSET 1
#define CLINT_MSIP_3_RSVD_3_FIELD \
  ((bitfield_field32_t) { .mask = CLINT_MSIP_3_RSVD_3_MASK, .index = CLINT_MSIP_3_RSVD_3_OFFSET })

// Machine Software Interrupt Pending
#define CLINT_MSIP_4_REG_OFFSET 0x10
#define CLINT_MSIP_4_P_4_BIT 0
#define CLINT_MSIP_4_RSVD_4_MASK 0x7fffffff
#define CLINT_MSIP_4_RSVD_4_OFFSET 1
#define CLINT_MSIP_4_RSVD_4_FIELD \
  ((bitfield_field32_t) { .mask = CLINT_MSIP_4_RSVD_4_MASK, .index = CLINT_MSIP_4_RSVD_4_OFFSET })

// Machine Software Interrupt Pending
#define CLINT_MSIP_5_REG_OFFSET 0x14
#define CLINT_MSIP_5_P_5_BIT 0
#define CLINT_MSIP_5_RSVD_5_MASK 0x7fffffff
#define CLINT_MSIP_5_RSVD_5_OFFSET 1
#define CLINT_MSIP_5_RSVD_5_FIELD \
  ((bitfield_field32_t) { .mask = CLINT_MSIP_5_RSVD_5_MASK, .index = CLINT_MSIP_5_RSVD_5_OFFSET })

// Machine Software Interrupt Pending
#define CLINT_MSIP_6_REG_OFFSET 0x18
#define CLINT_MSIP_6_P_6_BIT 0
#define CLINT_MSIP_6_RSVD_6_MASK 0x7fffffff
#define CLINT_MSIP_6_RSVD_6_OFFSET 1
#define CLINT_MSIP_6_RSVD_6_FIELD \
  ((bitfield_field32_t) { .mask = CLINT_MSIP_6_RSVD_6_MASK, .index = CLINT_MSIP_6_RSVD_6_OFFSET })

// Machine Software Interrupt Pending
#define CLINT_MSIP_7_REG_OFFSET 0x1c
#define CLINT_MSIP_7_P_7_BIT 0
#define CLINT_MSIP_7_RSVD_7_MASK 0x7fffffff
#define CLINT_MSIP_7_RSVD_7_OFFSET 1
#define CLINT_MSIP_7_RSVD_7_FIELD \
  ((bitfield_field32_t) { .mask = CLINT_MSIP_7_RSVD_7_MASK, .index = CLINT_MSIP_7_RSVD_7_OFFSET })

// Machine Software Interrupt Pending
#define CLINT_MSIP_8_REG_OFFSET 0x20
#define CLINT_MSIP_8_P_8_BIT 0
#define CLINT_MSIP_8_RSVD_8_MASK 0x7fffffff
#define CLINT_MSIP_8_RSVD_8_OFFSET 1
#define CLINT_MSIP_8_RSVD_8_FIELD \
  ((bitfield_field32_t) { .mask = CLINT_MSIP_8_RSVD_8_MASK, .index = CLINT_MSIP_8_RSVD_8_OFFSET })

// Machine Software Interrupt Pending
#define CLINT_MSIP_9_REG_OFFSET 0x24
#define CLINT_MSIP_9_P_9_BIT 0
#define CLINT_MSIP_9_RSVD_9_MASK 0x7fffffff
#define CLINT_MSIP_9_RSVD_9_OFFSET 1
#define CLINT_MSIP_9_RSVD_9_FIELD \
  ((bitfield_field32_t) { .mask = CLINT_MSIP_9_RSVD_9_MASK, .index = CLINT_MSIP_9_RSVD_9_OFFSET })

// Machine Software Interrupt Pending
#define CLINT_MSIP_10_REG_OFFSET 0x28
#define CLINT_MSIP_10_P_10_BIT 0
#define CLINT_MSIP_10_RSVD_10_MASK 0x7fffffff
#define CLINT_MSIP_10_RSVD_10_OFFSET 1
#define CLINT_MSIP_10_RSVD_10_FIELD \
  ((bitfield_field32_t) { .mask = CLINT_MSIP_10_RSVD_10_MASK, .index = CLINT_MSIP_10_RSVD_10_OFFSET })

// Machine Software Interrupt Pending
#define CLINT_MSIP_11_REG_OFFSET 0x2c
#define CLINT_MSIP_11_P_11_BIT 0
#define CLINT_MSIP_11_RSVD_11_MASK 0x7fffffff
#define CLINT_MSIP_11_RSVD_11_OFFSET 1
#define CLINT_MSIP_11_RSVD_11_FIELD \
  ((bitfield_field32_t) { .mask = CLINT_MSIP_11_RSVD_11_MASK, .index = CLINT_MSIP_11_RSVD_11_OFFSET })

// Machine Software Interrupt Pending
#define CLINT_MSIP_12_REG_OFFSET 0x30
#define CLINT_MSIP_12_P_12_BIT 0
#define CLINT_MSIP_12_RSVD_12_MASK 0x7fffffff
#define CLINT_MSIP_12_RSVD_12_OFFSET 1
#define CLINT_MSIP_12_RSVD_12_FIELD \
  ((bitfield_field32_t) { .mask = CLINT_MSIP_12_RSVD_12_MASK, .index = CLINT_MSIP_12_RSVD_12_OFFSET })

// Machine Software Interrupt Pending
#define CLINT_MSIP_13_REG_OFFSET 0x34
#define CLINT_MSIP_13_P_13_BIT 0
#define CLINT_MSIP_13_RSVD_13_MASK 0x7fffffff
#define CLINT_MSIP_13_RSVD_13_OFFSET 1
#define CLINT_MSIP_13_RSVD_13_FIELD \
  ((bitfield_field32_t) { .mask = CLINT_MSIP_13_RSVD_13_MASK, .index = CLINT_MSIP_13_RSVD_13_OFFSET })

// Machine Software Interrupt Pending
#define CLINT_MSIP_14_REG_OFFSET 0x38
#define CLINT_MSIP_14_P_14_BIT 0
#define CLINT_MSIP_14_RSVD_14_MASK 0x7fffffff
#define CLINT_MSIP_14_RSVD_14_OFFSET 1
#define CLINT_MSIP_14_RSVD_14_FIELD \
  ((bitfield_field32_t) { .mask = CLINT_MSIP_14_RSVD_14_MASK, .index = CLINT_MSIP_14_RSVD_14_OFFSET })

// Machine Software Interrupt Pending
#define CLINT_MSIP_15_REG_OFFSET 0x3c
#define CLINT_MSIP_15_P_15_BIT 0
#define CLINT_MSIP_15_RSVD_15_MASK 0x7fffffff
#define CLINT_MSIP_15_RSVD_15_OFFSET 1
#define CLINT_MSIP_15_RSVD_15_FIELD \
  ((bitfield_field32_t) { .mask = CLINT_MSIP_15_RSVD_15_MASK, .index = CLINT_MSIP_15_RSVD_15_OFFSET })

// Machine Software Interrupt Pending
#define CLINT_MSIP_16_REG_OFFSET 0x40
#define CLINT_MSIP_16_P_16_BIT 0
#define CLINT_MSIP_16_RSVD_16_MASK 0x7fffffff
#define CLINT_MSIP_16_RSVD_16_OFFSET 1
#define CLINT_MSIP_16_RSVD_16_FIELD \
  ((bitfield_field32_t) { .mask = CLINT_MSIP_16_RSVD_16_MASK, .index = CLINT_MSIP_16_RSVD_16_OFFSET })

// Machine Software Interrupt Pending
#define CLINT_MSIP_17_REG_OFFSET 0x44
#define CLINT_MSIP_17_P_17_BIT 0
#define CLINT_MSIP_17_RSVD_17_MASK 0x7fffffff
#define CLINT_MSIP_17_RSVD_17_OFFSET 1
#define CLINT_MSIP_17_RSVD_17_FIELD \
  ((bitfield_field32_t) { .mask = CLINT_MSIP_17_RSVD_17_MASK, .index = CLINT_MSIP_17_RSVD_17_OFFSET })

// Machine Software Interrupt Pending
#define CLINT_MSIP_18_REG_OFFSET 0x48
#define CLINT_MSIP_18_P_18_BIT 0
#define CLINT_MSIP_18_RSVD_18_MASK 0x7fffffff
#define CLINT_MSIP_18_RSVD_18_OFFSET 1
#define CLINT_MSIP_18_RSVD_18_FIELD \
  ((bitfield_field32_t) { .mask = CLINT_MSIP_18_RSVD_18_MASK, .index = CLINT_MSIP_18_RSVD_18_OFFSET })

// Machine Software Interrupt Pending
#define CLINT_MSIP_19_REG_OFFSET 0x4c
#define CLINT_MSIP_19_P_19_BIT 0
#define CLINT_MSIP_19_RSVD_19_MASK 0x7fffffff
#define CLINT_MSIP_19_RSVD_19_OFFSET 1
#define CLINT_MSIP_19_RSVD_19_FIELD \
  ((bitfield_field32_t) { .mask = CLINT_MSIP_19_RSVD_19_MASK, .index = CLINT_MSIP_19_RSVD_19_OFFSET })

// Machine Software Interrupt Pending
#define CLINT_MSIP_20_REG_OFFSET 0x50
#define CLINT_MSIP_20_P_20_BIT 0
#define CLINT_MSIP_20_RSVD_20_MASK 0x7fffffff
#define CLINT_MSIP_20_RSVD_20_OFFSET 1
#define CLINT_MSIP_20_RSVD_20_FIELD \
  ((bitfield_field32_t) { .mask = CLINT_MSIP_20_RSVD_20_MASK, .index = CLINT_MSIP_20_RSVD_20_OFFSET })

// Machine Software Interrupt Pending
#define CLINT_MSIP_21_REG_OFFSET 0x54
#define CLINT_MSIP_21_P_21_BIT 0
#define CLINT_MSIP_21_RSVD_21_MASK 0x7fffffff
#define CLINT_MSIP_21_RSVD_21_OFFSET 1
#define CLINT_MSIP_21_RSVD_21_FIELD \
  ((bitfield_field32_t) { .mask = CLINT_MSIP_21_RSVD_21_MASK, .index = CLINT_MSIP_21_RSVD_21_OFFSET })

// Machine Software Interrupt Pending
#define CLINT_MSIP_22_REG_OFFSET 0x58
#define CLINT_MSIP_22_P_22_BIT 0
#define CLINT_MSIP_22_RSVD_22_MASK 0x7fffffff
#define CLINT_MSIP_22_RSVD_22_OFFSET 1
#define CLINT_MSIP_22_RSVD_22_FIELD \
  ((bitfield_field32_t) { .mask = CLINT_MSIP_22_RSVD_22_MASK, .index = CLINT_MSIP_22_RSVD_22_OFFSET })

// Machine Software Interrupt Pending
#define CLINT_MSIP_23_REG_OFFSET 0x5c
#define CLINT_MSIP_23_P_23_BIT 0
#define CLINT_MSIP_23_RSVD_23_MASK 0x7fffffff
#define CLINT_MSIP_23_RSVD_23_OFFSET 1
#define CLINT_MSIP_23_RSVD_23_FIELD \
  ((bitfield_field32_t) { .mask = CLINT_MSIP_23_RSVD_23_MASK, .index = CLINT_MSIP_23_RSVD_23_OFFSET })

// Machine Software Interrupt Pending
#define CLINT_MSIP_24_REG_OFFSET 0x60
#define CLINT_MSIP_24_P_24_BIT 0
#define CLINT_MSIP_24_RSVD_24_MASK 0x7fffffff
#define CLINT_MSIP_24_RSVD_24_OFFSET 1
#define CLINT_MSIP_24_RSVD_24_FIELD \
  ((bitfield_field32_t) { .mask = CLINT_MSIP_24_RSVD_24_MASK, .index = CLINT_MSIP_24_RSVD_24_OFFSET })

// Machine Software Interrupt Pending
#define CLINT_MSIP_25_REG_OFFSET 0x64
#define CLINT_MSIP_25_P_25_BIT 0
#define CLINT_MSIP_25_RSVD_25_MASK 0x7fffffff
#define CLINT_MSIP_25_RSVD_25_OFFSET 1
#define CLINT_MSIP_25_RSVD_25_FIELD \
  ((bitfield_field32_t) { .mask = CLINT_MSIP_25_RSVD_25_MASK, .index = CLINT_MSIP_25_RSVD_25_OFFSET })

// Machine Software Interrupt Pending
#define CLINT_MSIP_26_REG_OFFSET 0x68
#define CLINT_MSIP_26_P_26_BIT 0
#define CLINT_MSIP_26_RSVD_26_MASK 0x7fffffff
#define CLINT_MSIP_26_RSVD_26_OFFSET 1
#define CLINT_MSIP_26_RSVD_26_FIELD \
  ((bitfield_field32_t) { .mask = CLINT_MSIP_26_RSVD_26_MASK, .index = CLINT_MSIP_26_RSVD_26_OFFSET })

// Machine Software Interrupt Pending
#define CLINT_MSIP_27_REG_OFFSET 0x6c
#define CLINT_MSIP_27_P_27_BIT 0
#define CLINT_MSIP_27_RSVD_27_MASK 0x7fffffff
#define CLINT_MSIP_27_RSVD_27_OFFSET 1
#define CLINT_MSIP_27_RSVD_27_FIELD \
  ((bitfield_field32_t) { .mask = CLINT_MSIP_27_RSVD_27_MASK, .index = CLINT_MSIP_27_RSVD_27_OFFSET })

// Machine Software Interrupt Pending
#define CLINT_MSIP_28_REG_OFFSET 0x70
#define CLINT_MSIP_28_P_28_BIT 0
#define CLINT_MSIP_28_RSVD_28_MASK 0x7fffffff
#define CLINT_MSIP_28_RSVD_28_OFFSET 1
#define CLINT_MSIP_28_RSVD_28_FIELD \
  ((bitfield_field32_t) { .mask = CLINT_MSIP_28_RSVD_28_MASK, .index = CLINT_MSIP_28_RSVD_28_OFFSET })

// Machine Software Interrupt Pending
#define CLINT_MSIP_29_REG_OFFSET 0x74
#define CLINT_MSIP_29_P_29_BIT 0
#define CLINT_MSIP_29_RSVD_29_MASK 0x7fffffff
#define CLINT_MSIP_29_RSVD_29_OFFSET 1
#define CLINT_MSIP_29_RSVD_29_FIELD \
  ((bitfield_field32_t) { .mask = CLINT_MSIP_29_RSVD_29_MASK, .index = CLINT_MSIP_29_RSVD_29_OFFSET })

// Machine Software Interrupt Pending
#define CLINT_MSIP_30_REG_OFFSET 0x78
#define CLINT_MSIP_30_P_30_BIT 0
#define CLINT_MSIP_30_RSVD_30_MASK 0x7fffffff
#define CLINT_MSIP_30_RSVD_30_OFFSET 1
#define CLINT_MSIP_30_RSVD_30_FIELD \
  ((bitfield_field32_t) { .mask = CLINT_MSIP_30_RSVD_30_MASK, .index = CLINT_MSIP_30_RSVD_30_OFFSET })

// Machine Software Interrupt Pending
#define CLINT_MSIP_31_REG_OFFSET 0x7c
#define CLINT_MSIP_31_P_31_BIT 0
#define CLINT_MSIP_31_RSVD_31_MASK 0x7fffffff
#define CLINT_MSIP_31_RSVD_31_OFFSET 1
#define CLINT_MSIP_31_RSVD_31_FIELD \
  ((bitfield_field32_t) { .mask = CLINT_MSIP_31_RSVD_31_MASK, .index = CLINT_MSIP_31_RSVD_31_OFFSET })

// Machine Software Interrupt Pending
#define CLINT_MSIP_32_REG_OFFSET 0x80
#define CLINT_MSIP_32_P_32_BIT 0
#define CLINT_MSIP_32_RSVD_32_MASK 0x7fffffff
#define CLINT_MSIP_32_RSVD_32_OFFSET 1
#define CLINT_MSIP_32_RSVD_32_FIELD \
  ((bitfield_field32_t) { .mask = CLINT_MSIP_32_RSVD_32_MASK, .index = CLINT_MSIP_32_RSVD_32_OFFSET })

// Machine Software Interrupt Pending
#define CLINT_MSIP_33_REG_OFFSET 0x84
#define CLINT_MSIP_33_P_33_BIT 0
#define CLINT_MSIP_33_RSVD_33_MASK 0x7fffffff
#define CLINT_MSIP_33_RSVD_33_OFFSET 1
#define CLINT_MSIP_33_RSVD_33_FIELD \
  ((bitfield_field32_t) { .mask = CLINT_MSIP_33_RSVD_33_MASK, .index = CLINT_MSIP_33_RSVD_33_OFFSET })

// Machine Software Interrupt Pending
#define CLINT_MSIP_34_REG_OFFSET 0x88
#define CLINT_MSIP_34_P_34_BIT 0
#define CLINT_MSIP_34_RSVD_34_MASK 0x7fffffff
#define CLINT_MSIP_34_RSVD_34_OFFSET 1
#define CLINT_MSIP_34_RSVD_34_FIELD \
  ((bitfield_field32_t) { .mask = CLINT_MSIP_34_RSVD_34_MASK, .index = CLINT_MSIP_34_RSVD_34_OFFSET })

// Machine Software Interrupt Pending
#define CLINT_MSIP_35_REG_OFFSET 0x8c
#define CLINT_MSIP_35_P_35_BIT 0
#define CLINT_MSIP_35_RSVD_35_MASK 0x7fffffff
#define CLINT_MSIP_35_RSVD_35_OFFSET 1
#define CLINT_MSIP_35_RSVD_35_FIELD \
  ((bitfield_field32_t) { .mask = CLINT_MSIP_35_RSVD_35_MASK, .index = CLINT_MSIP_35_RSVD_35_OFFSET })

// Machine Software Interrupt Pending
#define CLINT_MSIP_36_REG_OFFSET 0x90
#define CLINT_MSIP_36_P_36_BIT 0
#define CLINT_MSIP_36_RSVD_36_MASK 0x7fffffff
#define CLINT_MSIP_36_RSVD_36_OFFSET 1
#define CLINT_MSIP_36_RSVD_36_FIELD \
  ((bitfield_field32_t) { .mask = CLINT_MSIP_36_RSVD_36_MASK, .index = CLINT_MSIP_36_RSVD_36_OFFSET })

// Machine Software Interrupt Pending
#define CLINT_MSIP_37_REG_OFFSET 0x94
#define CLINT_MSIP_37_P_37_BIT 0
#define CLINT_MSIP_37_RSVD_37_MASK 0x7fffffff
#define CLINT_MSIP_37_RSVD_37_OFFSET 1
#define CLINT_MSIP_37_RSVD_37_FIELD \
  ((bitfield_field32_t) { .mask = CLINT_MSIP_37_RSVD_37_MASK, .index = CLINT_MSIP_37_RSVD_37_OFFSET })

// Machine Software Interrupt Pending
#define CLINT_MSIP_38_REG_OFFSET 0x98
#define CLINT_MSIP_38_P_38_BIT 0
#define CLINT_MSIP_38_RSVD_38_MASK 0x7fffffff
#define CLINT_MSIP_38_RSVD_38_OFFSET 1
#define CLINT_MSIP_38_RSVD_38_FIELD \
  ((bitfield_field32_t) { .mask = CLINT_MSIP_38_RSVD_38_MASK, .index = CLINT_MSIP_38_RSVD_38_OFFSET })

// Machine Software Interrupt Pending
#define CLINT_MSIP_39_REG_OFFSET 0x9c
#define CLINT_MSIP_39_P_39_BIT 0
#define CLINT_MSIP_39_RSVD_39_MASK 0x7fffffff
#define CLINT_MSIP_39_RSVD_39_OFFSET 1
#define CLINT_MSIP_39_RSVD_39_FIELD \
  ((bitfield_field32_t) { .mask = CLINT_MSIP_39_RSVD_39_MASK, .index = CLINT_MSIP_39_RSVD_39_OFFSET })

// Machine Software Interrupt Pending
#define CLINT_MSIP_40_REG_OFFSET 0xa0
#define CLINT_MSIP_40_P_40_BIT 0
#define CLINT_MSIP_40_RSVD_40_MASK 0x7fffffff
#define CLINT_MSIP_40_RSVD_40_OFFSET 1
#define CLINT_MSIP_40_RSVD_40_FIELD \
  ((bitfield_field32_t) { .mask = CLINT_MSIP_40_RSVD_40_MASK, .index = CLINT_MSIP_40_RSVD_40_OFFSET })

// Machine Software Interrupt Pending
#define CLINT_MSIP_41_REG_OFFSET 0xa4
#define CLINT_MSIP_41_P_41_BIT 0
#define CLINT_MSIP_41_RSVD_41_MASK 0x7fffffff
#define CLINT_MSIP_41_RSVD_41_OFFSET 1
#define CLINT_MSIP_41_RSVD_41_FIELD \
  ((bitfield_field32_t) { .mask = CLINT_MSIP_41_RSVD_41_MASK, .index = CLINT_MSIP_41_RSVD_41_OFFSET })

// Machine Software Interrupt Pending
#define CLINT_MSIP_42_REG_OFFSET 0xa8
#define CLINT_MSIP_42_P_42_BIT 0
#define CLINT_MSIP_42_RSVD_42_MASK 0x7fffffff
#define CLINT_MSIP_42_RSVD_42_OFFSET 1
#define CLINT_MSIP_42_RSVD_42_FIELD \
  ((bitfield_field32_t) { .mask = CLINT_MSIP_42_RSVD_42_MASK, .index = CLINT_MSIP_42_RSVD_42_OFFSET })

// Machine Software Interrupt Pending
#define CLINT_MSIP_43_REG_OFFSET 0xac
#define CLINT_MSIP_43_P_43_BIT 0
#define CLINT_MSIP_43_RSVD_43_MASK 0x7fffffff
#define CLINT_MSIP_43_RSVD_43_OFFSET 1
#define CLINT_MSIP_43_RSVD_43_FIELD \
  ((bitfield_field32_t) { .mask = CLINT_MSIP_43_RSVD_43_MASK, .index = CLINT_MSIP_43_RSVD_43_OFFSET })

// Machine Software Interrupt Pending
#define CLINT_MSIP_44_REG_OFFSET 0xb0
#define CLINT_MSIP_44_P_44_BIT 0
#define CLINT_MSIP_44_RSVD_44_MASK 0x7fffffff
#define CLINT_MSIP_44_RSVD_44_OFFSET 1
#define CLINT_MSIP_44_RSVD_44_FIELD \
  ((bitfield_field32_t) { .mask = CLINT_MSIP_44_RSVD_44_MASK, .index = CLINT_MSIP_44_RSVD_44_OFFSET })

// Machine Software Interrupt Pending
#define CLINT_MSIP_45_REG_OFFSET 0xb4
#define CLINT_MSIP_45_P_45_BIT 0
#define CLINT_MSIP_45_RSVD_45_MASK 0x7fffffff
#define CLINT_MSIP_45_RSVD_45_OFFSET 1
#define CLINT_MSIP_45_RSVD_45_FIELD \
  ((bitfield_field32_t) { .mask = CLINT_MSIP_45_RSVD_45_MASK, .index = CLINT_MSIP_45_RSVD_45_OFFSET })

// Machine Timer Compare
#define CLINT_MTIMECMP_LOW0_REG_OFFSET 0x4000

// Machine Timer Compare
#define CLINT_MTIMECMP_HIGH0_REG_OFFSET 0x4004

// Machine Timer Compare
#define CLINT_MTIMECMP_LOW1_REG_OFFSET 0x4008

// Machine Timer Compare
#define CLINT_MTIMECMP_HIGH1_REG_OFFSET 0x400c

// Machine Timer Compare
#define CLINT_MTIMECMP_LOW2_REG_OFFSET 0x4010

// Machine Timer Compare
#define CLINT_MTIMECMP_HIGH2_REG_OFFSET 0x4014

// Machine Timer Compare
#define CLINT_MTIMECMP_LOW3_REG_OFFSET 0x4018

// Machine Timer Compare
#define CLINT_MTIMECMP_HIGH3_REG_OFFSET 0x401c

// Machine Timer Compare
#define CLINT_MTIMECMP_LOW4_REG_OFFSET 0x4020

// Machine Timer Compare
#define CLINT_MTIMECMP_HIGH4_REG_OFFSET 0x4024

// Machine Timer Compare
#define CLINT_MTIMECMP_LOW5_REG_OFFSET 0x4028

// Machine Timer Compare
#define CLINT_MTIMECMP_HIGH5_REG_OFFSET 0x402c

// Machine Timer Compare
#define CLINT_MTIMECMP_LOW6_REG_OFFSET 0x4030

// Machine Timer Compare
#define CLINT_MTIMECMP_HIGH6_REG_OFFSET 0x4034

// Machine Timer Compare
#define CLINT_MTIMECMP_LOW7_REG_OFFSET 0x4038

// Machine Timer Compare
#define CLINT_MTIMECMP_HIGH7_REG_OFFSET 0x403c

// Machine Timer Compare
#define CLINT_MTIMECMP_LOW8_REG_OFFSET 0x4040

// Machine Timer Compare
#define CLINT_MTIMECMP_HIGH8_REG_OFFSET 0x4044

// Machine Timer Compare
#define CLINT_MTIMECMP_LOW9_REG_OFFSET 0x4048

// Machine Timer Compare
#define CLINT_MTIMECMP_HIGH9_REG_OFFSET 0x404c

// Machine Timer Compare
#define CLINT_MTIMECMP_LOW10_REG_OFFSET 0x4050

// Machine Timer Compare
#define CLINT_MTIMECMP_HIGH10_REG_OFFSET 0x4054

// Machine Timer Compare
#define CLINT_MTIMECMP_LOW11_REG_OFFSET 0x4058

// Machine Timer Compare
#define CLINT_MTIMECMP_HIGH11_REG_OFFSET 0x405c

// Machine Timer Compare
#define CLINT_MTIMECMP_LOW12_REG_OFFSET 0x4060

// Machine Timer Compare
#define CLINT_MTIMECMP_HIGH12_REG_OFFSET 0x4064

// Machine Timer Compare
#define CLINT_MTIMECMP_LOW13_REG_OFFSET 0x4068

// Machine Timer Compare
#define CLINT_MTIMECMP_HIGH13_REG_OFFSET 0x406c

// Machine Timer Compare
#define CLINT_MTIMECMP_LOW14_REG_OFFSET 0x4070

// Machine Timer Compare
#define CLINT_MTIMECMP_HIGH14_REG_OFFSET 0x4074

// Machine Timer Compare
#define CLINT_MTIMECMP_LOW15_REG_OFFSET 0x4078

// Machine Timer Compare
#define CLINT_MTIMECMP_HIGH15_REG_OFFSET 0x407c

// Machine Timer Compare
#define CLINT_MTIMECMP_LOW16_REG_OFFSET 0x4080

// Machine Timer Compare
#define CLINT_MTIMECMP_HIGH16_REG_OFFSET 0x4084

// Machine Timer Compare
#define CLINT_MTIMECMP_LOW17_REG_OFFSET 0x4088

// Machine Timer Compare
#define CLINT_MTIMECMP_HIGH17_REG_OFFSET 0x408c

// Machine Timer Compare
#define CLINT_MTIMECMP_LOW18_REG_OFFSET 0x4090

// Machine Timer Compare
#define CLINT_MTIMECMP_HIGH18_REG_OFFSET 0x4094

// Machine Timer Compare
#define CLINT_MTIMECMP_LOW19_REG_OFFSET 0x4098

// Machine Timer Compare
#define CLINT_MTIMECMP_HIGH19_REG_OFFSET 0x409c

// Machine Timer Compare
#define CLINT_MTIMECMP_LOW20_REG_OFFSET 0x40a0

// Machine Timer Compare
#define CLINT_MTIMECMP_HIGH20_REG_OFFSET 0x40a4

// Machine Timer Compare
#define CLINT_MTIMECMP_LOW21_REG_OFFSET 0x40a8

// Machine Timer Compare
#define CLINT_MTIMECMP_HIGH21_REG_OFFSET 0x40ac

// Machine Timer Compare
#define CLINT_MTIMECMP_LOW22_REG_OFFSET 0x40b0

// Machine Timer Compare
#define CLINT_MTIMECMP_HIGH22_REG_OFFSET 0x40b4

// Machine Timer Compare
#define CLINT_MTIMECMP_LOW23_REG_OFFSET 0x40b8

// Machine Timer Compare
#define CLINT_MTIMECMP_HIGH23_REG_OFFSET 0x40bc

// Machine Timer Compare
#define CLINT_MTIMECMP_LOW24_REG_OFFSET 0x40c0

// Machine Timer Compare
#define CLINT_MTIMECMP_HIGH24_REG_OFFSET 0x40c4

// Machine Timer Compare
#define CLINT_MTIMECMP_LOW25_REG_OFFSET 0x40c8

// Machine Timer Compare
#define CLINT_MTIMECMP_HIGH25_REG_OFFSET 0x40cc

// Machine Timer Compare
#define CLINT_MTIMECMP_LOW26_REG_OFFSET 0x40d0

// Machine Timer Compare
#define CLINT_MTIMECMP_HIGH26_REG_OFFSET 0x40d4

// Machine Timer Compare
#define CLINT_MTIMECMP_LOW27_REG_OFFSET 0x40d8

// Machine Timer Compare
#define CLINT_MTIMECMP_HIGH27_REG_OFFSET 0x40dc

// Machine Timer Compare
#define CLINT_MTIMECMP_LOW28_REG_OFFSET 0x40e0

// Machine Timer Compare
#define CLINT_MTIMECMP_HIGH28_REG_OFFSET 0x40e4

// Machine Timer Compare
#define CLINT_MTIMECMP_LOW29_REG_OFFSET 0x40e8

// Machine Timer Compare
#define CLINT_MTIMECMP_HIGH29_REG_OFFSET 0x40ec

// Machine Timer Compare
#define CLINT_MTIMECMP_LOW30_REG_OFFSET 0x40f0

// Machine Timer Compare
#define CLINT_MTIMECMP_HIGH30_REG_OFFSET 0x40f4

// Machine Timer Compare
#define CLINT_MTIMECMP_LOW31_REG_OFFSET 0x40f8

// Machine Timer Compare
#define CLINT_MTIMECMP_HIGH31_REG_OFFSET 0x40fc

// Machine Timer Compare
#define CLINT_MTIMECMP_LOW32_REG_OFFSET 0x4100

// Machine Timer Compare
#define CLINT_MTIMECMP_HIGH32_REG_OFFSET 0x4104

// Machine Timer Compare
#define CLINT_MTIMECMP_LOW33_REG_OFFSET 0x4108

// Machine Timer Compare
#define CLINT_MTIMECMP_HIGH33_REG_OFFSET 0x410c

// Machine Timer Compare
#define CLINT_MTIMECMP_LOW34_REG_OFFSET 0x4110

// Machine Timer Compare
#define CLINT_MTIMECMP_HIGH34_REG_OFFSET 0x4114

// Machine Timer Compare
#define CLINT_MTIMECMP_LOW35_REG_OFFSET 0x4118

// Machine Timer Compare
#define CLINT_MTIMECMP_HIGH35_REG_OFFSET 0x411c

// Machine Timer Compare
#define CLINT_MTIMECMP_LOW36_REG_OFFSET 0x4120

// Machine Timer Compare
#define CLINT_MTIMECMP_HIGH36_REG_OFFSET 0x4124

// Machine Timer Compare
#define CLINT_MTIMECMP_LOW37_REG_OFFSET 0x4128

// Machine Timer Compare
#define CLINT_MTIMECMP_HIGH37_REG_OFFSET 0x412c

// Machine Timer Compare
#define CLINT_MTIMECMP_LOW38_REG_OFFSET 0x4130

// Machine Timer Compare
#define CLINT_MTIMECMP_HIGH38_REG_OFFSET 0x4134

// Machine Timer Compare
#define CLINT_MTIMECMP_LOW39_REG_OFFSET 0x4138

// Machine Timer Compare
#define CLINT_MTIMECMP_HIGH39_REG_OFFSET 0x413c

// Machine Timer Compare
#define CLINT_MTIMECMP_LOW40_REG_OFFSET 0x4140

// Machine Timer Compare
#define CLINT_MTIMECMP_HIGH40_REG_OFFSET 0x4144

// Machine Timer Compare
#define CLINT_MTIMECMP_LOW41_REG_OFFSET 0x4148

// Machine Timer Compare
#define CLINT_MTIMECMP_HIGH41_REG_OFFSET 0x414c

// Machine Timer Compare
#define CLINT_MTIMECMP_LOW42_REG_OFFSET 0x4150

// Machine Timer Compare
#define CLINT_MTIMECMP_HIGH42_REG_OFFSET 0x4154

// Machine Timer Compare
#define CLINT_MTIMECMP_LOW43_REG_OFFSET 0x4158

// Machine Timer Compare
#define CLINT_MTIMECMP_HIGH43_REG_OFFSET 0x415c

// Machine Timer Compare
#define CLINT_MTIMECMP_LOW44_REG_OFFSET 0x4160

// Machine Timer Compare
#define CLINT_MTIMECMP_HIGH44_REG_OFFSET 0x4164

// Machine Timer Compare
#define CLINT_MTIMECMP_LOW45_REG_OFFSET 0x4168

// Machine Timer Compare
#define CLINT_MTIMECMP_HIGH45_REG_OFFSET 0x416c

// Timer Register Low
#define CLINT_MTIME_LOW_REG_OFFSET 0xbff8

// Timer Register High
#define CLINT_MTIME_HIGH_REG_OFFSET 0xbffc

#ifdef __cplusplus
}  // extern "C"
#endif
#endif  // _CLINT_REG_DEFS_
// End generated register defines for CLINT