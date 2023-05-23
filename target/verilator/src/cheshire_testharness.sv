// Copyright 2023 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Jannis Schönleber <janniss@iis.ee.ethz.ch>

module cheshire_testharness import cheshire_pkg::*; (
  input  logic             clk_i,
  input  logic             rtc_i,
  input  logic             rst_ni,
  
  input  logic             jtag_tck,
  input  logic             jtag_tms,
  input  logic             jtag_trst_n,
  input  logic             jtag_tdi,
  output logic             jtag_tdo,
  
  output logic [31:0]      exit_o,

  input   logic               test_mode_i,

  // Boot mode selection
  input   logic [1:0]         boot_mode_i,

  // Serial Link
  input   logic [SlinkNumChan-1:0][SlinkNumLanes-1:0]  slink_i,
  output  logic [SlinkNumChan-1:0][SlinkNumLanes-1:0]  slink_o,
  input   logic [SlinkNumChan-1:0]                     slink_rcv_clk_i,
  output  logic [SlinkNumChan-1:0]                     slink_rcv_clk_o,

  // VGA Controller
  output  logic                                   vga_hsync_o,
  output  logic                                   vga_vsync_o,
  output  logic [DefaultCfg.VgaRedWidth-1:0]      vga_red_o,
  output  logic [DefaultCfg.VgaGreenWidth-1:0]    vga_green_o,
  output  logic [DefaultCfg.VgaBlueWidth-1:0]     vga_blue_o,

  // UART Interface
  output logic                uart_tx_o,
  input  logic                uart_rx_i,

  // I2C Interface
  output logic                i2c_sda_o,
  input  logic                i2c_sda_i,
  output logic                i2c_sda_en_o,
  output logic                i2c_scl_o,
  input  logic                i2c_scl_i,
  output logic                i2c_scl_en_o,

  // SPI Host Interface
  output logic                spih_sck_o,
  output logic                spih_sck_en_o,
  output logic [ SpihNumCs-1:0]         spih_csb_o,
  output logic [ SpihNumCs-1:0]         spih_csb_en_o,
  output logic [ 3:0]         spih_sd_o,
  output logic [ 3:0]         spih_sd_en_o,
  input  logic [ 3:0]         spih_sd_i,


  // GPIO interface
  input  logic [ 7:0]         gpio_i,
  output logic [ 7:0]         gpio_o,
  output logic [ 7:0]         gpio_en_o
);


  `include "cheshire/typedef.svh"

  import cheshire_pkg::*;

  localparam cheshire_cfg_t DutCfg = DefaultCfg;
  `CHESHIRE_TYPEDEF_ALL(, DutCfg)

  cheshire_soc #(
    .Cfg                ( DutCfg ),
    .ExtHartinfo        ( '0 ),
    .axi_ext_llc_req_t  ( axi_llc_req_t ),
    .axi_ext_llc_rsp_t  ( axi_llc_rsp_t ),
    .axi_ext_mst_req_t  ( axi_mst_req_t ),
    .axi_ext_mst_rsp_t  ( axi_mst_rsp_t ),
    .axi_ext_slv_req_t  ( axi_slv_req_t ),
    .axi_ext_slv_rsp_t  ( axi_slv_rsp_t ),
    .reg_ext_req_t      ( reg_req_t ),
    .reg_ext_rsp_t      ( reg_rsp_t )
  ) i_cheshire (
      .clk_i                  ( clk_i                 ),
      .rst_ni                 ( rst_ni                ),

      .test_mode_i            ( test_mode_i           ),

      .jtag_tck_i             ( jtag_tck              ),
      .jtag_trst_ni           ( jtag_trst_n           ),
      .jtag_tms_i             ( jtag_tms              ),
      .jtag_tdi_i             ( jtag_tdi              ),
      .jtag_tdo_o             ( jtag_tdo              ),

      .rtc_i                  ( rtc_i                 ),

      .boot_mode_i            ( boot_mode_i           ),

      .slink_i                ( slink_i               ),
      .slink_o                ( slink_o               ),

      .slink_rcv_clk_i        ( slink_rcv_clk_i       ),
      .slink_rcv_clk_o        ( slink_rcv_clk_o       ),

      .vga_hsync_o            ( vga_hsync_o           ),
      .vga_vsync_o            ( vga_vsync_o           ),
      .vga_red_o              ( vga_red_o             ),
      .vga_green_o            ( vga_green_o           ),
      .vga_blue_o             ( vga_blue_o            ),

      .uart_tx_o              ( uart_tx_o             ),
      .uart_rx_i              ( uart_rx_i             ),

      .i2c_sda_o              ( i2c_sda_o             ),
      .i2c_sda_i              ( i2c_sda_i             ),
      .i2c_sda_en_o           ( i2c_sda_en_o          ),
      .i2c_scl_o              ( i2c_scl_o             ),
      .i2c_scl_i              ( i2c_scl_i             ),
      .i2c_scl_en_o           ( i2c_scl_en_o          ),

      .spih_sck_o             ( spih_sck_o            ),
      .spih_sck_en_o          (  spih_sck_en_o        ),
      .spih_csb_o             ( spih_csb_o            ),
      .spih_csb_en_o          ( spih_csb_en_o         ),
      .spih_sd_o              ( spih_sd_o             ),
      .spih_sd_en_o           ( spih_sd_en_o          ),
      .spih_sd_i              ( spih_sd_i             ),

      .gpio_i                 ( gpio_o                ),
      .gpio_o                 ( gpio_o                ),
      .gpio_en_o              ( gpio_en_o             )
  );


endmodule
