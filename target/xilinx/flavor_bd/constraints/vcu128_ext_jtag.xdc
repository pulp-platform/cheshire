set_property PACKAGE_PIN A23     [get_ports jtag_gnd_o] ;# A23 - C15 (FMCP_HSPC_LA10_N) - J1.04 - GND
set_property IOSTANDARD LVCMOS18 [get_ports jtag_gnd_o] ;

set_property PACKAGE_PIN B23     [get_ports jtag_vdd_o] ;# B23 - C14 (FMCP_HSPC_LA10_P) - J1.02 - VDD
set_property IOSTANDARD LVCMOS18 [get_ports jtag_vdd_o] ;

set_property PACKAGE_PIN B25     [get_ports jtag_tdo_o] ;# B25 - H17 (FMCP_HSPC_LA11_N) - J1.08 - TDO
set_property IOSTANDARD LVCMOS18 [get_ports jtag_tdo_o]

set_property PACKAGE_PIN B26     [get_ports jtag_tck_i] ;# B26 - H16 (FMCP_HSPC_LA11_P) - J1.06 - TCK
set_property IOSTANDARD LVCMOS18 [get_ports jtag_tck_i] ;

set_property PACKAGE_PIN H22     [get_ports jtag_tms_i] ;# H22 - G16 (FMCP_HSPC_LA12_N) - J1.12 - TNS
set_property IOSTANDARD LVCMOS18 [get_ports jtag_tms_i] ;

set_property PACKAGE_PIN J22     [get_ports jtag_tdi_i] ;# J22 - G15 (FMCP_HSPC_LA12_P) - J1.10 - TDI
set_property IOSTANDARD LVCMOS18 [get_ports jtag_tdi_i]
