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
#define CLINT_PARAM_NUM_CORES 28

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

// Timer Register Low
#define CLINT_MTIME_LOW_REG_OFFSET 0xbff8

// Timer Register High
#define CLINT_MTIME_HIGH_REG_OFFSET 0xbffc

#ifdef __cplusplus
}  // extern "C"
#endif
#endif  // _CLINT_REG_DEFS_
// End generated register defines for CLINT