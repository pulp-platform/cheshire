// Copyright 2022 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51

package cheshire_top_pkg;

  `include "cheshire/typedef.svh"

  import cheshire_pkg::*;

  localparam cheshire_cfg_t Cfg = DefaultCfg;
  `CHESHIRE_TYPEDEF_ALL(, Cfg)

endpackage

// https://iis-git.ee.ethz.ch/bslk/iguana/iguana-mirror/-/blob/toddler_iguana/hw/iguana.sv#L110
module cheshire_top import cheshire_top_pkg::*; import cheshire_pkg::*;
  (
    input   logic               clk_i,
    input   logic               rst_ni,

    input   logic               test_mode_i,

    // Boot mode selection
    input   logic [1:0]         boot_mode_i,

    // Serial Link
    input   logic [SlinkNumChan-1:0]         slink_i,
    output  logic [SlinkNumChan-1:0]         slink_o,
    input   logic [SlinkNumChan-1:0][SlinkNumLanes-1:0]              slink_rcv_clk_i,
    output  logic [SlinkNumChan-1:0][SlinkNumLanes-1:0]              slink_trx_clk_o,

    // VGA Controller
    output  logic                                 vga_hsync_o,
    output  logic                                 vga_vsync_o,
    output  logic [Cfg.VgaRedWidth-1:0]   vga_red_o,
    output  logic [Cfg.VgaGreenWidth-1:0] vga_green_o,
    output  logic [Cfg.VgaBlueWidth-1:0]  vga_blue_o,

    // JTAG Interface
    input   logic               jtag_tck_i,
    input   logic               jtag_trst_ni,
    input   logic               jtag_tms_i,
    input   logic               jtag_tdi_i,
    output  logic               jtag_tdo_o,

    // UART Interface
    output logic                uart_tx_o,
    input  logic                uart_rx_i,

    // I2C Interface
    output logic                i2c_sda_o,
    input  logic                i2c_sda_i,
    output logic                i2c_sda_en_no,
    output logic                i2c_scl_o,
    input  logic                i2c_scl_i,
    output logic                i2c_scl_en_no,

    // SPI Host Interface
    output logic                spih_sck_o,
    output logic                spih_sck_en_no,
    output logic [ SpihNumCs-1:0]         spih_csb_o,
    output logic [ SpihNumCs-1:0]         spih_csb_en_no,
    output logic [ 3:0]         spih_sd_o,
    output logic [ 3:0]         spih_sd_en_no,
    input  logic [ 3:0]         spih_sd_i,

    // CLINT
    input  logic                rtc_i,

    // hyperbus clocks
    input  logic                hyp_clk_phy_i,
    input  logic                hyp_rst_phy_ni,

    // GPIO interface
    input  logic [31:0]         gpio_i,
    output logic [31:0]         gpio_o,
    output logic [31:0]         gpio_en_o
  );

  cheshire_soc #(
    .Cfg               ( Cfg    ),
    .ExtHartinfo       ( '0             ),
    .axi_ext_llc_req_t ( axi_llc_req_t  ),
    .axi_ext_llc_rsp_t ( axi_llc_rsp_t ),
    .reg_ext_req_t     ( reg_req_t   ),
    .reg_ext_rsp_t     ( reg_rsp_t   )

  ) i_cheshire_soc (
    .clk_i,
    .rst_ni,
    .test_mode_i,
    .boot_mode_i,
    .rtc_i,
    // DRAM
    .axi_llc_mst_req_o ( dram_req  ),
    .axi_llc_mst_rsp_i ( dram_resp ),
    // AXI Crossbar ports
    .axi_ext_mst_req_i ( '0 ),
    .axi_ext_mst_rsp_o (    ),
    .axi_ext_slv_req_o (    ),
    .axi_ext_slv_rsp_i ( '0 ),
    // REG slaves
    .reg_ext_slv_req_o ( external_reg_req ),
    .reg_ext_slv_rsp_i ( external_reg_rsp ),
    // Interrupts
    .intr_ext_i ( '0 ),
    .meip_ext_o (    ),
    .seip_ext_o (    ),
    .mtip_ext_o (    ),
    .msip_ext_o (    ),
    // Debug Interface to external harts
    .dbg_active_o      (    ),
    .dbg_ext_req_o     (    ),
    .dbg_ext_unavail_i ( '0 ),
    // JTAG
    .jtag_tck_i,
    .jtag_trst_ni,
    .jtag_tms_i,
    .jtag_tdi_i,
    .jtag_tdo_o,
    .jtag_tdo_oe_o (),
    // UART
    .uart_tx_o,
    .uart_rx_i,
    .uart_rts_no (      ),
    .uart_dtr_no (      ),
    .uart_cts_ni ( 1'b1 ),
    .uart_dsr_ni ( 1'b1 ),
    .uart_dcd_ni ( 1'b1 ),
    .uart_rin_ni ( 1'b1 ),
    // I2C
    .i2c_sda_o,
    .i2c_sda_i,
    .i2c_sda_en_o ( i2c_sda_en ),
    .i2c_scl_o,
    .i2c_scl_i,
    .i2c_scl_en_o ( i2c_scl_en ),
    // SPI Host
    .spih_sck_o,
    .spih_sck_en_o ( spih_sck_en ),
    .spih_csb_o,
    .spih_csb_en_o ( spih_csb_en ),
    .spih_sd_o,
    .spih_sd_en_o  ( spih_sd_en  ),
    .spih_sd_i,
    // GPIO
    .gpio_i,
    .gpio_o,
    .gpio_en_o,
    // Serial Link Interface
    .slink_rcv_clk_i,
    .slink_rcv_clk_o ( slink_trx_clk_o ),
    .slink_i,
    .slink_o,
    // VGA
    .vga_hsync_o,
    .vga_vsync_o,
    .vga_red_o,
    .vga_green_o,
    .vga_blue_o
  );

endmodule