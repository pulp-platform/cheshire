`ifdef TARGET_VCU128
`define USE_UART
`define USE_DDR4
`define USE_JTAG
`define USE_JTAG_VDDGND
// DRAM runs at 200MHz
`define DDR_CLK_DIVIDER 4'h4
`endif

`ifdef TARGET_GENESYS2
`define USE_FAN
`define USE_JTAG
`define USE_JTAG_TRSTN
`define USE_DDR3
// DRAM runs at 200MHz
`define DDR_CLK_DIVIDER 4'h4
`endif

`define DDR4_INTF \
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
inout  [8:0]         c0_ddr4_dqs_t

/*
`define DDR3_INTF \
ddr3_ras_n, \
ddr3_addr, \
ddr3_ba, \
ddr3_we_n, \
ddr3_cke, \
ddr3_odt,
ddr3_cas_n, \
ddr3_ck_p, \
ddr3_ck_n, \
ddr3_reset_n, \
ddr3_cs_n, \
ddr3_dm, \
ddr3_dq, \
ddr3_dqs_n, \
ddr3_dqs_p
*/