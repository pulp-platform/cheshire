// Generated register defines for axi_vga

// Copyright information found in source file:
// Copyright 2022 ETH Zurich and University of Bologna.

// Licensing information found in source file:
// 
// SPDX-License-Identifier: SHL-0.51

#ifndef _AXI_VGA_REG_DEFS_
#define _AXI_VGA_REG_DEFS_

#ifdef __cplusplus
extern "C" {
#endif
// Register width
#define AXI_VGA_PARAM_REG_WIDTH 32

// Control register
#define AXI_VGA_CONTROL_REG_OFFSET 0x0
#define AXI_VGA_CONTROL_ENABLE_BIT 0
#define AXI_VGA_CONTROL_HSYNC_POL_BIT 1
#define AXI_VGA_CONTROL_VSYNC_POL_BIT 2

// Clock divider
#define AXI_VGA_CLK_DIV_REG_OFFSET 0x4
#define AXI_VGA_CLK_DIV_CLK_DIV_MASK 0xff
#define AXI_VGA_CLK_DIV_CLK_DIV_OFFSET 0
#define AXI_VGA_CLK_DIV_CLK_DIV_FIELD \
  ((bitfield_field32_t) { .mask = AXI_VGA_CLK_DIV_CLK_DIV_MASK, .index = AXI_VGA_CLK_DIV_CLK_DIV_OFFSET })

// Size of horizontal visible area
#define AXI_VGA_HORI_VISIBLE_SIZE_REG_OFFSET 0x8

// Size of horizontal front porch
#define AXI_VGA_HORI_FRONT_PORCH_SIZE_REG_OFFSET 0xc

// Size of horizontal sync area
#define AXI_VGA_HORI_SYNC_SIZE_REG_OFFSET 0x10

// Size of horizontal back porch
#define AXI_VGA_HORI_BACK_PORCH_SIZE_REG_OFFSET 0x14

// Size of vertical visible area
#define AXI_VGA_VERT_VISIBLE_SIZE_REG_OFFSET 0x18

// Size of vertical front porch
#define AXI_VGA_VERT_FRONT_PORCH_SIZE_REG_OFFSET 0x1c

// Size of vertical sync area
#define AXI_VGA_VERT_SYNC_SIZE_REG_OFFSET 0x20

// Size of vertical back porch
#define AXI_VGA_VERT_BACK_PORCH_SIZE_REG_OFFSET 0x24

// Low end of start address of frame buffer
#define AXI_VGA_START_ADDR_LOW_REG_OFFSET 0x28

// High end of start address of frame buffer
#define AXI_VGA_START_ADDR_HIGH_REG_OFFSET 0x2c

// Size of whole frame
#define AXI_VGA_FRAME_SIZE_REG_OFFSET 0x30

// Number of beats in a burst
#define AXI_VGA_BURST_LEN_REG_OFFSET 0x34
#define AXI_VGA_BURST_LEN_BURST_LEN_MASK 0xff
#define AXI_VGA_BURST_LEN_BURST_LEN_OFFSET 0
#define AXI_VGA_BURST_LEN_BURST_LEN_FIELD \
  ((bitfield_field32_t) { .mask = AXI_VGA_BURST_LEN_BURST_LEN_MASK, .index = AXI_VGA_BURST_LEN_BURST_LEN_OFFSET })

#ifdef __cplusplus
}  // extern "C"
#endif
#endif  // _AXI_VGA_REG_DEFS_
// End generated register defines for axi_vga