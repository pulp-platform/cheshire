// Copyright 2023 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Nicole Narr <narrn@student.ethz.ch>
// Christopher Reinwardt <creinwar@student.ethz.ch>
// Cyril Koenig <cykoenig@iis.ee.ethz.ch>
// Yann Picod <ypicod@ethz.ch>
// Paul Scheffler <paulsc@iis.ee.ethz.ch>

`include "cheshire/typedef.svh"
`include "phy_definitions.svh"

// TODO: Expose more IO: unused SPI CS, Serial Link, etc.

module cheshire_top_xilinx import cheshire_pkg::*; (
  input  logic  sys_clk_p,
  input  logic  sys_clk_n,

`ifdef USE_RESET
  input  logic  sys_reset,
`endif
`ifdef USE_RESETN
  input  logic  sys_resetn,
`endif

`ifdef USE_SWITCHES
  input logic       test_mode_i,
  input logic [1:0] boot_mode_i,
`endif

`ifdef USE_JTAG
  input  logic  jtag_tck_i,
  input  logic  jtag_tms_i,
  input  logic  jtag_tdi_i,
  output logic  jtag_tdo_o,
`ifdef USE_JTAG_TRSTN
  input  logic  jtag_trst_ni,
`endif
`ifdef USE_JTAG_VDDGND
  output logic  jtag_vdd_o,
  output logic  jtag_gnd_o,
  `endif
`endif

`ifdef USE_I2C
  inout  wire   i2c_scl_io,
  inout  wire   i2c_sda_io,
`endif

`ifdef USE_SD
  input  logic        sd_cd_i,
  output logic        sd_cmd_o,
  inout  wire  [3:0]  sd_d_io,
  output logic        sd_reset_o,
  output logic        sd_sclk_o,
`endif

`ifdef USE_FAN
  input  logic [3:0]  fan_sw,
  output logic        fan_pwm,
`endif

`ifdef USE_VGA
  // VGA Colour signals
  output logic        vga_hsync_o,
  output logic        vga_vsync_o,
  output logic [4:0]  vga_red_o,
  output logic [5:0]  vga_green_o,
  output logic [4:0]  vga_blue_o,
`endif

`ifdef USE_DDR4
  `DDR4_INTF
`endif
`ifdef USE_DDR3
  `DDR3_INTF
`endif

  output logic  uart_tx_o,
  input  logic  uart_rx_i,

  inout  wire [UsbNumPorts-1:0] usb_dm_io,
  inout  wire [UsbNumPorts-1:0] usb_dp_io
);

  ///////////////////////
  //  Cheshire Config  //
  ///////////////////////

  // Use default config as far as possible
  function automatic cheshire_cfg_t gen_cheshire_xilinx_cfg();
    cheshire_cfg_t ret  = DefaultCfg;
    ret.RtcFreq         = 1000000;
    ret.SerialLink      = 0;
  `ifdef USE_USB
    ret.Usb = 1;
  `else
    ret.Usb = 0;
  `endif
    return ret;
  endfunction

  // Configure cheshire for FPGA mapping
  localparam cheshire_cfg_t FPGACfg = gen_cheshire_xilinx_cfg();
  `CHESHIRE_TYPEDEF_ALL(, FPGACfg)

  ////////////////////////
  //  Clock Generation  //
  ////////////////////////

  wire sys_clk;
  wire soc_clk;
  wire usb_clk;

  IBUFDS #(
    .IBUF_LOW_PWR ("FALSE")
  ) i_bufds_sys_clk (
    .I  ( sys_clk_p ),
    .IB ( sys_clk_n ),
    .O  ( sys_clk   )
  );

  clkwiz i_clkwiz (
    .clk_in1  ( sys_clk ),
    .reset    ( '0 ),
    .locked   ( ),
    .clk_50   ( soc_clk ),
    .clk_48   ( usb_clk ),
    .clk_20   ( ),
    .clk_10   ( )
  );

  /////////////////////
  //  System Inputs  //
  /////////////////////

  // Select SoC reset
`ifdef USE_RESET
  logic sys_resetn;
  assign sys_resetn = ~sys_reset;
`elsif USE_RESETN
  logic sys_reset;
  assign sys_reset  = ~sys_resetn;
`endif

  // Tie off inputs of no switches
`ifndef USE_SWITCHES
  logic       test_mode_i;
  logic [1:0] boot_mode_i;
  assign test_mode_i = '0;
  assign boot_mode_i = '0;
`endif

  ////////////
  //  VIOs  //
  ////////////

  logic       vio_reset, vio_boot_mode_sel;
  logic [1:0] boot_mode, vio_boot_mode;
  logic       sys_rst;

`ifdef USE_VIO
  vio i_vio (
    .clk        ( soc_clk ),
    .probe_out0 ( vio_reset         ),
    .probe_out1 ( vio_boot_mode     ),
    .probe_out2 ( vio_boot_mode_sel )
  );
`else
  assign vio_reset          = '0;
  assign vio_boot_mode      = '0;
  assign vio_boot_mode_sel  = '0;
`endif

`ifdef USE_RESET
  assign sys_rst = sys_reset | vio_reset;
`elsif USE_RESETN
  assign sys_rst = ~sys_resetn | vio_reset;
`endif
  assign boot_mode = vio_boot_mode_sel ? vio_boot_mode : boot_mode_i;

  //////////////////
  //  Reset Sync  //
  //////////////////

  wire rst_n;

  rstgen i_rstgen (
    .clk_i        ( soc_clk     ),
    .rst_ni       ( ~sys_rst    ),
    .test_mode_i  ( test_mode_i ),
    .rst_no       ( rst_n       ),
    .init_no      ( )
  );

  ////////////
  //  JTAG  //
  ////////////

`ifdef USE_JTAG_VDDGND
  assign jtag_vdd_o = 1'b1;
  assign jtag_gnd_o = 1'b0;
`endif
`ifndef USE_JTAG_TRSTN
  logic jtag_trst_ni;
  assign jtag_trst_ni = 1'b1;
`endif

  //////////////////
  // I2C Adaption //
  //////////////////

  logic i2c_sda_soc_out;
  logic i2c_sda_soc_in;
  logic i2c_scl_soc_out;
  logic i2c_scl_soc_in;
  logic i2c_sda_en;
  logic i2c_scl_en;

`ifdef USE_I2C
  IOBUF #(
    .DRIVE        ( 12        ),
    .IBUF_LOW_PWR ( "FALSE"   ),
    .IOSTANDARD   ( "DEFAULT" ),
    .SLEW         ( "FAST"    )
  ) i_scl_iobuf (
    .O  ( i2c_scl_soc_in  ),
    .IO ( i2c_scl_io      ),
    .I  ( i2c_scl_soc_out ),
    .T  ( ~i2c_scl_en     )
  );

  IOBUF #(
    .DRIVE        ( 12        ),
    .IBUF_LOW_PWR ( "FALSE"   ),
    .IOSTANDARD   ( "DEFAULT" ),
    .SLEW         ( "FAST"    )
  ) i_sda_iobuf (
    .O  ( i2c_sda_soc_in  ),
    .IO ( i2c_sda_io      ),
    .I  ( i2c_sda_soc_out ),
    .T  ( ~i2c_sda_en     )
  );
