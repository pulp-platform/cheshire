// Copyright 2022 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Nicole Narr <narrn@student.ethz.ch>
// Christopher Reinwardt <creinwar@student.ethz.ch>
// Paul Scheffler <paulsc@iis.ee.ethz.ch>

module fixture_cheshire_soc #(
  /// The selected simulation configuration from the `tb_cheshire_pkg`.
  parameter int unsigned SelectedCfg = 32'd2
);

  `include "cheshire/typedef.svh"

  import cheshire_pkg::*;
  import tb_cheshire_pkg::*;

  localparam cheshire_cfg_t DutCfg = TbCheshireConfigs[SelectedCfg];

  `CHESHIRE_TYPEDEF_ALL(, DutCfg)

  ///////////
  //  DUT  //
  ///////////

  logic       clk;
  logic       rst_n;
  logic       test_mode;
  logic [1:0] boot_mode;
  logic       rtc;

  axi_llc_req_t axi_llc_mst_req;
  axi_llc_rsp_t axi_llc_mst_rsp;

  // JTAG signals connected to the DUT
  logic jtag_tck;
  logic jtag_trst_n;
  logic jtag_tms;
  logic jtag_tdi;
  logic jtag_tdo;
  logic jtag_tdo_oe;

  // JTAG signals driven by the existing SystemVerilog VIP
  logic vip_jtag_tck;
  logic vip_jtag_trst_n;
  logic vip_jtag_tms;
  logic vip_jtag_tdi;

  // JTAG signals driven by SimJTAG / remote-bitbang
  logic rbb_jtag_tck;
  logic rbb_jtag_trst_n;
  logic rbb_jtag_tms;
  logic rbb_jtag_tdi;
  logic [31:0] rbb_exit;

  bit use_openocd;

  initial begin
    use_openocd = $test$plusargs("OPENOCD");

    if (use_openocd) begin
      $display("[SimJTAG] OpenOCD remote-bitbang mode enabled");
    end
  end

  // Only one JTAG master may drive the DUT at a time.
  assign jtag_tck    = use_openocd ? rbb_jtag_tck    : vip_jtag_tck;
  assign jtag_trst_n = use_openocd ? rbb_jtag_trst_n : vip_jtag_trst_n;
  assign jtag_tms    = use_openocd ? rbb_jtag_tms    : vip_jtag_tms;
  assign jtag_tdi    = use_openocd ? rbb_jtag_tdi    : vip_jtag_tdi;

  logic uart_tx;
  logic uart_rx;

  logic i2c_sda_o;
  logic i2c_sda_i;
  logic i2c_sda_en;
  logic i2c_scl_o;
  logic i2c_scl_i;
  logic i2c_scl_en;

  logic                 spih_sck_o;
  logic                 spih_sck_en;
  logic [SpihNumCs-1:0] spih_csb_o;
  logic [SpihNumCs-1:0] spih_csb_en;
  logic [ 3:0]          spih_sd_o;
  logic [ 3:0]          spih_sd_i;
  logic [ 3:0]          spih_sd_en;

  logic [SlinkNumChan-1:0]                    slink_rcv_clk_i;
  logic [SlinkNumChan-1:0]                    slink_rcv_clk_o;
  logic [SlinkNumChan-1:0][SlinkNumLanes-1:0] slink_i;
  logic [SlinkNumChan-1:0][SlinkNumLanes-1:0] slink_o;

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
  ) dut (
    .clk_i              ( clk       ),
    .rst_ni             ( rst_n     ),
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
    .jtag_tck_i         ( jtag_tck    ),
    .jtag_trst_ni       ( jtag_trst_n ),
    .jtag_tms_i         ( jtag_tms    ),
    .jtag_tdi_i         ( jtag_tdi    ),
    .jtag_tdo_o         ( jtag_tdo    ),
    .jtag_tdo_oe_o      ( jtag_tdo_oe ),
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
    .vga_blue_o         ( )
  );

  ////////////////////////
  //  Tristate Adapter  //
  ////////////////////////

  wire i2c_sda;
  wire i2c_scl;

  wire                 spih_sck;
  wire [SpihNumCs-1:0] spih_csb;
  wire [ 3:0]          spih_sd;

  vip_cheshire_soc_tristate vip_tristate (.*);

  ////////////////////////////
  // OpenOCD remote-bitbang //
  ////////////////////////////

  SimJTAG #(
    .TICK_DELAY ( 1 )
  ) i_sim_jtag (
    .clock           ( clk             ),
    .reset           ( ~rst_n          ),
    .enable          ( use_openocd     ),
    .init_done       ( rst_n           ),
    .jtag_TCK        ( rbb_jtag_tck    ),
    .jtag_TMS        ( rbb_jtag_tms    ),
    .jtag_TDI        ( rbb_jtag_tdi    ),
    .jtag_TRSTn      ( rbb_jtag_trst_n ),
    .jtag_TDO_data   ( jtag_tdo        ),
    .jtag_TDO_driven ( jtag_tdo_oe     ),
    .exit            ( rbb_exit        )
  );

  ///////////
  //  VIP  //
  ///////////

  axi_mst_req_t axi_slink_mst_req;
  axi_mst_rsp_t axi_slink_mst_rsp;

  assign axi_slink_mst_req = '0;

  vip_cheshire_soc #(
  .DutCfg                ( DutCfg        ),
  .axi_ext_llc_req_t     ( axi_llc_req_t ),
  .axi_ext_llc_rsp_t     ( axi_llc_rsp_t ),
  .axi_ext_mst_req_t     ( axi_mst_req_t ),
  .axi_ext_mst_rsp_t     ( axi_mst_rsp_t )
) vip (
  .jtag_tck              ( vip_jtag_tck    ),
  .jtag_trst_n           ( vip_jtag_trst_n ),
  .jtag_tms              ( vip_jtag_tms    ),
  .jtag_tdi              ( vip_jtag_tdi    ),
  .jtag_tdo              ( jtag_tdo        ),
  .*
);

endmodule
