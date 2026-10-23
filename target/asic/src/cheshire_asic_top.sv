// Copyright 2026 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Technology-agnostic implementation top for `cheshire_soc`.
//
// Every port of `cheshire_soc` with logic behind it is exposed, so that none is
// optimized away behind an open output or a tied input. The external AXI,
// register, interrupt and debug ports are not: no configuration here connects
// them (their counts are 0, which `cheshire_soc` still gives one element), so
// they would only add some 800 dead pins. Struct ports are flattened into packed
// vectors, giving clean bus pins in netlists and constraints. The configuration
// is selected in `cheshire_asic_pkg`.
//
// The LLC's DRAM port leaves through a cut on all AXI channels (`LlcPortCut`):
// without it, data read from the LLC's memory macros reaches the outputs, and
// responses reach the LLC's logic, without a register, as a chip's DRAM
// controller would not see them.

module cheshire_asic_top import cheshire_pkg::*; import cheshire_asic_pkg::*; #(
  parameter bit LlcPortCut = 1'b1
) (
  input  logic        clk_i,
  input  logic        rst_ni,
  input  logic        test_mode_i,
  input  logic [1:0]  boot_mode_i,
  input  logic        rtc_i,
  // External AXI LLC (DRAM) port
  output logic [$bits(asic_axi_llc_req_t)-1:0] axi_llc_mst_req_o,
  input  logic [$bits(asic_axi_llc_rsp_t)-1:0] axi_llc_mst_rsp_i,
  // Debug module activity
  output logic        dbg_active_o,
  // JTAG interface
  input  logic  jtag_tck_i,
  input  logic  jtag_trst_ni,
  input  logic  jtag_tms_i,
  input  logic  jtag_tdi_i,
  output logic  jtag_tdo_o,
  output logic  jtag_tdo_oe_o,
  // UART interface
  output logic  uart_tx_o,
  input  logic  uart_rx_i,
  // UART modem flow control
  output logic  uart_rts_no,
  output logic  uart_dtr_no,
  input  logic  uart_cts_ni,
  input  logic  uart_dsr_ni,
  input  logic  uart_dcd_ni,
  input  logic  uart_rin_ni,
  // I2C interface
  output logic  i2c_sda_o,
  input  logic  i2c_sda_i,
  output logic  i2c_sda_en_o,
  output logic  i2c_scl_o,
  input  logic  i2c_scl_i,
  output logic  i2c_scl_en_o,
  // SPI host interface
  output logic                  spih_sck_o,
  output logic                  spih_sck_en_o,
  output logic [SpihNumCs-1:0]  spih_csb_o,
  output logic [SpihNumCs-1:0]  spih_csb_en_o,
  output logic [ 3:0]           spih_sd_o,
  output logic [ 3:0]           spih_sd_en_o,
  input  logic [ 3:0]           spih_sd_i,
  // GPIO interface
  input  logic [31:0] gpio_i,
  output logic [31:0] gpio_o,
  output logic [31:0] gpio_en_o,
  // Serial link interface
  input  logic [SlinkNumChan-1:0]                     slink_rcv_clk_i,
  output logic [SlinkNumChan-1:0]                     slink_rcv_clk_o,
  input  logic [SlinkNumChan-1:0][SlinkNumLanes-1:0]  slink_i,
  output logic [SlinkNumChan-1:0][SlinkNumLanes-1:0]  slink_o,
  // VGA interface
  output logic                              vga_hsync_o,
  output logic                              vga_vsync_o,
  output logic [AsicCfg.VgaRedWidth  -1:0]  vga_red_o,
  output logic [AsicCfg.VgaGreenWidth-1:0]  vga_green_o,
  output logic [AsicCfg.VgaBlueWidth -1:0]  vga_blue_o,
  // USB interface
  input  logic                   usb_clk_i,
  input  logic                   usb_rst_ni,
  input  logic [UsbNumPorts-1:0] usb_dm_i,
  output logic [UsbNumPorts-1:0] usb_dm_o,
  output logic [UsbNumPorts-1:0] usb_dm_oe_o,
  input  logic [UsbNumPorts-1:0] usb_dp_i,
  output logic [UsbNumPorts-1:0] usb_dp_o,
  output logic [UsbNumPorts-1:0] usb_dp_oe_o
);

  if (AsicCfgIdx >= NumAsicCfgs) begin : gen_cfg_check
    $fatal(1, "CHS_ASIC_CFG=%0d selects no configuration (have %0d)", AsicCfgIdx, NumAsicCfgs);
  end

  // The external ports are tied off below: a configuration connecting any of
  // them needs ports (and cuts) here first
  if (AsicCfg.AxiExtNumMst != 0 || AsicCfg.AxiExtNumSlv != 0 || AsicCfg.RegExtNumSlv != 0 ||
      AsicCfg.NumExtInIntrs != 0 || AsicCfg.NumExtOutIntrTgts != 0 ||
      AsicCfg.NumExtIrqHarts != 0 || AsicCfg.NumExtDbgHarts != 0) begin : gen_ext_check
    $fatal(1, "CHS_ASIC_CFG=%0d enables external ports that cheshire_asic_top does not expose",
        AsicCfgIdx);
  end

  // The constraints treat the GPIO inputs as asynchronous: they must enter
  // synchronizers
  if (AsicCfg.Gpio && !AsicCfg.GpioInputSyncs) begin : gen_gpio_sync_check
    $fatal(1, "CHS_ASIC_CFG=%0d disables the GPIO input synchronizers (GpioInputSyncs)",
        AsicCfgIdx);
  end

  asic_axi_llc_req_t llc_req;
  asic_axi_llc_rsp_t llc_rsp;

  axi_cut #(
    .Bypass     ( !LlcPortCut ),
    .aw_chan_t  ( asic_axi_llc_aw_chan_t ),
    .w_chan_t   ( asic_axi_llc_w_chan_t ),
    .b_chan_t   ( asic_axi_llc_b_chan_t ),
    .ar_chan_t  ( asic_axi_llc_ar_chan_t ),
    .r_chan_t   ( asic_axi_llc_r_chan_t ),
    .axi_req_t  ( asic_axi_llc_req_t ),
    .axi_resp_t ( asic_axi_llc_rsp_t )
  ) i_llc_cut (
    .clk_i,
    .rst_ni,
    .slv_req_i  ( llc_req ),
    .slv_resp_o ( llc_rsp ),
    .mst_req_o  ( axi_llc_mst_req_o ),
    .mst_resp_i ( axi_llc_mst_rsp_i )
  );

  cheshire_soc #(
    .Cfg                ( AsicCfg ),
    .ExtHartinfo        ( '0 ),
    .axi_ext_llc_req_t  ( asic_axi_llc_req_t ),
    .axi_ext_llc_rsp_t  ( asic_axi_llc_rsp_t ),
    .axi_ext_mst_req_t  ( asic_axi_mst_req_t ),
    .axi_ext_mst_rsp_t  ( asic_axi_mst_rsp_t ),
    .axi_ext_slv_req_t  ( asic_axi_slv_req_t ),
    .axi_ext_slv_rsp_t  ( asic_axi_slv_rsp_t ),
    .reg_ext_req_t      ( asic_reg_req_t ),
    .reg_ext_rsp_t      ( asic_reg_rsp_t )
  ) i_cheshire_soc (
    .clk_i,
    .rst_ni,
    .test_mode_i,
    .boot_mode_i,
    .rtc_i,
    .axi_llc_mst_req_o  ( llc_req ),
    .axi_llc_mst_rsp_i  ( llc_rsp ),
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
    .dbg_active_o,
    .dbg_ext_req_o      ( ),
    .dbg_ext_unavail_i  ( '0 ),
    .jtag_tck_i,
    .jtag_trst_ni,
    .jtag_tms_i,
    .jtag_tdi_i,
    .jtag_tdo_o,
    .jtag_tdo_oe_o,
    .uart_tx_o,
    .uart_rx_i,
    .uart_rts_no,
    .uart_dtr_no,
    .uart_cts_ni,
    .uart_dsr_ni,
    .uart_dcd_ni,
    .uart_rin_ni,
    .i2c_sda_o,
    .i2c_sda_i,
    .i2c_sda_en_o,
    .i2c_scl_o,
    .i2c_scl_i,
    .i2c_scl_en_o,
    .spih_sck_o,
    .spih_sck_en_o,
    .spih_csb_o,
    .spih_csb_en_o,
    .spih_sd_o,
    .spih_sd_en_o,
    .spih_sd_i,
    .gpio_i,
    .gpio_o,
    .gpio_en_o,
    .slink_rcv_clk_i,
    .slink_rcv_clk_o,
    .slink_i,
    .slink_o,
    .vga_hsync_o,
    .vga_vsync_o,
    .vga_red_o,
    .vga_green_o,
    .vga_blue_o,
    .usb_clk_i,
    .usb_rst_ni,
    .usb_dm_i,
    .usb_dm_o,
    .usb_dm_oe_o,
    .usb_dp_i,
    .usb_dp_o,
    .usb_dp_oe_o
  );

endmodule