`endif

  ///////////////
  // SPI to SD //
  ///////////////

  logic spi_sck_soc;
  logic [1:0] spi_cs_soc;
  logic [3:0] spi_sd_soc_out;
  logic [3:0] spi_sd_soc_in;

  logic spi_sck_en;
  logic [1:0] spi_cs_en;
  logic [3:0] spi_sd_en;

`ifdef USE_SD
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
`endif

  ////////////
  //  QSPI  //
  ////////////

`ifdef USE_QSPI
  logic                 qspi_clk;
  logic                 qspi_clk_ts;
  logic [3:0]           qspi_dqi;
  logic [3:0]           qspi_dqo_ts;
  logic [3:0]           qspi_dqo;
  logic [SpihNumCs-1:0] qspi_cs_b;
  logic [SpihNumCs-1:0] qspi_cs_b_ts;

  assign qspi_clk      = spi_sck_soc;
  assign qspi_cs_b     = spi_cs_soc;
  assign qspi_dqo      = spi_sd_soc_out;
  assign spi_sd_soc_in = qspi_dqi;

  // Tristate enables
  assign qspi_clk_ts  = ~spi_sck_en;
  assign qspi_cs_b_ts = ~spi_cs_en;
  assign qspi_dqo_ts  = ~spi_sd_en;

  // On VCU128/ZCU102, SPI ports are not directly available
`ifdef USE_STARTUPE3
  STARTUPE3 #(
    .PROG_USR("FALSE"),
    .SIM_CCLK_FREQ(0.0)
  ) i_startupe3 (
    .CFGCLK     ( ),
    .CFGMCLK    ( ),
    .DI         ( qspi_dqi ),
    .EOS        ( ),
    .PREQ       ( ),
    .DO         ( qspi_dqo ),
    .DTS        ( qspi_dqo_ts ),
    .FCSBO      ( qspi_cs_b[1] ),
    .FCSBTS     ( qspi_cs_b_ts[1] ),
    .GSR        ( 1'b0 ),
    .GTS        ( 1'b0 ),
    .KEYCLEARB  ( 1'b1 ),
    .PACK       ( 1'b0 ),
    .USRCCLKO   ( qspi_clk ),
    .USRCCLKTS  ( qspi_clk_ts ),
    .USRDONEO   ( 1'b1 ),
    .USRDONETS  ( 1'b1 )
  );
`else
  // TODO: off-chip QSPI interface
