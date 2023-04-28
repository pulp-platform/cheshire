// Copyright 2022 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Nicole Narr <narrn@student.ethz.ch>
// Christopher Reinwardt <creinwar@student.ethz.ch>

`include "phy_definitions.svh"

module tb_cheshire_top_xilinx 
  import cheshire_pkg::*;
(
);
  reg           sys_clk;

  reg           cpu_reset;
  wire          cpu_resetn;

  logic         uart_tx_o;
  logic         uart_rx_i;

`ifdef USE_SWITCHES
  logic         testmode_i;
  logic [1:0]   boot_mode_i;
`endif

`ifdef USE_JTAG
  logic         jtag_tck_i;
  logic         jtag_tms_i;
  logic         jtag_tdi_i;
  logic         jtag_tdo_o;
`ifdef USE_JTAG_TRSTN
  logic         jtag_trst_ni;
`endif
`ifdef USE_JTAG_VDDGND
  logic         jtag_vdd_o;
  logic         jtag_gnd_o;
`endif
`endif

`ifdef USE_I2C
  logic         i2c_scl_io;
  logic         i2c_sda_io;
`endif

`ifdef USE_SD
  logic         sd_cd_i;
  logic         U46;
  wire  [3:0]   sd_d_io;
  logic         sd_reset_o;
  logic         sd_sclk_o;
`endif

`ifdef USE_FAN
  logic [3:0]   fan_sw;
  logic         fan_pwm;
`endif

`ifdef USE_QSPI
  logic        qspi_clk;
  logic        qspi_dq0;
  logic        qspi_dq1;
  logic        qspi_dq2;
  logic        qspi_dq3;
  logic        qspi_cs_b;
`endif

`ifdef USE_VGA
  logic [4:0]  vga_b;
  logic [5:0]  vga_g;
  logic [4:0]  vga_r;
  logic        vga_hs;
  logic        vga_vs;
`endif

`ifdef USE_SERIAL
  logic [4:0]  ddr_link_o;
  logic        ddr_link_clk_o;
`endif

  // Phy interface for DDR4
`ifdef USE_DDR4
  wire                c0_sys_clk_p;
  wire                c0_sys_clk_n;
  wire                c0_ddr4_act_n;
  wire [16:0]         c0_ddr4_adr;
  wire [1:0]          c0_ddr4_ba;
  wire [0:0]          c0_ddr4_bg;
  wire [0:0]          c0_ddr4_cke;
  wire [0:0]          c0_ddr4_odt;
  wire [1:0]          c0_ddr4_cs_n;
  wire [0:0]          c0_ddr4_ck_t;
  wire [0:0]          c0_ddr4_ck_c;
  wire                c0_ddr4_reset_n;
  wire [8:0]          c0_ddr4_dm_dbi_n;
  wire [71:0]         c0_ddr4_dq;
  wire [8:0]          c0_ddr4_dqs_c;
  wire [8:0]          c0_ddr4_dqs_t;
`endif

  initial begin
    cpu_reset = 1'b0;
    #200
    cpu_reset = 1'b1;
    #200;
    cpu_reset = 1'b0;
    #100;
  end

  initial
    sys_clk = 1'b0;
  always
    sys_clk = #(13501/2.0) ~sys_clk;

  cheshire_top_xilinx DUT
  (
    .*
  );

`ifdef USE_DDR4
  assign c0_sys_clk_p = sys_clk;
  assign c0_sys_clk_n = ~sys_clk;
`endif

  `ifdef USE_JTAG
  assign jtag_tck_i = '0;
  assign jtag_tms_i = '0;
  assign jtag_tdi_i = '0;
  `endif

  assign uart_rx_i  = '1;

endmodule
