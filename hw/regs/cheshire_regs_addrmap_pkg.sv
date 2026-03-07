// Copyright 2025 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
package cheshire_regs_addrmap_pkg;

localparam longint unsigned CHESHIRE_REGS_BASE_ADDR = 64'h0;
localparam longint unsigned CHESHIRE_REGS_SIZE = 64'h5C;

function automatic longint unsigned CHESHIRE_REGS_SCRATCH_BASE_ADDR(input int unsigned scratch_idx);
    return 64'h0 + (scratch_idx * 64'h4);
endfunction
localparam longint unsigned CHESHIRE_REGS_SCRATCH_NUM = 64'h10;
localparam longint unsigned CHESHIRE_REGS_BOOT_MODE_BASE_ADDR = 64'h40;
localparam longint unsigned CHESHIRE_REGS_RTC_FREQ_BASE_ADDR = 64'h44;
localparam longint unsigned CHESHIRE_REGS_PLATFORM_ROM_BASE_ADDR = 64'h48;
localparam longint unsigned CHESHIRE_REGS_NUM_INT_HARTS_BASE_ADDR = 64'h4C;
localparam longint unsigned CHESHIRE_REGS_HW_FEATURES_BASE_ADDR = 64'h50;
localparam longint unsigned CHESHIRE_REGS_LLC_SIZE_BASE_ADDR = 64'h54;
localparam longint unsigned CHESHIRE_REGS_VGA_PARAMS_BASE_ADDR = 64'h58;


typedef enum logic [1:0] {
    PASSIVE = 2'd0,
    SPI_SDCARD = 2'd1,
    SPI_S25FS512S = 2'd2,
    I2C_24XX1025 = 2'd3
} BootMode_e;

endpackage;
