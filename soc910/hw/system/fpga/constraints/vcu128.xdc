## Clock
set_property -dict {PACKAGE_PIN BH51 IOSTANDARD DIFF_SSTL12} [get_ports sys_clk_p]
set_property -dict {PACKAGE_PIN BJ51 IOSTANDARD DIFF_SSTL12} [get_ports sys_clk_n]

## Buttons
set_property -dict {PACKAGE_PIN BM29 IOSTANDARD LVCMOS12} [get_ports cpu_resetn]

## To use FTDI FT2232 JTAG
# set_property -dict { PACKAGE_PIN BN26 IOSTANDARD LVCMOS18 } [get_ports { tck }];
# set_property -dict { PACKAGE_PIN BP26 IOSTANDARD LVCMOS18 } [get_ports { tdi }];
# set_property -dict { PACKAGE_PIN BP22 IOSTANDARD LVCMOS18 } [get_ports { tdo }];
# set_property -dict { PACKAGE_PIN BP23 IOSTANDARD LVCMOS18 } [get_ports { tms }];
set_property -dict { PACKAGE_PIN B23 IOSTANDARD LVCMOS18 } [get_ports { vdd }];
set_property -dict { PACKAGE_PIN A23 IOSTANDARD LVCMOS18 } [get_ports { gnd }];
set_property -dict { PACKAGE_PIN B26 IOSTANDARD LVCMOS18 } [get_ports { tck }];
set_property -dict { PACKAGE_PIN J22 IOSTANDARD LVCMOS18 } [get_ports { tdi }];
set_property -dict { PACKAGE_PIN B25 IOSTANDARD LVCMOS18 } [get_ports { tdo }];
set_property -dict { PACKAGE_PIN H22 IOSTANDARD LVCMOS18 } [get_ports { tms }];

## UART
# set_property -dict {PACKAGE_PIN BJ28 IOSTANDARD LVCMOS18} [get_ports tx]
# set_property -dict {PACKAGE_PIN BK28 IOSTANDARD LVCMOS18} [get_ports rx]
set_property -dict {PACKAGE_PIN BN26 IOSTANDARD LVCMOS18} [get_ports tx]
set_property -dict {PACKAGE_PIN BP26 IOSTANDARD LVCMOS18} [get_ports rx]

## JTAG
# minimize routing delay

set_max_delay -to   [get_ports { tdo } ] 20
set_max_delay -from [get_ports { tms } ] 20
set_max_delay -from [get_ports { tdi } ] 20
# set_max_delay -from [get_ports { trst_n } ] 20

# reset signal
# set_false_path -from [get_ports { trst_n } ]
# set_false_path -from [get_pins i_ddr/u_xlnx_mig_7_ddr3_mig/u_ddr3_infrastructure/rstdiv0_sync_r1_reg_rep/C]
