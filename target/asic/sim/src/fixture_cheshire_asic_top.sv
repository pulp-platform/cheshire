// Copyright 2026 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Simulation fixture of `cheshire_asic_top`: the RTL top or a netlist of it,
// driven by Cheshire's VIP (`vip_cheshire_soc`) as in `fixture_cheshire_soc`.
// The configuration is the implemented one (`cheshire_asic_pkg::AsicCfg`,
// selected with CHS_ASIC_CFG). The LLC's DRAM port, a packed vector on the top,
// is cast to the VIP's AXI structs. `gpio_o` is visible here so that
// simulation scripts can follow markers a program writes to the GPIOs.

module fixture_cheshire_asic_top #(
  parameter bit      UseDramSys   = 1'b0,
  /// System clock period: the implemented one, so that activity recorded in
  /// simulation has the implemented toggle rates
  parameter realtime ClkPeriodSys = 5ns,
  /// When the VIP changes the DUT's inputs, as a fraction of the clock period
  /// after the clock edge: after the edge has reached the DUT's flip-flops
  /// through its clock tree in a simulation with delays
  parameter real     TAppl        = 0.1
);

  `include "cheshire/typedef.svh"

  import cheshire_pkg::*;
  import cheshire_asic_pkg::*;

  localparam cheshire_cfg_t DutCfg = AsicCfg;

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

  logic [$bits(axi_llc_req_t)-1:0] axi_llc_mst_req_vec;
  logic [$bits(axi_llc_rsp_t)-1:0] axi_llc_mst_rsp_vec;

  assign axi_llc_mst_req     = axi_llc_req_t'(axi_llc_mst_req_vec);
  assign axi_llc_mst_rsp_vec = axi_llc_mst_rsp;

  logic jtag_tck;
  logic jtag_trst_n;
  logic jtag_trst_n_dut;
  logic jtag_tms;
  logic jtag_tdi;
  logic jtag_tdo;

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

  logic [31:0] gpio_o;
  logic [31:0] gpio_en;

  logic [SlinkNumChan-1:0]                    slink_rcv_clk_i;
  logic [SlinkNumChan-1:0]                    slink_rcv_clk_o;
  logic [SlinkNumChan-1:0][SlinkNumLanes-1:0] slink_i;
  logic [SlinkNumChan-1:0][SlinkNumLanes-1:0] slink_o;

  // TRST is asserted from power-up until the VIP drives it, as a pull-down
  // would hold it: the JTAG side of the debug module's clock domain crossing is
  // in reset whenever the system side is
  assign jtag_trst_n_dut = (jtag_trst_n === 1'bx) ? 1'b0 : jtag_trst_n;

  cheshire_asic_top dut (
    .clk_i              ( clk       ),
    .rst_ni             ( rst_n     ),
    .test_mode_i        ( test_mode ),
    .boot_mode_i        ( boot_mode ),
    .rtc_i              ( rtc       ),
    .axi_llc_mst_req_o  ( axi_llc_mst_req_vec ),
    .axi_llc_mst_rsp_i  ( axi_llc_mst_rsp_vec ),
    .dbg_active_o       ( ),
    .jtag_tck_i         ( jtag_tck    ),
    .jtag_trst_ni       ( jtag_trst_n_dut ),
    .jtag_tms_i         ( jtag_tms    ),
    .jtag_tdi_i         ( jtag_tdi    ),
    .jtag_tdo_o         ( jtag_tdo    ),
    .jtag_tdo_oe_o      ( ),
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
    .gpio_o             ( gpio_o  ),
    .gpio_en_o          ( gpio_en ),
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

  ////////////////////////
  //  Tristate Adapter  //
  ////////////////////////

  wire i2c_sda;
  wire i2c_scl;

  wire                 spih_sck;
  wire [SpihNumCs-1:0] spih_csb;
  wire [ 3:0]          spih_sd;

  vip_cheshire_soc_tristate vip_tristate (
    .i2c_sda_i   ( i2c_sda_i   ),
    .i2c_sda_o   ( i2c_sda_o   ),
    .i2c_sda_en  ( i2c_sda_en  ),
    .i2c_scl_i   ( i2c_scl_i   ),
    .i2c_scl_o   ( i2c_scl_o   ),
    .i2c_scl_en  ( i2c_scl_en  ),
    .spih_sck_o  ( spih_sck_o  ),
    .spih_sck_en ( spih_sck_en ),
    .spih_csb_o  ( spih_csb_o  ),
    .spih_csb_en ( spih_csb_en ),
    .spih_sd_i   ( spih_sd_i   ),
    .spih_sd_o   ( spih_sd_o   ),
    .spih_sd_en  ( spih_sd_en  ),
    .i2c_sda     ( i2c_sda     ),
    .i2c_scl     ( i2c_scl     ),
    .spih_sck    ( spih_sck    ),
    .spih_csb    ( spih_csb    ),
    .spih_sd     ( spih_sd     )
  );

  ///////////
  //  VIP  //
  ///////////

  axi_mst_req_t axi_slink_mst_req;
  axi_mst_rsp_t axi_slink_mst_rsp;

  assign axi_slink_mst_req = '0;

  vip_cheshire_soc #(
    .DutCfg            ( DutCfg ),
    .UseDramSys        ( UseDramSys ),
    .ClkPeriodSys      ( ClkPeriodSys ),
    .TAppl             ( TAppl ),
    .axi_ext_llc_req_t ( axi_llc_req_t ),
    .axi_ext_llc_rsp_t ( axi_llc_rsp_t ),
    .axi_ext_mst_req_t ( axi_mst_req_t ),
    .axi_ext_mst_rsp_t ( axi_mst_rsp_t )
  ) vip (
    .clk               ( clk               ),
    .rst_n             ( rst_n             ),
    .test_mode         ( test_mode         ),
    .boot_mode         ( boot_mode         ),
    .rtc               ( rtc               ),
    .axi_llc_mst_req   ( axi_llc_mst_req   ),
    .axi_llc_mst_rsp   ( axi_llc_mst_rsp   ),
    .axi_slink_mst_req ( axi_slink_mst_req ),
    .axi_slink_mst_rsp ( axi_slink_mst_rsp ),
    .jtag_tck          ( jtag_tck          ),
    .jtag_trst_n       ( jtag_trst_n       ),
    .jtag_tms          ( jtag_tms          ),
    .jtag_tdi          ( jtag_tdi          ),
    .jtag_tdo          ( jtag_tdo          ),
    .uart_tx           ( uart_tx           ),
    .uart_rx           ( uart_rx           ),
    .i2c_sda           ( i2c_sda           ),
    .i2c_scl           ( i2c_scl           ),
    .spih_sck          ( spih_sck          ),
    .spih_csb          ( spih_csb          ),
    .spih_sd           ( spih_sd           ),
    .slink_rcv_clk_i   ( slink_rcv_clk_i   ),
    .slink_rcv_clk_o   ( slink_rcv_clk_o   ),
    .slink_i           ( slink_i           ),
    .slink_o           ( slink_o           )
  );

endmodule
