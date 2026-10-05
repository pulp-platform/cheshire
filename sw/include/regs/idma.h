// Generated register defines for idma_reg64_2d

// Copyright information found in source file:
// Copyright 2023 ETH Zurich and University of Bologna.

// Licensing information found in source file:
// 
// SPDX-License-Identifier: SHL-0.51

#ifndef _IDMA_REG64_2D_REG_DEFS_
#define _IDMA_REG64_2D_REG_DEFS_

#ifdef __cplusplus
extern "C" {
#endif
// Number of dimensions available
#define IDMA_REG64_2D_PARAM_NUM_DIMS 2

// Register width
#define IDMA_REG64_2D_PARAM_REG_WIDTH 32

// Configuration Register for DMA settings
#define IDMA_REG64_2D_CONF_REG_OFFSET 0x0
#define IDMA_REG64_2D_CONF_DECOUPLE_AW_BIT 0
#define IDMA_REG64_2D_CONF_DECOUPLE_RW_BIT 1
#define IDMA_REG64_2D_CONF_SRC_REDUCE_LEN_BIT 2
#define IDMA_REG64_2D_CONF_DST_REDUCE_LEN_BIT 3
#define IDMA_REG64_2D_CONF_SRC_MAX_LLEN_MASK 0x7
#define IDMA_REG64_2D_CONF_SRC_MAX_LLEN_OFFSET 4
#define IDMA_REG64_2D_CONF_SRC_MAX_LLEN_FIELD \
  ((bitfield_field32_t) { .mask = IDMA_REG64_2D_CONF_SRC_MAX_LLEN_MASK, .index = IDMA_REG64_2D_CONF_SRC_MAX_LLEN_OFFSET })
#define IDMA_REG64_2D_CONF_DST_MAX_LLEN_MASK 0x7
#define IDMA_REG64_2D_CONF_DST_MAX_LLEN_OFFSET 7
#define IDMA_REG64_2D_CONF_DST_MAX_LLEN_FIELD \
  ((bitfield_field32_t) { .mask = IDMA_REG64_2D_CONF_DST_MAX_LLEN_MASK, .index = IDMA_REG64_2D_CONF_DST_MAX_LLEN_OFFSET })
#define IDMA_REG64_2D_CONF_ENABLE_ND_BIT 10
#define IDMA_REG64_2D_CONF_SRC_PROTOCOL_MASK 0x7
#define IDMA_REG64_2D_CONF_SRC_PROTOCOL_OFFSET 11
#define IDMA_REG64_2D_CONF_SRC_PROTOCOL_FIELD \
  ((bitfield_field32_t) { .mask = IDMA_REG64_2D_CONF_SRC_PROTOCOL_MASK, .index = IDMA_REG64_2D_CONF_SRC_PROTOCOL_OFFSET })
#define IDMA_REG64_2D_CONF_DST_PROTOCOL_MASK 0x7
#define IDMA_REG64_2D_CONF_DST_PROTOCOL_OFFSET 14
#define IDMA_REG64_2D_CONF_DST_PROTOCOL_FIELD \
  ((bitfield_field32_t) { .mask = IDMA_REG64_2D_CONF_DST_PROTOCOL_MASK, .index = IDMA_REG64_2D_CONF_DST_PROTOCOL_OFFSET })

// DMA Status (common parameters)
#define IDMA_REG64_2D_STATUS_BUSY_FIELD_WIDTH 10
#define IDMA_REG64_2D_STATUS_BUSY_FIELDS_PER_REG 3
#define IDMA_REG64_2D_STATUS_MULTIREG_COUNT 16

// DMA Status
#define IDMA_REG64_2D_STATUS_0_REG_OFFSET 0x4
#define IDMA_REG64_2D_STATUS_0_BUSY_0_MASK 0x3ff
#define IDMA_REG64_2D_STATUS_0_BUSY_0_OFFSET 0
#define IDMA_REG64_2D_STATUS_0_BUSY_0_FIELD \
  ((bitfield_field32_t) { .mask = IDMA_REG64_2D_STATUS_0_BUSY_0_MASK, .index = IDMA_REG64_2D_STATUS_0_BUSY_0_OFFSET })

// DMA Status
#define IDMA_REG64_2D_STATUS_1_REG_OFFSET 0x8
#define IDMA_REG64_2D_STATUS_1_BUSY_1_MASK 0x3ff
#define IDMA_REG64_2D_STATUS_1_BUSY_1_OFFSET 0
#define IDMA_REG64_2D_STATUS_1_BUSY_1_FIELD \
  ((bitfield_field32_t) { .mask = IDMA_REG64_2D_STATUS_1_BUSY_1_MASK, .index = IDMA_REG64_2D_STATUS_1_BUSY_1_OFFSET })

// DMA Status
#define IDMA_REG64_2D_STATUS_2_REG_OFFSET 0xc
#define IDMA_REG64_2D_STATUS_2_BUSY_2_MASK 0x3ff
#define IDMA_REG64_2D_STATUS_2_BUSY_2_OFFSET 0
#define IDMA_REG64_2D_STATUS_2_BUSY_2_FIELD \
  ((bitfield_field32_t) { .mask = IDMA_REG64_2D_STATUS_2_BUSY_2_MASK, .index = IDMA_REG64_2D_STATUS_2_BUSY_2_OFFSET })

// DMA Status
#define IDMA_REG64_2D_STATUS_3_REG_OFFSET 0x10
#define IDMA_REG64_2D_STATUS_3_BUSY_3_MASK 0x3ff
#define IDMA_REG64_2D_STATUS_3_BUSY_3_OFFSET 0
#define IDMA_REG64_2D_STATUS_3_BUSY_3_FIELD \
  ((bitfield_field32_t) { .mask = IDMA_REG64_2D_STATUS_3_BUSY_3_MASK, .index = IDMA_REG64_2D_STATUS_3_BUSY_3_OFFSET })

// DMA Status
#define IDMA_REG64_2D_STATUS_4_REG_OFFSET 0x14
#define IDMA_REG64_2D_STATUS_4_BUSY_4_MASK 0x3ff
#define IDMA_REG64_2D_STATUS_4_BUSY_4_OFFSET 0
#define IDMA_REG64_2D_STATUS_4_BUSY_4_FIELD \
  ((bitfield_field32_t) { .mask = IDMA_REG64_2D_STATUS_4_BUSY_4_MASK, .index = IDMA_REG64_2D_STATUS_4_BUSY_4_OFFSET })

// DMA Status
#define IDMA_REG64_2D_STATUS_5_REG_OFFSET 0x18
#define IDMA_REG64_2D_STATUS_5_BUSY_5_MASK 0x3ff
#define IDMA_REG64_2D_STATUS_5_BUSY_5_OFFSET 0
#define IDMA_REG64_2D_STATUS_5_BUSY_5_FIELD \
  ((bitfield_field32_t) { .mask = IDMA_REG64_2D_STATUS_5_BUSY_5_MASK, .index = IDMA_REG64_2D_STATUS_5_BUSY_5_OFFSET })

// DMA Status
#define IDMA_REG64_2D_STATUS_6_REG_OFFSET 0x1c
#define IDMA_REG64_2D_STATUS_6_BUSY_6_MASK 0x3ff
#define IDMA_REG64_2D_STATUS_6_BUSY_6_OFFSET 0
#define IDMA_REG64_2D_STATUS_6_BUSY_6_FIELD \
  ((bitfield_field32_t) { .mask = IDMA_REG64_2D_STATUS_6_BUSY_6_MASK, .index = IDMA_REG64_2D_STATUS_6_BUSY_6_OFFSET })

// DMA Status
#define IDMA_REG64_2D_STATUS_7_REG_OFFSET 0x20
#define IDMA_REG64_2D_STATUS_7_BUSY_7_MASK 0x3ff
#define IDMA_REG64_2D_STATUS_7_BUSY_7_OFFSET 0
#define IDMA_REG64_2D_STATUS_7_BUSY_7_FIELD \
  ((bitfield_field32_t) { .mask = IDMA_REG64_2D_STATUS_7_BUSY_7_MASK, .index = IDMA_REG64_2D_STATUS_7_BUSY_7_OFFSET })

// DMA Status
#define IDMA_REG64_2D_STATUS_8_REG_OFFSET 0x24
#define IDMA_REG64_2D_STATUS_8_BUSY_8_MASK 0x3ff
#define IDMA_REG64_2D_STATUS_8_BUSY_8_OFFSET 0
#define IDMA_REG64_2D_STATUS_8_BUSY_8_FIELD \
  ((bitfield_field32_t) { .mask = IDMA_REG64_2D_STATUS_8_BUSY_8_MASK, .index = IDMA_REG64_2D_STATUS_8_BUSY_8_OFFSET })

// DMA Status
#define IDMA_REG64_2D_STATUS_9_REG_OFFSET 0x28
#define IDMA_REG64_2D_STATUS_9_BUSY_9_MASK 0x3ff
#define IDMA_REG64_2D_STATUS_9_BUSY_9_OFFSET 0
#define IDMA_REG64_2D_STATUS_9_BUSY_9_FIELD \
  ((bitfield_field32_t) { .mask = IDMA_REG64_2D_STATUS_9_BUSY_9_MASK, .index = IDMA_REG64_2D_STATUS_9_BUSY_9_OFFSET })

// DMA Status
#define IDMA_REG64_2D_STATUS_10_REG_OFFSET 0x2c
#define IDMA_REG64_2D_STATUS_10_BUSY_10_MASK 0x3ff
#define IDMA_REG64_2D_STATUS_10_BUSY_10_OFFSET 0
#define IDMA_REG64_2D_STATUS_10_BUSY_10_FIELD \
  ((bitfield_field32_t) { .mask = IDMA_REG64_2D_STATUS_10_BUSY_10_MASK, .index = IDMA_REG64_2D_STATUS_10_BUSY_10_OFFSET })

// DMA Status
#define IDMA_REG64_2D_STATUS_11_REG_OFFSET 0x30
#define IDMA_REG64_2D_STATUS_11_BUSY_11_MASK 0x3ff
#define IDMA_REG64_2D_STATUS_11_BUSY_11_OFFSET 0
#define IDMA_REG64_2D_STATUS_11_BUSY_11_FIELD \
  ((bitfield_field32_t) { .mask = IDMA_REG64_2D_STATUS_11_BUSY_11_MASK, .index = IDMA_REG64_2D_STATUS_11_BUSY_11_OFFSET })

// DMA Status
#define IDMA_REG64_2D_STATUS_12_REG_OFFSET 0x34
#define IDMA_REG64_2D_STATUS_12_BUSY_12_MASK 0x3ff
#define IDMA_REG64_2D_STATUS_12_BUSY_12_OFFSET 0
#define IDMA_REG64_2D_STATUS_12_BUSY_12_FIELD \
  ((bitfield_field32_t) { .mask = IDMA_REG64_2D_STATUS_12_BUSY_12_MASK, .index = IDMA_REG64_2D_STATUS_12_BUSY_12_OFFSET })

// DMA Status
#define IDMA_REG64_2D_STATUS_13_REG_OFFSET 0x38
#define IDMA_REG64_2D_STATUS_13_BUSY_13_MASK 0x3ff
#define IDMA_REG64_2D_STATUS_13_BUSY_13_OFFSET 0
#define IDMA_REG64_2D_STATUS_13_BUSY_13_FIELD \
  ((bitfield_field32_t) { .mask = IDMA_REG64_2D_STATUS_13_BUSY_13_MASK, .index = IDMA_REG64_2D_STATUS_13_BUSY_13_OFFSET })

// DMA Status
#define IDMA_REG64_2D_STATUS_14_REG_OFFSET 0x3c
#define IDMA_REG64_2D_STATUS_14_BUSY_14_MASK 0x3ff
#define IDMA_REG64_2D_STATUS_14_BUSY_14_OFFSET 0
#define IDMA_REG64_2D_STATUS_14_BUSY_14_FIELD \
  ((bitfield_field32_t) { .mask = IDMA_REG64_2D_STATUS_14_BUSY_14_MASK, .index = IDMA_REG64_2D_STATUS_14_BUSY_14_OFFSET })

// DMA Status
#define IDMA_REG64_2D_STATUS_15_REG_OFFSET 0x40
#define IDMA_REG64_2D_STATUS_15_BUSY_15_MASK 0x3ff
#define IDMA_REG64_2D_STATUS_15_BUSY_15_OFFSET 0
#define IDMA_REG64_2D_STATUS_15_BUSY_15_FIELD \
  ((bitfield_field32_t) { .mask = IDMA_REG64_2D_STATUS_15_BUSY_15_MASK, .index = IDMA_REG64_2D_STATUS_15_BUSY_15_OFFSET })

// Next ID, launches transfer, returns 0 if transfer not set up properly.
// (common parameters)
#define IDMA_REG64_2D_NEXT_ID_NEXT_ID_FIELD_WIDTH 32
#define IDMA_REG64_2D_NEXT_ID_NEXT_ID_FIELDS_PER_REG 1
#define IDMA_REG64_2D_NEXT_ID_MULTIREG_COUNT 16

// Next ID, launches transfer, returns 0 if transfer not set up properly.
#define IDMA_REG64_2D_NEXT_ID_0_REG_OFFSET 0x44

// Next ID, launches transfer, returns 0 if transfer not set up properly.
#define IDMA_REG64_2D_NEXT_ID_1_REG_OFFSET 0x48

// Next ID, launches transfer, returns 0 if transfer not set up properly.
#define IDMA_REG64_2D_NEXT_ID_2_REG_OFFSET 0x4c

// Next ID, launches transfer, returns 0 if transfer not set up properly.
#define IDMA_REG64_2D_NEXT_ID_3_REG_OFFSET 0x50

// Next ID, launches transfer, returns 0 if transfer not set up properly.
#define IDMA_REG64_2D_NEXT_ID_4_REG_OFFSET 0x54

// Next ID, launches transfer, returns 0 if transfer not set up properly.
#define IDMA_REG64_2D_NEXT_ID_5_REG_OFFSET 0x58

// Next ID, launches transfer, returns 0 if transfer not set up properly.
#define IDMA_REG64_2D_NEXT_ID_6_REG_OFFSET 0x5c

// Next ID, launches transfer, returns 0 if transfer not set up properly.
#define IDMA_REG64_2D_NEXT_ID_7_REG_OFFSET 0x60

// Next ID, launches transfer, returns 0 if transfer not set up properly.
#define IDMA_REG64_2D_NEXT_ID_8_REG_OFFSET 0x64

// Next ID, launches transfer, returns 0 if transfer not set up properly.
#define IDMA_REG64_2D_NEXT_ID_9_REG_OFFSET 0x68

// Next ID, launches transfer, returns 0 if transfer not set up properly.
#define IDMA_REG64_2D_NEXT_ID_10_REG_OFFSET 0x6c

// Next ID, launches transfer, returns 0 if transfer not set up properly.
#define IDMA_REG64_2D_NEXT_ID_11_REG_OFFSET 0x70

// Next ID, launches transfer, returns 0 if transfer not set up properly.
#define IDMA_REG64_2D_NEXT_ID_12_REG_OFFSET 0x74

// Next ID, launches transfer, returns 0 if transfer not set up properly.
#define IDMA_REG64_2D_NEXT_ID_13_REG_OFFSET 0x78

// Next ID, launches transfer, returns 0 if transfer not set up properly.
#define IDMA_REG64_2D_NEXT_ID_14_REG_OFFSET 0x7c

// Next ID, launches transfer, returns 0 if transfer not set up properly.
#define IDMA_REG64_2D_NEXT_ID_15_REG_OFFSET 0x80

// Get ID of finished transactions. (common parameters)
#define IDMA_REG64_2D_DONE_ID_DONE_ID_FIELD_WIDTH 32
#define IDMA_REG64_2D_DONE_ID_DONE_ID_FIELDS_PER_REG 1
#define IDMA_REG64_2D_DONE_ID_MULTIREG_COUNT 16

// Get ID of finished transactions.
#define IDMA_REG64_2D_DONE_ID_0_REG_OFFSET 0x84

// Get ID of finished transactions.
#define IDMA_REG64_2D_DONE_ID_1_REG_OFFSET 0x88

// Get ID of finished transactions.
#define IDMA_REG64_2D_DONE_ID_2_REG_OFFSET 0x8c

// Get ID of finished transactions.
#define IDMA_REG64_2D_DONE_ID_3_REG_OFFSET 0x90

// Get ID of finished transactions.
#define IDMA_REG64_2D_DONE_ID_4_REG_OFFSET 0x94

// Get ID of finished transactions.
#define IDMA_REG64_2D_DONE_ID_5_REG_OFFSET 0x98

// Get ID of finished transactions.
#define IDMA_REG64_2D_DONE_ID_6_REG_OFFSET 0x9c

// Get ID of finished transactions.
#define IDMA_REG64_2D_DONE_ID_7_REG_OFFSET 0xa0

// Get ID of finished transactions.
#define IDMA_REG64_2D_DONE_ID_8_REG_OFFSET 0xa4

// Get ID of finished transactions.
#define IDMA_REG64_2D_DONE_ID_9_REG_OFFSET 0xa8

// Get ID of finished transactions.
#define IDMA_REG64_2D_DONE_ID_10_REG_OFFSET 0xac

// Get ID of finished transactions.
#define IDMA_REG64_2D_DONE_ID_11_REG_OFFSET 0xb0

// Get ID of finished transactions.
#define IDMA_REG64_2D_DONE_ID_12_REG_OFFSET 0xb4

// Get ID of finished transactions.
#define IDMA_REG64_2D_DONE_ID_13_REG_OFFSET 0xb8

// Get ID of finished transactions.
#define IDMA_REG64_2D_DONE_ID_14_REG_OFFSET 0xbc

// Get ID of finished transactions.
#define IDMA_REG64_2D_DONE_ID_15_REG_OFFSET 0xc0

// Low destination address
#define IDMA_REG64_2D_DST_ADDR_LOW_REG_OFFSET 0xd0

// High destination address
#define IDMA_REG64_2D_DST_ADDR_HIGH_REG_OFFSET 0xd4

// Low source address
#define IDMA_REG64_2D_SRC_ADDR_LOW_REG_OFFSET 0xd8

// High source address
#define IDMA_REG64_2D_SRC_ADDR_HIGH_REG_OFFSET 0xdc

// Low transfer length in byte
#define IDMA_REG64_2D_LENGTH_LOW_REG_OFFSET 0xe0

// High transfer length in byte
#define IDMA_REG64_2D_LENGTH_HIGH_REG_OFFSET 0xe4

// Low destination stride dimension 2
#define IDMA_REG64_2D_DST_STRIDE_2_LOW_REG_OFFSET 0xe8

// High destination stride dimension 2
#define IDMA_REG64_2D_DST_STRIDE_2_HIGH_REG_OFFSET 0xec

// Low source stride dimension 2
#define IDMA_REG64_2D_SRC_STRIDE_2_LOW_REG_OFFSET 0xf0

// High source stride dimension 2
#define IDMA_REG64_2D_SRC_STRIDE_2_HIGH_REG_OFFSET 0xf4

// Low number of repetitions dimension 2
#define IDMA_REG64_2D_REPS_2_LOW_REG_OFFSET 0xf8

// High number of repetitions dimension 2
#define IDMA_REG64_2D_REPS_2_HIGH_REG_OFFSET 0xfc

#ifdef __cplusplus
}  // extern "C"
#endif
#endif  // _IDMA_REG64_2D_REG_DEFS_
// End generated register defines for idma_reg64_2d