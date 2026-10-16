// Copyright 2026 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Enrico Zelioli <ezelioli@iis.ee.ethz.ch>
//
// Based on prior work by Max Wipfli <mwipfli@student.ethz.ch>
// and Paul Scheffler <paulsc@iis.ee.ethz.ch>.

// Top level for fast, untimed Verilator simulation of Cheshire. Clocks, resets, JTAG, and UART
// are driven by the C++ harness in `main.cpp`. The harness accesses the SoC through an AXI port
// into a mirrored serial link, and DRAM through a sparse memory it also owns.

module cheshire_top_verilator import cheshire_pkg::*; #(
  /// The selected simulation configuration from the `tb_cheshire_pkg`.
  parameter int unsigned SelectedCfg = 32'd0,
  /// RTC frequency in Hz overriding that of the selected configuration (0: keep it).
  /// The harness generates `rtc_i` at the resulting frequency.
  parameter int unsigned RtcFreq     = 32'd0
) (
  input  logic        clk_i,
  input  logic        rst_ni,
  input  logic        rtc_i,
  input  logic [1:0]  boot_mode_i,
  // JTAG
  input  logic        jtag_tck_i,
  input  logic        jtag_trst_ni,
  input  logic        jtag_tms_i,
  input  logic        jtag_tdi_i,
  output logic        jtag_tdo_o,
  // UART
  output logic        uart_tx_o,
  input  logic        uart_rx_i,
  // AXI port into the mirror serial link (INCR bursts with ID 0)
  input  logic        slink_aw_valid_i,
  output logic        slink_aw_ready_o,
  input  logic [63:0] slink_aw_addr_i,
  input  logic [7:0]  slink_aw_len_i,
  input  logic [2:0]  slink_aw_size_i,
  input  logic        slink_w_valid_i,
  output logic        slink_w_ready_o,
  input  logic [63:0] slink_w_data_i,
  input  logic [7:0]  slink_w_strb_i,
  input  logic        slink_w_last_i,
  output logic        slink_b_valid_o,
  input  logic        slink_b_ready_i,
  output logic [1:0]  slink_b_resp_o,
  input  logic        slink_ar_valid_i,
  output logic        slink_ar_ready_o,
  input  logic [63:0] slink_ar_addr_i,
  input  logic [7:0]  slink_ar_len_i,
  input  logic [2:0]  slink_ar_size_i,
  output logic        slink_r_valid_o,
  input  logic        slink_r_ready_i,
  output logic [63:0] slink_r_data_o,
  output logic [1:0]  slink_r_resp_o,
  output logic        slink_r_last_o,
  // Debug: PC of the instruction at the commit stage of hart 0
  output logic [63:0] dbg_pc_commit_o
);

  `include "cheshire/typedef.svh"

  import cheshire_addrmap_pkg::*;

  function automatic cheshire_cfg_t gen_dut_cfg();
    cheshire_cfg_t ret = tb_cheshire_pkg::TbCheshireConfigs[SelectedCfg];
    if (RtcFreq != 0) ret.RtcFreq = RtcFreq;
    return ret;
  endfunction

  localparam cheshire_cfg_t DutCfg = gen_dut_cfg();

  `CHESHIRE_TYPEDEF_ALL(, DutCfg)

  if (DutCfg.AxiDataWidth != 64 || DutCfg.AddrWidth > 64) begin : gen_cfg_check
    $fatal(1, "The Verilator harness requires a 64-bit AXI data width and <= 64-bit addresses.");
  end

  //////////////////////
  //  Config Exports  //
  //////////////////////

  // Configuration-dependent constants for the C++ harness
  export "DPI-C" function chs_vlt_get_cfg;

  function automatic void chs_vlt_get_cfg(
    output longint unsigned scratch_base,
    output longint unsigned llc_spm_cfg_addr,
    output byte unsigned    llc_not_bypass,
    output longint unsigned dram_base,
    output longint unsigned dram_end,
    output int unsigned     dbg_idcode,
    output int unsigned     rtc_freq
  );
    scratch_base     = REGS_SCRATCH_BASE_ADDR(0);
    llc_spm_cfg_addr = LLC_BASE_ADDR + axi_llc_reg_pkg::AXI_LLC_CFG_SPM_LOW_OFFSET;
    llc_not_bypass   = 8'(DutCfg.LlcNotBypass);
    dram_base        = DutCfg.LlcOutRegionStart;
    dram_end         = DutCfg.LlcOutRegionEnd;
    dbg_idcode       = DutCfg.DbgIdCode;
    rtc_freq         = DutCfg.RtcFreq;
  endfunction

  ///////////
  //  DUT  //
  ///////////

  axi_llc_req_t axi_llc_mst_req;
  axi_llc_rsp_t axi_llc_mst_rsp;

  logic i2c_sda_o, i2c_sda_en;
  logic i2c_scl_o, i2c_scl_en;

  logic [3:0] spih_sd_o, spih_sd_en;

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
  ) i_dut (
    .clk_i,
    .rst_ni,
    .test_mode_i        ( 1'b0 ),
    .boot_mode_i,
    .rtc_i,
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
    .jtag_tck_i,
    .jtag_trst_ni,
    .jtag_tms_i,
    .jtag_tdi_i,
    .jtag_tdo_o,
    .jtag_tdo_oe_o      ( ),
    .uart_tx_o,
    .uart_rx_i,
    .uart_rts_no        ( ),
    .uart_dtr_no        ( ),
    .uart_cts_ni        ( 1'b0 ),
    .uart_dsr_ni        ( 1'b0 ),
    .uart_dcd_ni        ( 1'b0 ),
    .uart_rin_ni        ( 1'b0 ),
    // Emulate pullups on otherwise undriven I2C and SPI lines
    .i2c_sda_o,
    .i2c_sda_i          ( i2c_sda_en ? i2c_sda_o : 1'b1 ),
    .i2c_sda_en_o       ( i2c_sda_en ),
    .i2c_scl_o,
    .i2c_scl_i          ( i2c_scl_en ? i2c_scl_o : 1'b1 ),
    .i2c_scl_en_o       ( i2c_scl_en ),
    .spih_sck_o         ( ),
    .spih_sck_en_o      ( ),
    .spih_csb_o         ( ),
    .spih_csb_en_o      ( ),
    .spih_sd_o,
    .spih_sd_en_o       ( spih_sd_en ),
    .spih_sd_i          ( (spih_sd_o & spih_sd_en) | ~spih_sd_en ),
    .gpio_i             ( '0 ),
    .gpio_o             ( ),
    .gpio_en_o          ( ),
    .slink_rcv_clk_i,
    .slink_rcv_clk_o,
    .slink_i,
    .slink_o,
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

  assign dbg_pc_commit_o = 64'(i_dut.gen_cva6_cores[0].i_core_cva6.pc_commit);

  ////////////
  //  DRAM  //
  ////////////

  cheshire_vlt_axi_mem #(
    .MemId      ( 0 ),
    .AddrWidth  ( DutCfg.AddrWidth    ),
    .DataWidth  ( DutCfg.AxiDataWidth ),
    .IdWidth    ( $bits(axi_llc_id_t) ),
    .aw_chan_t  ( axi_llc_aw_chan_t ),
    .w_chan_t   ( axi_llc_w_chan_t  ),
    .b_chan_t   ( axi_llc_b_chan_t  ),
    .ar_chan_t  ( axi_llc_ar_chan_t ),
    .r_chan_t   ( axi_llc_r_chan_t  ),
    .axi_req_t  ( axi_llc_req_t ),
    .axi_rsp_t  ( axi_llc_rsp_t )
  ) i_dram (
    .clk_i,
    .rst_ni,
    .axi_req_i  ( axi_llc_mst_req ),
    .axi_rsp_o  ( axi_llc_mst_rsp )
  );

  ///////////////////
  //  Serial Link  //
  ///////////////////

  axi_mst_req_t slink_axi_mst_req, slink_axi_slv_req;
  axi_mst_rsp_t slink_axi_mst_rsp, slink_axi_slv_rsp;

  // Assemble AXI requests from the harness; unlisted fields (e.g. IDs, cache) are zero
  always_comb begin
    slink_axi_mst_req          = '0;
    slink_axi_mst_req.aw.addr  = slink_aw_addr_i[DutCfg.AddrWidth-1:0];
    slink_axi_mst_req.aw.len   = slink_aw_len_i;
    slink_axi_mst_req.aw.size  = slink_aw_size_i;
    slink_axi_mst_req.aw.burst = axi_pkg::BURST_INCR;
    slink_axi_mst_req.aw_valid = slink_aw_valid_i;
    slink_axi_mst_req.w.data   = slink_w_data_i;
    slink_axi_mst_req.w.strb   = slink_w_strb_i;
    slink_axi_mst_req.w.last   = slink_w_last_i;
    slink_axi_mst_req.w_valid  = slink_w_valid_i;
    slink_axi_mst_req.b_ready  = slink_b_ready_i;
    slink_axi_mst_req.ar.addr  = slink_ar_addr_i[DutCfg.AddrWidth-1:0];
    slink_axi_mst_req.ar.len   = slink_ar_len_i;
    slink_axi_mst_req.ar.size  = slink_ar_size_i;
    slink_axi_mst_req.ar.burst = axi_pkg::BURST_INCR;
    slink_axi_mst_req.ar_valid = slink_ar_valid_i;
    slink_axi_mst_req.r_ready  = slink_r_ready_i;
  end

  assign slink_aw_ready_o = slink_axi_mst_rsp.aw_ready;
  assign slink_w_ready_o  = slink_axi_mst_rsp.w_ready;
  assign slink_b_valid_o  = slink_axi_mst_rsp.b_valid;
  assign slink_b_resp_o   = slink_axi_mst_rsp.b.resp;
  assign slink_ar_ready_o = slink_axi_mst_rsp.ar_ready;
  assign slink_r_valid_o  = slink_axi_mst_rsp.r_valid;
  assign slink_r_data_o   = slink_axi_mst_rsp.r.data;
  assign slink_r_resp_o   = slink_axi_mst_rsp.r.resp;
  assign slink_r_last_o   = slink_axi_mst_rsp.r.last;

  // Mirror instance of serial link, reflecting another chip
  slink #(
    .axi_req_t    ( axi_mst_req_t ),
    .axi_rsp_t    ( axi_mst_rsp_t ),
    .aw_chan_t    ( axi_mst_aw_chan_t ),
    .ar_chan_t    ( axi_mst_ar_chan_t ),
    .r_chan_t     ( axi_mst_r_chan_t  ),
    .w_chan_t     ( axi_mst_w_chan_t  ),
    .b_chan_t     ( axi_mst_b_chan_t  ),
    .apb_req_t    ( apb_req_t  ),
    .apb_rsp_t    ( apb_resp_t ),
    .NoRegCdc     ( 1'b1 ) // Since reg_clk_i is assigned to clk_i
  ) i_serial_link (
    .clk_i,
    .rst_ni,
    .clk_sl_i       ( clk_i  ),
    .rst_sl_ni      ( rst_ni ),
    .clk_reg_i      ( clk_i  ),
    .rst_reg_ni     ( rst_ni ),
    .testmode_i     ( 1'b0 ),
    .axi_in_req_i   ( slink_axi_mst_req ),
    .axi_in_rsp_o   ( slink_axi_mst_rsp ),
    .axi_out_req_o  ( slink_axi_slv_req ),
    .axi_out_rsp_i  ( slink_axi_slv_rsp ),
    .apb_req_i      ( '0 ),
    .apb_rsp_o      ( ),
    .ddr_rcv_clk_i  ( slink_rcv_clk_o ),
    .ddr_rcv_clk_o  ( slink_rcv_clk_i ),
    .ddr_i          ( slink_o ),
    .ddr_o          ( slink_i ),
    .isolated_i     ( '0 ),
    .isolate_o      ( ),
    .clk_ena_o      ( ),
    .reset_no       ( )
  );

  // Requests from the SoC through the serial link are served by a memory on the far side.
  // The serial link delivers W only after its AW, so the memory needs a decoupling FIFO.
  cheshire_vlt_axi_mem #(
    .MemId      ( 1 ),
    .AddrWidth  ( DutCfg.AddrWidth     ),
    .DataWidth  ( DutCfg.AxiDataWidth  ),
    .IdWidth    ( DutCfg.AxiMstIdWidth ),
    .FifoDepth  ( 16 ),
    .aw_chan_t  ( axi_mst_aw_chan_t ),
    .w_chan_t   ( axi_mst_w_chan_t  ),
    .b_chan_t   ( axi_mst_b_chan_t  ),
    .ar_chan_t  ( axi_mst_ar_chan_t ),
    .r_chan_t   ( axi_mst_r_chan_t  ),
    .axi_req_t  ( axi_mst_req_t ),
    .axi_rsp_t  ( axi_mst_rsp_t )
  ) i_slink_mem (
    .clk_i,
    .rst_ni,
    .axi_req_i  ( slink_axi_slv_req ),
    .axi_rsp_o  ( slink_axi_slv_rsp )
  );

endmodule
