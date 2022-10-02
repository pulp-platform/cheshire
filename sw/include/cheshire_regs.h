// Generated register defines for cheshire_register_file

// Copyright information found in source file:
// Copyright 2022 ETH Zurich and University of Bologna.

// Licensing information found in source file:
// Licensed under Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51

#ifndef _CHESHIRE_REGISTER_FILE_REG_DEFS_
#define _CHESHIRE_REGISTER_FILE_REG_DEFS_

#ifdef __cplusplus
extern "C" {
#endif
// Register width
#define CHESHIRE_REGISTER_FILE_PARAM_REG_WIDTH 32

// Version register, should read 2.
#define CHESHIRE_REGISTER_FILE_VERSION_REG_OFFSET 0x0
#define CHESHIRE_REGISTER_FILE_VERSION_VERSION_MASK 0xffff
#define CHESHIRE_REGISTER_FILE_VERSION_VERSION_OFFSET 0
#define CHESHIRE_REGISTER_FILE_VERSION_VERSION_FIELD \
  ((bitfield_field32_t) { .mask = CHESHIRE_REGISTER_FILE_VERSION_VERSION_MASK, .index = CHESHIRE_REGISTER_FILE_VERSION_VERSION_OFFSET })

// Scratch register for SW to write to. (common parameters)
#define CHESHIRE_REGISTER_FILE_SCRATCH_SCRATCH_FIELD_WIDTH 32
#define CHESHIRE_REGISTER_FILE_SCRATCH_SCRATCH_FIELDS_PER_REG 1
#define CHESHIRE_REGISTER_FILE_SCRATCH_MULTIREG_COUNT 4

// Scratch register for SW to write to.
#define CHESHIRE_REGISTER_FILE_SCRATCH_0_REG_OFFSET 0x4

// Scratch register for SW to write to.
#define CHESHIRE_REGISTER_FILE_SCRATCH_1_REG_OFFSET 0x8

// Scratch register for SW to write to.
#define CHESHIRE_REGISTER_FILE_SCRATCH_2_REG_OFFSET 0xc

// Scratch register for SW to write to.
#define CHESHIRE_REGISTER_FILE_SCRATCH_3_REG_OFFSET 0x10

// Selected boot mode exposed as a register.
#define CHESHIRE_REGISTER_FILE_BOOT_MODE_REG_OFFSET 0x14
#define CHESHIRE_REGISTER_FILE_BOOT_MODE_MODE_MASK 0x3
#define CHESHIRE_REGISTER_FILE_BOOT_MODE_MODE_OFFSET 0
#define CHESHIRE_REGISTER_FILE_BOOT_MODE_MODE_FIELD \
  ((bitfield_field32_t) { .mask = CHESHIRE_REGISTER_FILE_BOOT_MODE_MODE_MASK, .index = CHESHIRE_REGISTER_FILE_BOOT_MODE_MODE_OFFSET })
#define CHESHIRE_REGISTER_FILE_BOOT_MODE_MODE_VALUE_SD_BOOT 0x0
#define CHESHIRE_REGISTER_FILE_BOOT_MODE_MODE_VALUE_RESERVED_1 0x1
#define CHESHIRE_REGISTER_FILE_BOOT_MODE_MODE_VALUE_RESERVED_2 0x2
#define CHESHIRE_REGISTER_FILE_BOOT_MODE_MODE_VALUE_RESERVED_3 0x3

// Clock frequency lock exposed as a register.
#define CHESHIRE_REGISTER_FILE_STATUS_REG_OFFSET 0x18
#define CHESHIRE_REGISTER_FILE_STATUS_CLOCK_LOCK_BIT 0
#define CHESHIRE_REGISTER_FILE_STATUS_UART_PRESENT_BIT 1
#define CHESHIRE_REGISTER_FILE_STATUS_SPI_PRESENT_BIT 2
#define CHESHIRE_REGISTER_FILE_STATUS_I2C_PRESENT_BIT 3
#define CHESHIRE_REGISTER_FILE_STATUS_DMA_PRESENT_BIT 4
#define CHESHIRE_REGISTER_FILE_STATUS_DDR_LINK_PRESENT_BIT 5
#define CHESHIRE_REGISTER_FILE_STATUS_DRAM_PRESENT_BIT 6
#define CHESHIRE_REGISTER_FILE_STATUS_VGA_PRESENT_BIT 7

// Selected VGA red width exposed as a register.
#define CHESHIRE_REGISTER_FILE_VGA_RED_WIDTH_REG_OFFSET 0x1c

// Selected VGA green width exposed as a register.
#define CHESHIRE_REGISTER_FILE_VGA_GREEN_WIDTH_REG_OFFSET 0x20

// Selected VGA blue width exposed as a register.
#define CHESHIRE_REGISTER_FILE_VGA_BLUE_WIDTH_REG_OFFSET 0x24

// Clock frequency after coming out of reset.
#define CHESHIRE_REGISTER_FILE_RESET_FREQ_REG_OFFSET 0x28

#ifdef __cplusplus
}  // extern "C"
#endif
#endif  // _CHESHIRE_REGISTER_FILE_REG_DEFS_
// End generated register defines for cheshire_register_file