`endif
`endif

  ///////////
  //  USB  //
  ///////////

  // SoC IOs
  logic [UsbNumPorts-1:0] usb_dm_i;
  logic [UsbNumPorts-1:0] usb_dm_o;
  logic [UsbNumPorts-1:0] usb_dm_oe_o;
  logic [UsbNumPorts-1:0] usb_dp_i;
  logic [UsbNumPorts-1:0] usb_dp_o;
  logic [UsbNumPorts-1:0] usb_dp_oe_o;

  for (genvar i = 0; i < FPGACfg.Usb*UsbNumPorts; ++i) begin : gen_usb_tristate
    assign usb_dp_io [i] = usb_dp_oe_o[i] ? usb_dp_o[i] : 'z;
    assign usb_dp_i  [i] = usb_dp_io[i];
    assign usb_dm_io [i] = usb_dm_oe_o[i] ? usb_dm_o[i] : 'z;
    assign usb_dm_i  [i] = usb_dm_io[i];
  end

  /////////////////////////
  // "RTC" Clock Divider //
  /////////////////////////

  logic rtc_clk_d, rtc_clk_q;
  logic [15:0] counter_d, counter_q;

  // Divide soc_clk (50 MHz) by 50 => 1 MHz RTC Clock
  always_comb begin
    counter_d = counter_q + 1;
    rtc_clk_d = rtc_clk_q;

    if(counter_q == 24) begin
      counter_d = '0;
      rtc_clk_d = ~rtc_clk_q;
    end
  end

  always_ff @(posedge soc_clk, negedge rst_n) begin
    if(~rst_n) begin
      counter_q <= '0;
      rtc_clk_q <= 0;
    end else begin
      counter_q <= counter_d;
      rtc_clk_q <= rtc_clk_d;
    end
  end

  /////////////////
  // Fan Control //
  /////////////////

`ifdef USE_FAN
  fan_ctrl i_fan_ctrl (
    .clk_i          ( soc_clk ),
    .rst_ni         ( rst_n   ),
    .pwm_setting_i  ( fan_sw  ),
    .fan_pwm_o      ( fan_pwm )
  );
`endif

  //////////////
  // DRAM MIG //
  //////////////

  axi_llc_req_t axi_llc_mst_req;
  axi_llc_rsp_t axi_llc_mst_rsp;

`ifdef USE_DDR
  dram_wrapper_xilinx #(
    .axi_soc_aw_chan_t ( axi_llc_aw_chan_t ),
    .axi_soc_w_chan_t  ( axi_llc_w_chan_t  ),
    .axi_soc_b_chan_t  ( axi_llc_b_chan_t  ),
    .axi_soc_ar_chan_t ( axi_llc_ar_chan_t ),
    .axi_soc_r_chan_t  ( axi_llc_r_chan_t  ),
    .axi_soc_req_t     ( axi_llc_req_t     ),
    .axi_soc_resp_t    ( axi_llc_rsp_t     )
  ) i_dram_wrapper (
    .sys_rst_i    ( sys_rst ),
    .soc_resetn_i ( rst_n   ),
    .soc_clk_i    ( soc_clk ),
    .dram_clk_i   ( sys_clk ),
    .soc_req_i    ( axi_llc_mst_req ),
    .soc_rsp_o    ( axi_llc_mst_rsp ),
    .*
  );
`endif

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
    .reg_ext_rsp_t      ( reg_rsp_t )
  ) i_cheshire_soc (
    .clk_i              ( soc_clk ),
    .rst_ni             ( rst_n   ),
    .test_mode_i        ( test_mode_i ),
    .boot_mode_i        ( boot_mode   ),
    .rtc_i              ( rtc_clk_q       ),
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
    .slink_rcv_clk_i    ( 1'b1 ),
    .slink_rcv_clk_o    ( ),
    .slink_i            ( '0 ),
    .slink_o            ( ),
`ifdef USE_JTAG
    .jtag_tck_i,
    .jtag_trst_ni,
    .jtag_tms_i,
    .jtag_tdi_i,
    .jtag_tdo_o,
    // TODO: connect to the tdo pad
    .jtag_tdo_oe_o      ( ),
`endif
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
`ifdef USE_VGA
    .vga_hsync_o,
    .vga_vsync_o,
    .vga_red_o,
    .vga_green_o,
    .vga_blue_o,
`endif
    .uart_tx_o,
    .uart_rx_i,
    .usb_clk_i          ( usb_clk ),
    .usb_rst_ni         ( rst_n ), // Technically should sync to `usb_clk`, but pulse is long enough
    .usb_dm_i,
    .usb_dm_o,
    .usb_dm_oe_o,
    .usb_dp_i,
    .usb_dp_o,
    .usb_dp_oe_o
  );

endmodule
