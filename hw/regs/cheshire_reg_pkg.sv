// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Register Package auto-generated by `reggen` containing data structure

package cheshire_reg_pkg;

  // Address widths within the block
  parameter int BlockAw = 6;

  ////////////////////////////
  // Typedefs for registers //
  ////////////////////////////

  typedef struct packed {
    logic [1:0]  d;
  } cheshire_hw2reg_boot_mode_reg_t;

  typedef struct packed {
    struct packed {
      logic        d;
    } clock_lock;
    struct packed {
      logic        d;
    } uart_present;
    struct packed {
      logic        d;
    } spi_present;
    struct packed {
      logic        d;
    } i2c_present;
    struct packed {
      logic        d;
    } dma_present;
    struct packed {
      logic        d;
    } ddr_link_present;
    struct packed {
      logic        d;
    } dram_present;
    struct packed {
      logic        d;
    } vga_present;
  } cheshire_hw2reg_status_reg_t;

  typedef struct packed {
    logic [31:0] d;
  } cheshire_hw2reg_vga_red_width_reg_t;

  typedef struct packed {
    logic [31:0] d;
  } cheshire_hw2reg_vga_green_width_reg_t;

  typedef struct packed {
    logic [31:0] d;
  } cheshire_hw2reg_vga_blue_width_reg_t;

  typedef struct packed {
    logic [31:0] d;
  } cheshire_hw2reg_reset_freq_reg_t;

  // HW -> register type
  typedef struct packed {
    cheshire_hw2reg_boot_mode_reg_t boot_mode; // [137:136]
    cheshire_hw2reg_status_reg_t status; // [135:128]
    cheshire_hw2reg_vga_red_width_reg_t vga_red_width; // [127:96]
    cheshire_hw2reg_vga_green_width_reg_t vga_green_width; // [95:64]
    cheshire_hw2reg_vga_blue_width_reg_t vga_blue_width; // [63:32]
    cheshire_hw2reg_reset_freq_reg_t reset_freq; // [31:0]
  } cheshire_hw2reg_t;

  // Register offsets
  parameter logic [BlockAw-1:0] CHESHIRE_VERSION_OFFSET = 6'h 0;
  parameter logic [BlockAw-1:0] CHESHIRE_SCRATCH_0_OFFSET = 6'h 4;
  parameter logic [BlockAw-1:0] CHESHIRE_SCRATCH_1_OFFSET = 6'h 8;
  parameter logic [BlockAw-1:0] CHESHIRE_SCRATCH_2_OFFSET = 6'h c;
  parameter logic [BlockAw-1:0] CHESHIRE_SCRATCH_3_OFFSET = 6'h 10;
  parameter logic [BlockAw-1:0] CHESHIRE_BOOT_MODE_OFFSET = 6'h 14;
  parameter logic [BlockAw-1:0] CHESHIRE_STATUS_OFFSET = 6'h 18;
  parameter logic [BlockAw-1:0] CHESHIRE_VGA_RED_WIDTH_OFFSET = 6'h 1c;
  parameter logic [BlockAw-1:0] CHESHIRE_VGA_GREEN_WIDTH_OFFSET = 6'h 20;
  parameter logic [BlockAw-1:0] CHESHIRE_VGA_BLUE_WIDTH_OFFSET = 6'h 24;
  parameter logic [BlockAw-1:0] CHESHIRE_RESET_FREQ_OFFSET = 6'h 28;

  // Reset values for hwext registers and their fields
  parameter logic [1:0] CHESHIRE_BOOT_MODE_RESVAL = 2'h 0;
  parameter logic [7:0] CHESHIRE_STATUS_RESVAL = 8'h 0;
  parameter logic [31:0] CHESHIRE_VGA_RED_WIDTH_RESVAL = 32'h 0;
  parameter logic [31:0] CHESHIRE_VGA_GREEN_WIDTH_RESVAL = 32'h 0;
  parameter logic [31:0] CHESHIRE_VGA_BLUE_WIDTH_RESVAL = 32'h 0;
  parameter logic [31:0] CHESHIRE_RESET_FREQ_RESVAL = 32'h 0;

  // Register index
  typedef enum int {
    CHESHIRE_VERSION,
    CHESHIRE_SCRATCH_0,
    CHESHIRE_SCRATCH_1,
    CHESHIRE_SCRATCH_2,
    CHESHIRE_SCRATCH_3,
    CHESHIRE_BOOT_MODE,
    CHESHIRE_STATUS,
    CHESHIRE_VGA_RED_WIDTH,
    CHESHIRE_VGA_GREEN_WIDTH,
    CHESHIRE_VGA_BLUE_WIDTH,
    CHESHIRE_RESET_FREQ
  } cheshire_id_e;

  // Register width information to check illegal writes
  parameter logic [3:0] CHESHIRE_PERMIT [11] = '{
    4'b 0011, // index[ 0] CHESHIRE_VERSION
    4'b 1111, // index[ 1] CHESHIRE_SCRATCH_0
    4'b 1111, // index[ 2] CHESHIRE_SCRATCH_1
    4'b 1111, // index[ 3] CHESHIRE_SCRATCH_2
    4'b 1111, // index[ 4] CHESHIRE_SCRATCH_3
    4'b 0001, // index[ 5] CHESHIRE_BOOT_MODE
    4'b 0001, // index[ 6] CHESHIRE_STATUS
    4'b 1111, // index[ 7] CHESHIRE_VGA_RED_WIDTH
    4'b 1111, // index[ 8] CHESHIRE_VGA_GREEN_WIDTH
    4'b 1111, // index[ 9] CHESHIRE_VGA_BLUE_WIDTH
    4'b 1111  // index[10] CHESHIRE_RESET_FREQ
  };

endpackage

