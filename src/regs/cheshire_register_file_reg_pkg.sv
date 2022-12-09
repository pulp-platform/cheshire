// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Register Package auto-generated by `reggen` containing data structure

package cheshire_register_file_reg_pkg;

  // Address widths within the block
  parameter int BlockAw = 6;

  ////////////////////////////
  // Typedefs for registers //
  ////////////////////////////

  typedef struct packed {
    logic [1:0]  d;
  } cheshire_register_file_hw2reg_boot_mode_reg_t;

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
    } rpc_dram_present;
    struct packed {
      logic        d;
    } vga_present;
  } cheshire_register_file_hw2reg_status_reg_t;

  typedef struct packed {
    logic [31:0] d;
  } cheshire_register_file_hw2reg_vga_red_width_reg_t;

  typedef struct packed {
    logic [31:0] d;
  } cheshire_register_file_hw2reg_vga_green_width_reg_t;

  typedef struct packed {
    logic [31:0] d;
  } cheshire_register_file_hw2reg_vga_blue_width_reg_t;

  // HW -> register type
  typedef struct packed {
    cheshire_register_file_hw2reg_boot_mode_reg_t boot_mode; // [105:104]
    cheshire_register_file_hw2reg_status_reg_t status; // [103:96]
    cheshire_register_file_hw2reg_vga_red_width_reg_t vga_red_width; // [95:64]
    cheshire_register_file_hw2reg_vga_green_width_reg_t vga_green_width; // [63:32]
    cheshire_register_file_hw2reg_vga_blue_width_reg_t vga_blue_width; // [31:0]
  } cheshire_register_file_hw2reg_t;

  // Register offsets
  parameter logic [BlockAw-1:0] CHESHIRE_REGISTER_FILE_VERSION_OFFSET = 6'h 0;
  parameter logic [BlockAw-1:0] CHESHIRE_REGISTER_FILE_SCRATCH_0_OFFSET = 6'h 4;
  parameter logic [BlockAw-1:0] CHESHIRE_REGISTER_FILE_SCRATCH_1_OFFSET = 6'h 8;
  parameter logic [BlockAw-1:0] CHESHIRE_REGISTER_FILE_SCRATCH_2_OFFSET = 6'h c;
  parameter logic [BlockAw-1:0] CHESHIRE_REGISTER_FILE_SCRATCH_3_OFFSET = 6'h 10;
  parameter logic [BlockAw-1:0] CHESHIRE_REGISTER_FILE_BOOT_MODE_OFFSET = 6'h 14;
  parameter logic [BlockAw-1:0] CHESHIRE_REGISTER_FILE_STATUS_OFFSET = 6'h 18;
  parameter logic [BlockAw-1:0] CHESHIRE_REGISTER_FILE_VGA_RED_WIDTH_OFFSET = 6'h 1c;
  parameter logic [BlockAw-1:0] CHESHIRE_REGISTER_FILE_VGA_GREEN_WIDTH_OFFSET = 6'h 20;
  parameter logic [BlockAw-1:0] CHESHIRE_REGISTER_FILE_VGA_BLUE_WIDTH_OFFSET = 6'h 24;

  // Reset values for hwext registers and their fields
  parameter logic [1:0] CHESHIRE_REGISTER_FILE_BOOT_MODE_RESVAL = 2'h 0;
  parameter logic [7:0] CHESHIRE_REGISTER_FILE_STATUS_RESVAL = 8'h 0;
  parameter logic [31:0] CHESHIRE_REGISTER_FILE_VGA_RED_WIDTH_RESVAL = 32'h 0;
  parameter logic [31:0] CHESHIRE_REGISTER_FILE_VGA_GREEN_WIDTH_RESVAL = 32'h 0;
  parameter logic [31:0] CHESHIRE_REGISTER_FILE_VGA_BLUE_WIDTH_RESVAL = 32'h 0;

  // Register index
  typedef enum int {
    CHESHIRE_REGISTER_FILE_VERSION,
    CHESHIRE_REGISTER_FILE_SCRATCH_0,
    CHESHIRE_REGISTER_FILE_SCRATCH_1,
    CHESHIRE_REGISTER_FILE_SCRATCH_2,
    CHESHIRE_REGISTER_FILE_SCRATCH_3,
    CHESHIRE_REGISTER_FILE_BOOT_MODE,
    CHESHIRE_REGISTER_FILE_STATUS,
    CHESHIRE_REGISTER_FILE_VGA_RED_WIDTH,
    CHESHIRE_REGISTER_FILE_VGA_GREEN_WIDTH,
    CHESHIRE_REGISTER_FILE_VGA_BLUE_WIDTH
  } cheshire_register_file_id_e;

  // Register width information to check illegal writes
  parameter logic [3:0] CHESHIRE_REGISTER_FILE_PERMIT [10] = '{
    4'b 0011, // index[0] CHESHIRE_REGISTER_FILE_VERSION
    4'b 1111, // index[1] CHESHIRE_REGISTER_FILE_SCRATCH_0
    4'b 1111, // index[2] CHESHIRE_REGISTER_FILE_SCRATCH_1
    4'b 1111, // index[3] CHESHIRE_REGISTER_FILE_SCRATCH_2
    4'b 1111, // index[4] CHESHIRE_REGISTER_FILE_SCRATCH_3
    4'b 0001, // index[5] CHESHIRE_REGISTER_FILE_BOOT_MODE
    4'b 0001, // index[6] CHESHIRE_REGISTER_FILE_STATUS
    4'b 1111, // index[7] CHESHIRE_REGISTER_FILE_VGA_RED_WIDTH
    4'b 1111, // index[8] CHESHIRE_REGISTER_FILE_VGA_GREEN_WIDTH
    4'b 1111  // index[9] CHESHIRE_REGISTER_FILE_VGA_BLUE_WIDTH
  };

endpackage

