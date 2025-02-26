// Copyright 2025 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Authors:
// Philippe Sauter <phsauter@iis.ee.ethz.ch>

package cheshire_synth_wrapper_pkg;
  `include "cheshire/typedef.svh"

  import cheshire_pkg::*;

  // generate the cheshire configuration used here
  function automatic cheshire_cfg_t gen_cheshire_cfg();
    cheshire_cfg_t ret = DefaultCfg;
    // here you would modify the struct to change your configuration
    return ret;
  endfunction
  localparam cheshire_cfg_t Cfg = gen_cheshire_cfg();

  `CHESHIRE_TYPEDEF_ALL(, Cfg)
endpackage


module cheshire_synth_wrapper import cheshire_synth_wrapper_pkg::*; import cheshire_pkg::*; #(
  parameter type axi_ext_llc_req_t  = axi_llc_req_t,
  parameter type axi_ext_llc_rsp_t  = axi_llc_rsp_t,
  parameter type axi_ext_mst_req_t  = axi_mst_req_t,
  parameter type axi_ext_mst_rsp_t  = axi_mst_rsp_t,
  parameter type axi_ext_slv_req_t  = axi_slv_req_t,
  parameter type axi_ext_slv_rsp_t  = axi_slv_rsp_t,
  parameter type reg_ext_req_t      = reg_req_t,
  parameter type reg_ext_rsp_t      = reg_rsp_t
) (
  input  logic        clk_i,
  input  logic        rst_ni,
  input  logic        test_mode_i,
  input  logic [1:0]  boot_mode_i,
  input  logic        rtc_i,
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
  // GPIO interface
  input  logic [31:0] gpio_i,
  output logic [31:0] gpio_o,
  output logic [31:0] gpio_en_o,
  // SPI host interface
  output logic                  spih_sck_o,
  output logic                  spih_sck_en_o,
  output logic [SpihNumCs-1:0]  spih_csb_o,
  output logic [SpihNumCs-1:0]  spih_csb_en_o,
  output logic [ 3:0]           spih_sd_o,
  output logic [ 3:0]           spih_sd_en_o,
  input  logic [ 3:0]           spih_sd_i,
  // USB interface
  input  logic                   usb_clk_i,
  input  logic                   usb_rst_ni,
  input  logic [UsbNumPorts-1:0] usb_dm_i,
  output logic [UsbNumPorts-1:0] usb_dm_o,
  output logic [UsbNumPorts-1:0] usb_dm_oe_o,
  input  logic [UsbNumPorts-1:0] usb_dp_i,
  output logic [UsbNumPorts-1:0] usb_dp_o,
  output logic [UsbNumPorts-1:0] usb_dp_oe_o,
  // VGA interface
  output logic                         vga_hsync_o,
  output logic                         vga_vsync_o,
  output logic [Cfg.VgaRedWidth  -1:0] vga_red_o,
  output logic [Cfg.VgaGreenWidth-1:0] vga_green_o,
  output logic [Cfg.VgaBlueWidth -1:0] vga_blue_o,
  // Serial link interface
  input  logic [SlinkNumChan-1:0]                    slink_rcv_clk_i,
  output logic [SlinkNumChan-1:0]                    slink_rcv_clk_o,
  input  logic [SlinkNumChan-1:0][SlinkNumLanes-1:0] slink_i,
  output logic [SlinkNumChan-1:0][SlinkNumLanes-1:0] slink_o,
  // External AXI LLC (DRAM) port
  output axi_ext_llc_req_t axi_llc_mst_req_o,
  input  axi_ext_llc_rsp_t axi_llc_mst_rsp_i,
  // External AXI crossbar ports
  input  axi_ext_mst_req_t [iomsb(Cfg.AxiExtNumMst):0] axi_ext_mst_req_i,
  output axi_ext_mst_rsp_t [iomsb(Cfg.AxiExtNumMst):0] axi_ext_mst_rsp_o,
  output axi_ext_slv_req_t [iomsb(Cfg.AxiExtNumSlv):0] axi_ext_slv_req_o,
  input  axi_ext_slv_rsp_t [iomsb(Cfg.AxiExtNumSlv):0] axi_ext_slv_rsp_i,
  // External reg demux slaves
  output reg_ext_req_t [iomsb(Cfg.RegExtNumSlv):0] reg_ext_slv_req_o,
  input  reg_ext_rsp_t [iomsb(Cfg.RegExtNumSlv):0] reg_ext_slv_rsp_i,
  // Interrupts from and to external targets
  input  logic [iomsb(Cfg.NumExtInIntrs):0]                                  intr_ext_i,
  output logic [iomsb(Cfg.NumExtOutIntrTgts):0][iomsb(Cfg.NumExtOutIntrs):0] intr_ext_o,
  // Interrupt requests to external harts
  output logic [iomsb(NumIrqCtxts*Cfg.NumExtIrqHarts):0] xeip_ext_o,
  output logic [iomsb(Cfg.NumExtIrqHarts):0]             mtip_ext_o,
  output logic [iomsb(Cfg.NumExtIrqHarts):0]             msip_ext_o,
  // Debug interface to external harts
  output logic                               dbg_active_o,
  output logic [iomsb(Cfg.NumExtDbgHarts):0] dbg_ext_req_o,
  input  logic [iomsb(Cfg.NumExtDbgHarts):0] dbg_ext_unavail_i
);

  cheshire_soc #(
    .Cfg                ( Cfg ),
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
    .*
  );

endmodule
