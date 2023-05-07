// Copyright 2022 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Nicole Narr <narrn@student.ethz.ch>
// Christopher Reinwardt <creinwar@student.ethz.ch>

`include "cheshire/typedef.svh"

module cheshire_top_xilinx
  import cheshire_pkg::*;
(
  input logic         sysclk_p,
  input logic         sysclk_n,
  input logic         cpu_resetn,

  input logic         test_mode_i,

  input logic [1:0]   boot_mode_i,

  output logic        uart_tx_o,
  input logic         uart_rx_i,

  input logic         jtag_tck_i,
  input logic         jtag_trst_ni,
  input logic         jtag_tms_i,
  input logic         jtag_tdi_i,
  output logic        jtag_tdo_o,

  inout wire          i2c_scl_io,
  inout wire          i2c_sda_io,

  input logic         sd_cd_i,
  output logic        sd_cmd_o,
  inout wire  [3:0]   sd_d_io,
  output logic        sd_reset_o,
  output logic        sd_sclk_o,

  input logic [3:0]   fan_sw,
  output logic        fan_pwm,

  // DDR3 DRAM interface
  output wire [14:0]  ddr3_addr,
  output wire [2:0]   ddr3_ba,
  output wire         ddr3_cas_n,
  output wire [0:0]   ddr3_ck_n,
  output wire [0:0]   ddr3_ck_p,
  output wire [0:0]   ddr3_cke,
  output wire [0:0]   ddr3_cs_n,
  output wire [3:0]   ddr3_dm,
  inout wire  [31:0]  ddr3_dq,
  inout wire  [3:0]   ddr3_dqs_n,
  inout wire  [3:0]   ddr3_dqs_p,
  output wire [0:0]   ddr3_odt,
  output wire         ddr3_ras_n,
  output wire         ddr3_reset_n,
  output wire         ddr3_we_n,

  // VGA Colour signals
  output logic [4:0]  vga_b,
  output logic [5:0]  vga_g,
  output logic [4:0]  vga_r,

  // VGA Sync signals
  output logic        vga_hs,
  output logic        vga_vs
);

  // Configure cheshire for FPGA mapping
  localparam cheshire_cfg_t FPGACfg = '{
    // CVA6 parameters
    Cva6RASDepth      : ariane_pkg::ArianeDefaultConfig.RASDepth,
    Cva6BTBEntries    : ariane_pkg::ArianeDefaultConfig.BTBEntries,
    Cva6BHTEntries    : ariane_pkg::ArianeDefaultConfig.BHTEntries,
    Cva6CLICNumInterruptSrc : ariane_pkg::ArianeDefaultConfig.CLICNumInterruptSrc,
    Cva6CLICIntCtlBits      : ariane_pkg::ArianeDefaultConfig.CLICIntCtlBits,
    Cva6NrPMPEntries  : 0,
    Cva6ExtCieLength  : 'h2000_0000,
    // Harts
    DualCore          : 0,  // Only one core, but rest of config allows for two
    CoreMaxTxns       : 8,
    CoreMaxTxnsPerId  : 4,
    // Interconnect
    AddrWidth         : 48,
    AxiDataWidth      : 64,
    AxiUserWidth      : 2,  // Convention: bit 0 for core(s), bit 1 for serial link
    AxiMstIdWidth     : 2,
    AxiMaxMstTrans    : 8,
    AxiMaxSlvTrans    : 8,
    AxiUserAmoMsb     : 1,
    AxiUserAmoLsb     : 0,
    RegMaxReadTxns    : 8,
    RegMaxWriteTxns   : 8,
    RegAmoNumCuts     : 1,
    RegAmoPostCut     : 1,
    // RTC
    RtcFreq           : 1000000,
    // Features
    Bootrom           : 1,
    Uart              : 1,
    I2c               : 1,
    SpiHost           : 1,
    Gpio              : 1,
    Dma               : 1,
    SerialLink        : 0,
    Vga               : 1,
    // Debug
    DbgIdCode         : CheshireIdCode,
    DbgMaxReqs        : 4,
    DbgMaxReadTxns    : 4,
    DbgMaxWriteTxns   : 4,
    DbgAmoNumCuts     : 1,
    DbgAmoPostCut     : 1,
    // LLC: 128 KiB, up to 2 GiB DRAM
    LlcNotBypass      : 1,
    LlcSetAssoc       : 8,
    LlcNumLines       : 256,
    LlcNumBlocks      : 8,
    LlcMaxReadTxns    : 8,
    LlcMaxWriteTxns   : 8,
    LlcAmoNumCuts     : 1,
    LlcAmoPostCut     : 1,
    LlcOutConnect     : 1,
    LlcOutRegionStart : 'h8000_0000,
    LlcOutRegionEnd   : 'h1_0000_0000,
    // VGA: RGB332
    VgaRedWidth       : 5,
    VgaGreenWidth     : 6,
    VgaBlueWidth      : 5,
    VgaHCountWidth    : 24, // TODO: Default is 32; is this needed?
    VgaVCountWidth    : 24, // TODO: See above
    // Serial Link: map other chip's lower 32bit to 'h1_000_0000
    SlinkMaxTxnsPerId : 4,
    SlinkMaxUniqIds   : 4,
    SlinkMaxClkDiv    : 1024,
    SlinkRegionStart  : 'h1_0000_0000,
    SlinkRegionEnd    : 'h2_0000_0000,
    SlinkTxAddrMask   : 'hFFFF_FFFF,
    SlinkTxAddrDomain : 'h0000_0000,
    SlinkUserAmoBit   : 1,  // Upper atomics bit for serial link
    // DMA config
    DmaConfMaxReadTxns  : 4,
    DmaConfMaxWriteTxns : 4,
    DmaConfAmoNumCuts   : 1,
    DmaConfAmoPostCut   : 1,
    // GPIOs
    GpioInputSyncs    : 1,
    // All non-set values should be zero
    default: '0
  };

  localparam cheshire_cfg_t CheshireFPGACfg = FPGACfg;
  `CHESHIRE_TYPEDEF_ALL(, CheshireFPGACfg)

  axi_llc_req_t axi_llc_mst_req, dram_req, dram_req_cdc;
  axi_llc_rsp_t axi_llc_mst_rsp, dram_resp, dram_resp_cdc;

  wire dram_clock_out;
  wire dram_sync_reset;
  wire soc_clk;

  logic rst_n;

  // Statically assign the response user signals
  // B Channel user
  assign dram_resp.b.user      = '0;

  // R Channel user
  assign dram_resp.r.user      = '0;

  ///////////////////
  // Clock Divider //
  ///////////////////

  clk_int_div #(
    .DIV_VALUE_WIDTH          ( 4             ),
    .DEFAULT_DIV_VALUE        ( 4'h4          ),
    .ENABLE_CLOCK_IN_RESET    ( 1'b0          )
  ) i_sys_clk_div (
    .clk_i                ( dram_clock_out    ),
    .rst_ni               ( ~dram_sync_reset  ),
    .en_i                 ( 1'b1              ),
    .test_mode_en_i       ( testmode_i        ),
    .div_i                ( 4'h4              ),
    .div_valid_i          ( 1'b0              ),
    .div_ready_o          (                   ),
    .clk_o                ( soc_clk           ),
    .cycl_count_o         (                   )
  );

  /////////////////////
  // Reset Generator //
  /////////////////////

  rstgen i_rstgen_main (
    .clk_i        ( soc_clk                  ),
    .rst_ni       ( ~dram_sync_reset         ),
    .test_mode_i  ( test_en                  ),
    .rst_no       ( rst_n                    ),
    .init_no      (                          ) // keep open
  );


  ///////////////////////////////////////////
  // AXI Clock Domain Crossing SoC -> DRAM //
  ///////////////////////////////////////////

  axi_cdc #(
    .aw_chan_t  ( axi_llc_aw_chan_t ),
    .w_chan_t   ( axi_llc_w_chan_t  ),
    .b_chan_t   ( axi_llc_b_chan_t  ),
    .ar_chan_t  ( axi_llc_ar_chan_t ),
    .r_chan_t   ( axi_llc_r_chan_t  ),
    .axi_req_t  ( axi_llc_req_t     ),
    .axi_resp_t ( axi_llc_rsp_t     ),
    .LogDepth   ( 1                                   )
  ) i_axi_cdc_mig (
    .src_clk_i    ( soc_clk           ),
    .src_rst_ni   ( rst_n             ),
    .src_req_i    ( axi_llc_mst_req   ),
    .src_resp_o   ( axi_llc_mst_rsp   ),
    .dst_clk_i    ( dram_clock_out    ),
    .dst_rst_ni   ( rst_n             ),
    .dst_req_o    ( dram_req_cdc      ),
    .dst_resp_i   ( dram_resp_cdc     )
  );

  // AXI CUT (spill register) between the AXI CDC and the MIG to
  // reduce timing pressure
  axi_cut #(
    .Bypass     ( 1'b0  ),
    .aw_chan_t  ( axi_llc_aw_chan_t  ),
    .w_chan_t   ( axi_llc_w_chan_t   ),
    .b_chan_t   ( axi_llc_b_chan_t   ),
    .ar_chan_t  ( axi_llc_ar_chan_t  ),
    .r_chan_t   ( axi_llc_r_chan_t   ),
    .axi_req_t  ( axi_llc_req_t      ),
    .axi_resp_t ( axi_llc_rsp_t      )
  ) i_axi_cut_soc_dram (
    .clk_i      ( dram_clock_out  ),
    .rst_ni     ( rst_n           ),

    .slv_req_i  ( dram_req_cdc    ),
    .slv_resp_o ( dram_resp_cdc   ),

    .mst_req_o  ( dram_req        ),
    .mst_resp_i ( dram_resp       )
  );

  //////////////
  // DRAM MIG //
  //////////////

  xlnx_mig_7_ddr3 i_dram (
    .sys_clk_p       ( sysclk_p               ),
    .sys_clk_n       ( sysclk_n               ),
    .ddr3_dq,
    .ddr3_dqs_n,
    .ddr3_dqs_p,
    .ddr3_addr,
    .ddr3_ba,
    .ddr3_ras_n,
    .ddr3_cas_n,
    .ddr3_we_n,
    .ddr3_reset_n,
    .ddr3_ck_p,
    .ddr3_ck_n,
    .ddr3_cke,
    .ddr3_cs_n,
    .ddr3_dm,
    .ddr3_odt,
    .mmcm_locked     (                        ), // keep open
    .app_sr_req      ( '0                     ),
    .app_ref_req     ( '0                     ),
    .app_zq_req      ( '0                     ),
    .app_sr_active   (                        ), // keep open
    .app_ref_ack     (                        ), // keep open
    .app_zq_ack      (                        ), // keep open
    .ui_clk          ( dram_clock_out         ),
    .ui_clk_sync_rst ( dram_sync_reset        ),
    .aresetn         ( rst_n                  ),
    .s_axi_awid      ( dram_req.aw.id         ),
    .s_axi_awaddr    ( dram_req.aw.addr[29:0] ),
    .s_axi_awlen     ( dram_req.aw.len        ),
    .s_axi_awsize    ( dram_req.aw.size       ),
    .s_axi_awburst   ( dram_req.aw.burst      ),
    .s_axi_awlock    ( dram_req.aw.lock       ),
    .s_axi_awcache   ( dram_req.aw.cache      ),
    .s_axi_awprot    ( dram_req.aw.prot       ),
    .s_axi_awqos     ( dram_req.aw.qos        ),
    .s_axi_awvalid   ( dram_req.aw_valid      ),
    .s_axi_awready   ( dram_resp.aw_ready     ),
    .s_axi_wdata     ( dram_req.w.data        ),
    .s_axi_wstrb     ( dram_req.w.strb        ),
    .s_axi_wlast     ( dram_req.w.last        ),
    .s_axi_wvalid    ( dram_req.w_valid       ),
    .s_axi_wready    ( dram_resp.w_ready      ),
    .s_axi_bready    ( dram_req.b_ready       ),
    .s_axi_bid       ( dram_resp.b.id         ),
    .s_axi_bresp     ( dram_resp.b.resp       ),
    .s_axi_bvalid    ( dram_resp.b_valid      ),
    .s_axi_arid      ( dram_req.ar.id         ),
    .s_axi_araddr    ( dram_req.ar.addr[29:0] ),
    .s_axi_arlen     ( dram_req.ar.len        ),
    .s_axi_arsize    ( dram_req.ar.size       ),
    .s_axi_arburst   ( dram_req.ar.burst      ),
    .s_axi_arlock    ( dram_req.ar.lock       ),
    .s_axi_arcache   ( dram_req.ar.cache      ),
    .s_axi_arprot    ( dram_req.ar.prot       ),
    .s_axi_arqos     ( dram_req.ar.qos        ),
    .s_axi_arvalid   ( dram_req.ar_valid      ),
    .s_axi_arready   ( dram_resp.ar_ready     ),
    .s_axi_rready    ( dram_req.r_ready       ),
    .s_axi_rid       ( dram_resp.r.id         ),
    .s_axi_rdata     ( dram_resp.r.data       ),
    .s_axi_rresp     ( dram_resp.r.resp       ),
    .s_axi_rlast     ( dram_resp.r.last       ),
    .s_axi_rvalid    ( dram_resp.r_valid      ),
    .init_calib_complete (                    ), // keep open
    .device_temp         (                    ), // keep open
    .sys_rst             ( cpu_resetn         )
  );


  //////////////////
  // I2C Adaption //
  //////////////////

  logic i2c_sda_soc_out;
  logic i2c_sda_soc_in;
  logic i2c_scl_soc_out;
  logic i2c_scl_soc_in;
  logic i2c_sda_en;
  logic i2c_scl_en;

  // Three state buffer for SCL
  IOBUF #(
    .DRIVE        ( 12        ),
    .IBUF_LOW_PWR ( "FALSE"   ),
    .IOSTANDARD   ( "DEFAULT" ),
    .SLEW         ( "FAST"    )
  ) i_scl_iobuf (
    .O  ( i2c_scl_soc_in      ),
    .IO ( i2c_scl_io          ),
    .I  ( i2c_scl_soc_out     ),
    .T  ( ~i2c_scl_en         )
  );

  // Three state buffer for SDA
  IOBUF #(
    .DRIVE        ( 12        ),
    .IBUF_LOW_PWR ( "FALSE"   ),
    .IOSTANDARD   ( "DEFAULT" ),
    .SLEW         ( "FAST"    )
  ) i_sda_iobuf (
    .O  ( i2c_sda_soc_in      ),
    .IO ( i2c_sda_io          ),
    .I  ( i2c_sda_soc_out     ),
    .T  ( ~i2c_sda_en         )
  );


  //////////////////
  // SPI Adaption //
  //////////////////

  logic spi_sck_soc;
  logic [1:0] spi_cs_soc;
  logic [3:0] spi_sd_soc_out;
  logic [3:0] spi_sd_soc_in;

  logic spi_sck_en;
  logic [1:0] spi_cs_en;
  logic [3:0] spi_sd_en;

  // Assert reset low => Apply power to the SD Card
  assign sd_reset_o       = 1'b0;

  // SCK  - SD CLK signal
  assign sd_sclk_o        = spi_sck_en    ? spi_sck_soc       : 1'b1;

  // CS   - SD DAT3 signal
  assign sd_d_io[3]       = spi_cs_en[0]  ? spi_cs_soc[0]     : 1'b1;

  // MOSI - SD CMD signal
  assign sd_cmd_o         = spi_sd_en[0]  ? spi_sd_soc_out[0] : 1'b1;

  // MISO - SD DAT0 signal
  assign spi_sd_soc_in[1] = sd_d_io[0];

  // SD DAT1 and DAT2 signal tie-off - Not used for SPI mode
  assign sd_d_io[2:1]     = 2'b11;

  // Bind input side of SoC low for output signals
  assign spi_sd_soc_in[0] = 1'b0;
  assign spi_sd_soc_in[2] = 1'b0;
  assign spi_sd_soc_in[3] = 1'b0;


  /////////////////////////
  // "RTC" Clock Divider //
  /////////////////////////

  logic rtc_clk_d, rtc_clk_q;
  logic [4:0] counter_d, counter_q;

  // Divide soc_clk (50 MHz) by 50 => 1 MHz RTC Clock
  always_comb begin
    counter_d = counter_q + 1;
    rtc_clk_d = rtc_clk_q;

    if(counter_q == 24) begin
      counter_d = 5'b0;
      rtc_clk_d = ~rtc_clk_q;
    end
  end

  always_ff @(posedge soc_clk, negedge rst_n) begin
    if(~rst_n) begin
      counter_q <= 5'b0;
      rtc_clk_q <= 0;
    end else begin
      counter_q <= counter_d;
      rtc_clk_q <= rtc_clk_d;
    end
  end


  /////////////////
  // Fan Control //
  /////////////////

  fan_ctrl i_fan_ctrl (
    .clk_i         ( soc_clk    ),
    .rst_ni        ( rst_n      ),
    .pwm_setting_i ( fan_sw     ),
    .fan_pwm_o     ( fan_pwm    )
  );


  ////////////////////////
  // Regbus Error Slave //
  ////////////////////////

  reg_req_t ext_req;
  reg_rsp_t ext_rsp;

  reg_err_slv #(
    .DW       ( 32                 ),
    .ERR_VAL  ( 32'hBADCAB1E       ),
    .req_t    ( reg_req_t  ),
    .rsp_t    ( reg_rsp_t  )
  ) i_reg_err_slv_ext (
    .req_i ( ext_req  ),
    .rsp_o ( ext_rsp  )
  );


  //////////////////
  // Cheshire SoC //
  //////////////////

  cheshire_soc #(
    .Cfg                ( FPGACfg ),
    .ExtHartinfo        ( '0 ),
    .axi_ext_llc_req_t  ( axi_llc_req_t ),
    .axi_ext_llc_rsp_t  ( axi_llc_rsp_t ),
    .axi_ext_mst_req_t  ( axi_mst_req_t ),
    .axi_ext_mst_rsp_t  ( axi_mst_rsp_t ),
    .axi_ext_slv_req_t  ( axi_slv_req_t ),
    .axi_ext_slv_rsp_t  ( axi_slv_rsp_t ),
    .reg_ext_req_t      ( reg_req_t ),
    .reg_ext_rsp_t      ( reg_req_t )
  ) i_cheshire_soc (
    .clk_i              ( soc_clk ),
    .rst_ni             ( rst_n   ),
    .test_mode_i,
    .boot_mode_i,
    .rtc_i              ( rtc_clk_q             ),
    .axi_llc_mst_req_o  ( axi_llc_mst_req ),
    .axi_llc_mst_rsp_i  ( axi_llc_mst_rsp ),
    .axi_ext_mst_req_i  ( '0 ),
    .axi_ext_mst_rsp_o  ( ),
    .axi_ext_slv_req_o  ( ),
    .axi_ext_slv_rsp_i  ( '0 ),
    .reg_ext_slv_req_o  ( ),
    .reg_ext_slv_rsp_i  ( '0 ),
    .intr_ext_i         ( '0 ),
    .meip_ext_o         ( ),
    .seip_ext_o         ( ),
    .mtip_ext_o         ( ),
    .msip_ext_o         ( ),
    .intr_distributed_o ( ),
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
    .i2c_sda_o          ( i2c_sda_soc_out ),
    .i2c_sda_i          ( i2c_sda_soc_in  ),
    .i2c_sda_en_o       ( i2c_sda_en      ),
    .i2c_scl_o          ( i2c_scl_soc_out ),
    .i2c_scl_i          ( i2c_scl_soc_in  ),
    .i2c_scl_en_o       ( i2c_scl_en      ),
    .spih_sck_o         ( spi_sck_soc     ),
    .spih_sck_en_o      ( spi_sck_en      ),
    .spih_csb_o         ( spi_cs_soc      ),
    .spih_csb_en_o      ( spi_cs_en       ),
    .spih_sd_o          ( spi_sd_soc_out  ),
    .spih_sd_en_o       ( spi_sd_en       ),
    .spih_sd_i          ( spi_sd_soc_in   ),
    .gpio_i             ( '0 ),
    .gpio_o             ( ),
    .gpio_en_o          ( ),
    .slink_rcv_clk_i    ( '1 ),
    .slink_rcv_clk_o    ( ),
    .slink_i            ( '0 ),
    .slink_o            ( ),
    .vga_hsync_o        ( vga_hs          ),
    .vga_vsync_o        ( vga_vs          ),
    .vga_red_o          ( vga_r           ),
    .vga_green_o        ( vga_g           ),
    .vga_blue_o         ( vga_b           )
  );

endmodule
