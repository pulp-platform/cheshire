// Copyright 2023 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Cyril Koenig <cykoenig@iis.ee.ethz.ch>

`ifdef TARGET_VCU128
  `define USE_RESET
  `define USE_JTAG
  `define USE_JTAG_VDDGND
  `define USE_VIO
  `define USE_DDR4
  // DRAM runs at 200MHz
  `define DDR_CLK_DIVIDER 4'h4
`endif

`ifdef TARGET_GENESYS2
  `define USE_RESETN
  `define USE_JTAG
  `define USE_JTAG_TRSTN
  `define USE_SD
  `define USE_SWITCHES
  `define USE_DDR3
  // DRAM runs at 200MHz
  `define DDR_CLK_DIVIDER 4'h4
  `define USE_FAN
`endif

`ifdef TARGET_ZCU102
  `define USE_RESET
  `define USE_JTAG
  `define USE_DDR4
  // DRAM runs at 100MHz
  `define DDR_CLK_DIVIDER 4'h2
`endif

`define DDR4_INTF \
`ifdef TARGET_VCU128 \
  /* Diff clock */ \
  input                c0_sys_clk_p, \
  input                c0_sys_clk_n, \
  /* DDR4 intf */ \
  output               c0_ddr4_act_n, \
  output [16:0]        c0_ddr4_adr, \
  output [1:0]         c0_ddr4_ba, \
  output [0:0]         c0_ddr4_bg, \
  output [0:0]         c0_ddr4_cke, \
  output [0:0]         c0_ddr4_odt, \
  output [1:0]         c0_ddr4_cs_n, \
  output [0:0]         c0_ddr4_ck_t, \
  output [0:0]         c0_ddr4_ck_c, \
  output               c0_ddr4_reset_n, \
  inout  [8:0]         c0_ddr4_dm_dbi_n, \
  inout  [71:0]        c0_ddr4_dq, \
  inout  [8:0]         c0_ddr4_dqs_c, \
  inout  [8:0]         c0_ddr4_dqs_t, \
`endif \
`ifdef TARGET_ZCU102 \
  /* Diff clock */ \
  input                c0_sys_clk_p, \
  input                c0_sys_clk_n, \
  /* DDR4 intf */ \
  output               c0_ddr4_act_n, \
  output [16:0]        c0_ddr4_adr, \
  output [1:0]         c0_ddr4_ba, \
  output [0:0]         c0_ddr4_bg, \
  output [0:0]         c0_ddr4_cke, \
  output [0:0]         c0_ddr4_odt, \
  output [0:0]         c0_ddr4_cs_n, \
  output [0:0]         c0_ddr4_ck_t, \
  output [0:0]         c0_ddr4_ck_c, \
  output               c0_ddr4_reset_n, \
  inout  [1:0]         c0_ddr4_dm_dbi_n, \
  inout  [15:0]        c0_ddr4_dq, \
  inout  [1:0]         c0_ddr4_dqs_c, \
  inout  [1:0]         c0_ddr4_dqs_t, \
`endif

`define DDR3_INTF \
  inout [31:0] ddr3_dq, \
  inout [3:0] ddr3_dqs_n, \
  inout [3:0] ddr3_dqs_p, \
  output [14:0] ddr3_addr, \
  output [2:0] ddr3_ba, \
  output ddr3_ras_n, \
  output ddr3_cas_n, \
  output ddr3_we_n, \
  output ddr3_reset_n, \
  output [0:0] ddr3_ck_p, \
  output [0:0] ddr3_ck_n, \
  output [0:0] ddr3_cke, \
  output [0:0] ddr3_cs_n, \
  output [3:0] ddr3_dm, \
  output [0:0] ddr3_odt, \
  input sys_clk_p, \
  input sys_clk_n,

`define ila(__name, __signal)  \
  (* dont_touch = "yes" *) (* mark_debug = "true" *) logic [$bits(__signal)-1:0] __name; \
  assign __name = __signal;
