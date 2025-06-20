// Copyright 2025 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Max Wipfli <mwipfli@student.ethz.ch>

module cheshire_soc_wrapper (
  input logic clk_i,
  input logic rtc_i,
  input logic rst_ni,

  // JTAG
  input  logic jtag_tck_i,
  input  logic jtag_trst_ni,
  input  logic jtag_tms_i,
  input  logic jtag_tdi_i,
  output logic jtag_tdo_o,
  output logic jtag_tdo_oe_o
);

  `include "cheshire/typedef.svh"

  import cheshire_pkg::*;

  function automatic cheshire_pkg::cheshire_cfg_t gen_cheshire_cfg();
    cheshire_pkg::cheshire_cfg_t ret = cheshire_pkg::DefaultCfg;
    ret.SerialLink = 1'b0;
    return ret;
  endfunction

  localparam cheshire_cfg_t DutCfg = gen_cheshire_cfg();

  `CHESHIRE_TYPEDEF_ALL(, DutCfg)

  ///////////
  //  DUT  //
  ///////////

  logic       test_mode;
  logic [1:0] boot_mode;
  logic       rtc;

  assign test_mode = 1'b0;
  assign boot_mode = 2'b00; // passive

  axi_llc_req_t axi_llc_mst_req;
  axi_llc_rsp_t axi_llc_mst_rsp;

  logic jtag_tck;
  logic jtag_trst_n;
  logic jtag_tms;
  logic jtag_tdi;
  logic jtag_tdo;
  logic jtag_tdo_oe;

  logic uart_tx;
  logic uart_rx;

  logic i2c_sda_o;
  logic i2c_sda_i;
  logic i2c_sda_en;
  logic i2c_scl_o;
  logic i2c_scl_i;
  logic i2c_scl_en;
  assign i2c_sda_i = 1'b1;
  assign i2c_scl_i = 1'b1;

  logic                 spih_sck_o;
  logic                 spih_sck_en;
  logic [SpihNumCs-1:0] spih_csb_o;
  logic [SpihNumCs-1:0] spih_csb_en;
  logic [ 3:0]          spih_sd_o;
  logic [ 3:0]          spih_sd_i;
  logic [ 3:0]          spih_sd_en;
  assign spih_sd_i = 1'b0;

  logic [SlinkNumChan-1:0]                    slink_rcv_clk_i;
  logic [SlinkNumChan-1:0]                    slink_rcv_clk_o;
  logic [SlinkNumChan-1:0][SlinkNumLanes-1:0] slink_i;
  logic [SlinkNumChan-1:0][SlinkNumLanes-1:0] slink_o;
  assign slink_rcv_clk_i = '1;
  assign slink_i         = '1;

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
  ) i_dut (
    .clk_i              ( clk_i     ),
    .rst_ni             ( rst_ni    ),
    .test_mode_i        ( test_mode ),
    .boot_mode_i        ( boot_mode ),
    .rtc_i              ( rtc       ),
    .axi_llc_mst_req_o  ( axi_llc_mst_req ),
    .axi_llc_mst_rsp_i  ( axi_llc_mst_rsp ),
    .axi_ext_mst_req_i  ( '0 ),
    .axi_ext_mst_rsp_o  ( ),
    .axi_ext_slv_req_o  ( ),
    .axi_ext_slv_rsp_i  ( '0 ),
    .reg_ext_slv_req_o  ( ),
    .reg_ext_slv_rsp_i  ( '0 ),
    .intr_ext_i         ( '0 ),
    .intr_ext_o         ( ),
    .xeip_ext_o         ( ),
    .mtip_ext_o         ( ),
    .msip_ext_o         ( ),
    .dbg_active_o       ( ),
    .dbg_ext_req_o      ( ),
    .dbg_ext_unavail_i  ( '0 ),
    .jtag_tck_i         ( jtag_tck_i    ),
    .jtag_trst_ni       ( jtag_trst_ni  ),
    .jtag_tms_i         ( jtag_tms_i    ),
    .jtag_tdi_i         ( jtag_tdi_i    ),
    .jtag_tdo_o         ( jtag_tdo_o    ),
    .jtag_tdo_oe_o      ( jtag_tdo_oe_o ),
    .uart_tx_o          ( uart_tx ),
    .uart_rx_i          ( uart_rx ),
    .uart_rts_no        ( ),
    .uart_dtr_no        ( ),
    .uart_cts_ni        ( 1'b0 ),
    .uart_dsr_ni        ( 1'b0 ),
    .uart_dcd_ni        ( 1'b0 ),
    .uart_rin_ni        ( 1'b0 ),
    .i2c_sda_o          ( i2c_sda_o  ),
    .i2c_sda_i          ( i2c_sda_i  ),
    .i2c_sda_en_o       ( i2c_sda_en ),
    .i2c_scl_o          ( i2c_scl_o  ),
    .i2c_scl_i          ( i2c_scl_i  ),
    .i2c_scl_en_o       ( i2c_scl_en ),
    .spih_sck_o         ( spih_sck_o  ),
    .spih_sck_en_o      ( spih_sck_en ),
    .spih_csb_o         ( spih_csb_o  ),
    .spih_csb_en_o      ( spih_csb_en ),
    .spih_sd_o          ( spih_sd_o   ),
    .spih_sd_en_o       ( spih_sd_en  ),
    .spih_sd_i          ( spih_sd_i   ),
    .gpio_i             ( '0 ),
    .gpio_o             ( ),
    .gpio_en_o          ( ),
    .slink_rcv_clk_i    ( slink_rcv_clk_i ),
    .slink_rcv_clk_o    ( slink_rcv_clk_o ),
    .slink_i            ( slink_i ),
    .slink_o            ( slink_o ),
    .vga_hsync_o        ( ),
    .vga_vsync_o        ( ),
    .vga_red_o          ( ),
    .vga_green_o        ( ),
    .vga_blue_o         ( ),
    .usb_clk_i          ( 1'b0 ),
    .usb_rst_ni         ( 1'b1 ),
    .usb_dm_i           ( '0 ),
    .usb_dm_o           ( ),
    .usb_dm_oe_o        ( ),
    .usb_dp_i           ( '0 ),
    .usb_dp_o           ( ),
    .usb_dp_oe_o        ( )
  );

  ////////////
  //  DRAM  //
  ////////////

  // axi_sim_mem #(
  //   .AddrWidth          ( DutCfg.AddrWidth    ),
  //   .DataWidth          ( DutCfg.AxiDataWidth ),
  //   .IdWidth            ( $bits(axi_llc_id_t) ),
  //   .UserWidth          ( DutCfg.AxiUserWidth ),
  //   .axi_req_t          ( axi_llc_req_t ),
  //   .axi_rsp_t          ( axi_llc_rsp_t ),
  //   .WarnUninitialized  ( 0 ),
  //   .ClearErrOnAccess   ( 1 ),
  //   .ApplDelay          ( 0ps ),
  //   .AcqDelay           ( 0ps )
  // ) i_dram_sim_mem (
  //   .clk_i              ( clk_i  ),
  //   .rst_ni             ( rst_ni ),
  //   .axi_req_i          ( axi_llc_mst_req ),
  //   .axi_rsp_o          ( axi_llc_mst_rsp ),
  //   .mon_w_valid_o      ( ),
  //   .mon_w_addr_o       ( ),
  //   .mon_w_data_o       ( ),
  //   .mon_w_id_o         ( ),
  //   .mon_w_user_o       ( ),
  //   .mon_w_beat_count_o ( ),
  //   .mon_w_last_o       ( ),
  //   .mon_r_valid_o      ( ),
  //   .mon_r_addr_o       ( ),
  //   .mon_r_data_o       ( ),
  //   .mon_r_id_o         ( ),
  //   .mon_r_user_o       ( ),
  //   .mon_r_beat_count_o ( ),
  //   .mon_r_last_o       ( )
  // );
  assign axi_llc_mst_rsp = '0;

endmodule
