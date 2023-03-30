// Generated register defines for cheshire

// Copyright information found in source file:
// Copyright 2022 ETH Zurich and University of Bologna.

// Licensing information found in source file:
// Licensed under Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51

#ifndef _CHESHIRE_REG_DEFS_
#define _CHESHIRE_REG_DEFS_

#ifdef __cplusplus
extern "C" {
#endif
// Register width
#define CHESHIRE_PARAM_REG_WIDTH 32

// Registers for use by software (common parameters)
#define CHESHIRE_SCRATCH_SCRATCH_FIELD_WIDTH 32
#define CHESHIRE_SCRATCH_SCRATCH_FIELDS_PER_REG 1
#define CHESHIRE_SCRATCH_MULTIREG_COUNT 4

// Registers for use by software
#define CHESHIRE_SCRATCH_0_REG_OFFSET 0x0

// Registers for use by software
#define CHESHIRE_SCRATCH_1_REG_OFFSET 0x4

// Registers for use by software
#define CHESHIRE_SCRATCH_2_REG_OFFSET 0x8

// Registers for use by software
#define CHESHIRE_SCRATCH_3_REG_OFFSET 0xc

// Method to load boot code (connected to input pins)
#define CHESHIRE_BOOT_MODE_REG_OFFSET 0x10
#define CHESHIRE_BOOT_MODE_BOOT_MODE_MASK 0x3
#define CHESHIRE_BOOT_MODE_BOOT_MODE_OFFSET 0
#define CHESHIRE_BOOT_MODE_BOOT_MODE_FIELD \
  ((bitfield_field32_t) { .mask = CHESHIRE_BOOT_MODE_BOOT_MODE_MASK, .index = CHESHIRE_BOOT_MODE_BOOT_MODE_OFFSET })
#define CHESHIRE_BOOT_MODE_BOOT_MODE_VALUE_PASSIVE 0x0
#define CHESHIRE_BOOT_MODE_BOOT_MODE_VALUE_SPI_SDCARD 0x1
#define CHESHIRE_BOOT_MODE_BOOT_MODE_VALUE_SPI_S25FS512S 0x2
#define CHESHIRE_BOOT_MODE_BOOT_MODE_VALUE_I2C_24XX1025 0x3

// Frequency (Hz) configured for RTC
#define CHESHIRE_RTC_FREQ_REG_OFFSET 0x14

// Address of platform ROM
#define CHESHIRE_PLATFORM_ROM_REG_OFFSET 0x18

// Specifies which hardware features are available
#define CHESHIRE_HW_FEATURES_REG_OFFSET 0x1c
#define CHESHIRE_HW_FEATURES_BOOTROM_BIT 0
#define CHESHIRE_HW_FEATURES_LLC_BIT 1
#define CHESHIRE_HW_FEATURES_UART_BIT 2
#define CHESHIRE_HW_FEATURES_SPI_HOST_BIT 3
#define CHESHIRE_HW_FEATURES_I2C_BIT 4
#define CHESHIRE_HW_FEATURES_GPIO_BIT 5
#define CHESHIRE_HW_FEATURES_DMA_BIT 6
#define CHESHIRE_HW_FEATURES_SERIAL_LINK_BIT 7
#define CHESHIRE_HW_FEATURES_VGA_BIT 8

// Total size of LLC in bytes
#define CHESHIRE_LLC_SIZE_REG_OFFSET 0x20

// VGA hardware parameters
#define CHESHIRE_VGA_PARAMS_REG_OFFSET 0x24
#define CHESHIRE_VGA_PARAMS_RED_WIDTH_MASK 0xff
#define CHESHIRE_VGA_PARAMS_RED_WIDTH_OFFSET 0
#define CHESHIRE_VGA_PARAMS_RED_WIDTH_FIELD \
  ((bitfield_field32_t) { .mask = CHESHIRE_VGA_PARAMS_RED_WIDTH_MASK, .index = CHESHIRE_VGA_PARAMS_RED_WIDTH_OFFSET })
#define CHESHIRE_VGA_PARAMS_GREEN_WIDTH_MASK 0xff
#define CHESHIRE_VGA_PARAMS_GREEN_WIDTH_OFFSET 8
#define CHESHIRE_VGA_PARAMS_GREEN_WIDTH_FIELD \
  ((bitfield_field32_t) { .mask = CHESHIRE_VGA_PARAMS_GREEN_WIDTH_MASK, .index = CHESHIRE_VGA_PARAMS_GREEN_WIDTH_OFFSET })
#define CHESHIRE_VGA_PARAMS_BLUE_WIDTH_MASK 0xff
#define CHESHIRE_VGA_PARAMS_BLUE_WIDTH_OFFSET 16
#define CHESHIRE_VGA_PARAMS_BLUE_WIDTH_FIELD \
  ((bitfield_field32_t) { .mask = CHESHIRE_VGA_PARAMS_BLUE_WIDTH_MASK, .index = CHESHIRE_VGA_PARAMS_BLUE_WIDTH_OFFSET })

#ifdef __cplusplus
}  // extern "C"
#endif
#endif  // _CHESHIRE_REG_DEFS_
// End generated register defines for cheshire