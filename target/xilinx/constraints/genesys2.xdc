# Copyright 2022 ETH Zurich and University of Bologna.
# Solderpad Hardware License, Version 0.51, see LICENSE for details.
# SPDX-License-Identifier: SHL-0.51
#
# Nicole Narr <narrn@student.ethz.ch>
# Christopher Reinwardt <creinwar@student.ethz.ch>
# Cyril Koenig <cykoenig@iis.ee.ethz.ch>
# Paul Scheffler <paulsc@iis.ee.ethz.ch>

#############
# Sys Clock #
#############

# 200 MHz input clock
set SYS_TCK 5
create_clock -period $SYS_TCK -name sys_clk [get_ports sys_clk_p]

# SoC clock is generated by clock wizard and its constraints
set SOC_TCK 20.0
set soc_clk [get_clocks -of_objects [get_pins i_clkwiz/clk_50]]

############
# Switches #
############

# Testmode is set to 0 during normal use
set_case_analysis 0 [get_ports test_mode_i]

set_input_delay -min -clock $soc_clk [expr { $SOC_TCK * 0.10 }] [ \
    get_ports {boot_mode* fan_sw* test_mode_i}]
set_input_delay -max -clock $soc_clk [expr { $SOC_TCK * 0.35 }] [ \
    get_ports {boot_mode* fan_sw* test_mode_i}]

set_output_delay -min -clock $soc_clk [expr { $SOC_TCK * 0.10 }] [get_ports fan_pwm]
set_output_delay -max -clock $soc_clk [expr { $SOC_TCK * 0.35 }] [get_ports fan_pwm]

set_max_delay [expr { 2 * $SOC_TCK }] -from [get_ports {boot_mode* fan_sw* test_mode_i}]
set_false_path -hold -from [get_ports {boot_mode* fan_sw* test_mode_i}]

set_max_delay [expr { 2 * $SOC_TCK }] -to [get_ports fan_pwm]
set_false_path -hold -to [get_ports fan_pwm]

#######
# MIG #
#######

# Dram axi clock : 200 MHz (defined by MIG constraints)
set MIG_TCK 5

# False-path incoming reset
set MIG_RST_I [get_pin i_dram_wrapper/i_dram/aresetn]
set_false_path -hold -setup -through $MIG_RST_I

# Constrain outgoing reset
set MIG_RST_O [get_pins i_dram_wrapper/i_dram/ui_clk_sync_rst]
set_false_path -hold -through $MIG_RST_O
set_max_delay -through $MIG_RST_O $MIG_TCK

# Limit delay across DRAM CDC (hold already false-pathed)
# tclint-disable line-length
set_max_delay -datapath_only \
    -from [get_pins i_dram_wrapper/gen_cdc.i_axi_cdc_mig/i_axi_cdc_*/i_cdc_fifo_gray_*/*reg*/C] \
    -to [get_pins i_dram_wrapper/gen_cdc.i_axi_cdc_mig/i_axi_cdc_*/i_cdc_fifo_gray_*/*i_sync/reg*/D] $MIG_TCK
set_max_delay -datapath_only \
    -from [get_pins i_dram_wrapper/gen_cdc.i_axi_cdc_mig/i_axi_cdc_*/i_cdc_fifo_gray_*/*reg*/C] \
    -to [get_pins i_dram_wrapper/gen_cdc.i_axi_cdc_mig/i_axi_cdc_*/i_cdc_fifo_gray_*/i_spill_register/spill_register_flushable_i/*reg*/D] $MIG_TCK
# tclint-enable line-length

#######
# VGA #
#######

set_output_delay -min -clock $soc_clk [expr { $SOC_TCK * 0.10 }] [get_ports vga*]
set_output_delay -max -clock $soc_clk [expr { $SOC_TCK * 0.35 }] [get_ports vga*]

########
# SPIM #
########

set_input_delay -min -clock $soc_clk [expr { 0.10 * $SOC_TCK }] [ \
    get_ports {sd_d_* sd_cd_i spih_sd_*}]
set_input_delay -max -clock $soc_clk [expr { 0.35 * $SOC_TCK }] [ \
    get_ports {sd_d_* sd_cd_i spih_sd_*}]
# TODO: fix this by raising it back up...
set_output_delay -min -clock $soc_clk [expr { 0.020 * $SOC_TCK }] [ \
    get_ports {sd_d_* sd_*_o spih_sd_* spih_csb_o}]
set_output_delay -max -clock $soc_clk [expr { 0.063 * $SOC_TCK }] [ \
    get_ports {sd_d_* sd_*_o spih_sd_* spih_csb_o}]

#######
# I2C #
#######

# I2C High-speed mode is 3.2 Mb/s
set I2C_IO_SPEED 312.5

set_max_delay [expr { $I2C_IO_SPEED * 0.35 }] -from [get_ports {i2c_scl_io i2c_sda_io}]
set_false_path -hold -from [get_ports {i2c_scl_io i2c_sda_io}]

set_max_delay [expr { $I2C_IO_SPEED * 0.35 }] -to [get_ports {i2c_scl_io i2c_sda_io}]
set_false_path -hold -to [get_ports {i2c_scl_io i2c_sda_io}]

#######
# USB #
#######

set usb_clk [get_clocks -of_objects [get_pins i_clkwiz/clk_48]]

# `set_max_delay -datapath only` implicitly vaives all undesired checks between clocks (setup with
# skew and hold). We assume here `soc_clk` is the faster clock, and allocate two thirds of its
# period for the crossing.
set_max_delay -datapath_only -from $usb_clk -to $soc_clk [expr { 0.67 * $SOC_TCK }]
set_max_delay -datapath_only -from $soc_clk -to $usb_clk [expr { 0.67 * $SOC_TCK }]

set_input_delay -min -clock $usb_clk [expr { 0.10 * $SOC_TCK }] [get_ports {usb_d*_i}]
set_input_delay -max -clock $usb_clk [expr { 0.35 * $SOC_TCK }] [get_ports {usb_d*_i}]

set_output_delay -min -clock $usb_clk [expr { 0.10 * $SOC_TCK }] [get_ports {usb_d*_o usb_d*_oe}]
set_output_delay -max -clock $usb_clk [expr { 0.35 * $SOC_TCK }] [get_ports {usb_d*_o usb_d*_oe}]

###############
# Assign Pins #
###############

# tclint-disable line-length, spacing

## Clock Signal
set_property -dict { PACKAGE_PIN AD11  IOSTANDARD LVDS     } [get_ports { sys_clk_n }]; #IO_L12N_T1_MRCC_33 Sch=sysclk_n
set_property -dict { PACKAGE_PIN AD12  IOSTANDARD LVDS     } [get_ports { sys_clk_p }]; #IO_L12P_T1_MRCC_33 Sch=sysclk_p

## Buttons
set_property -dict { PACKAGE_PIN R19   IOSTANDARD LVCMOS33 } [get_ports { sys_resetn }]; #IO_0_14 Sch=cpu_resetn

## Switches
set_property -dict { PACKAGE_PIN G19   IOSTANDARD LVCMOS12 } [get_ports { boot_mode_i[0] }]; #IO_0_17 Sch=sw[0]
set_property -dict { PACKAGE_PIN G25   IOSTANDARD LVCMOS12 } [get_ports { boot_mode_i[1] }]; #IO_25_16 Sch=sw[1]
set_property -dict { PACKAGE_PIN H24   IOSTANDARD LVCMOS12 } [get_ports { fan_sw[0] }]; #IO_L19P_T3_16 Sch=sw[2]
set_property -dict { PACKAGE_PIN K19   IOSTANDARD LVCMOS12 } [get_ports { fan_sw[1] }]; #IO_L6P_T0_17 Sch=sw[3]
set_property -dict { PACKAGE_PIN N19   IOSTANDARD LVCMOS12 } [get_ports { fan_sw[2] }]; #IO_L19P_T3_A22_15 Sch=sw[4]
set_property -dict { PACKAGE_PIN P19   IOSTANDARD LVCMOS12 } [get_ports { fan_sw[3] }]; #IO_25_15 Sch=sw[5]
set_property -dict { PACKAGE_PIN P27   IOSTANDARD LVCMOS33 } [get_ports { test_mode_i }]; #IO_L8P_T1_D11_14 Sch=sw[7]

# UART
set_property -dict { PACKAGE_PIN Y23   IOSTANDARD LVCMOS33 } [get_ports { uart_tx_o }]; #IO_L1P_T0_12 Sch=uart_rx_out
set_property -dict { PACKAGE_PIN Y20   IOSTANDARD LVCMOS33 } [get_ports { uart_rx_i }]; #IO_0_12 Sch=uart_tx_in

# SD Card
set_property -dict { PACKAGE_PIN P28   IOSTANDARD LVCMOS33 } [get_ports { sd_cd_i }]; #IO_L8N_T1_D12_14 Sch=sd_cd
set_property -dict { PACKAGE_PIN R29   IOSTANDARD LVCMOS33 } [get_ports { sd_cmd_o }]; #IO_L7N_T1_D10_14 Sch=sd_cmd
set_property -dict { PACKAGE_PIN R26   IOSTANDARD LVCMOS33 } [get_ports { sd_d_io[0] }]; #IO_L10N_T1_D15_14 Sch=sd_dat[0]
set_property -dict { PACKAGE_PIN R30   IOSTANDARD LVCMOS33 } [get_ports { sd_d_io[1] }]; #IO_L9P_T1_DQS_14 Sch=sd_dat[1]
set_property -dict { PACKAGE_PIN P29   IOSTANDARD LVCMOS33 } [get_ports { sd_d_io[2] }]; #IO_L7P_T1_D09_14 Sch=sd_dat[2]
set_property -dict { PACKAGE_PIN T30   IOSTANDARD LVCMOS33 } [get_ports { sd_d_io[3] }]; #IO_L9N_T1_DQS_D13_14 Sch=sd_dat[3]
set_property -dict { PACKAGE_PIN AE24  IOSTANDARD LVCMOS33 } [get_ports { sd_reset_o }]; #IO_L12N_T1_MRCC_12 Sch=sd_reset
set_property -dict { PACKAGE_PIN R28   IOSTANDARD LVCMOS33 } [get_ports { sd_sclk_o }]; #IO_L11P_T1_SRCC_14 Sch=sd_sclk

# QSPI
set_property -dict { PACKAGE_PIN U19   IOSTANDARD LVCMOS33 } [get_ports { spih_csb_o }]; #IO_L6P_T0_FCS_B_14 Sch=qspi_csn
set_property -dict { PACKAGE_PIN P24   IOSTANDARD LVCMOS33 } [get_ports { spih_sd_io[0] }]; #IO_L1P_T0_D00_MOSI_14 Sch=qspi_d[0]
set_property -dict { PACKAGE_PIN R25   IOSTANDARD LVCMOS33 } [get_ports { spih_sd_io[1] }]; #IO_L1N_T0_D01_DIN_14 Sch=qspi_d[1]
set_property -dict { PACKAGE_PIN R20   IOSTANDARD LVCMOS33 } [get_ports { spih_sd_io[2] }]; #IO_L2P_T0_D02_14 Sch=qspi_d[2]
set_property -dict { PACKAGE_PIN R21   IOSTANDARD LVCMOS33 } [get_ports { spih_sd_io[3] }]; #IO_L2N_T0_D03_14 Sch=qspi_d[3]

# VGA Connector
set_property -dict { PACKAGE_PIN AH20  IOSTANDARD LVCMOS33 } [get_ports { vga_blue_o[0] }]; #IO_L22N_T3_12 Sch=vga_b[3]
set_property -dict { PACKAGE_PIN AG20  IOSTANDARD LVCMOS33 } [get_ports { vga_blue_o[1] }]; #IO_L22P_T3_12 Sch=vga_b[4]
set_property -dict { PACKAGE_PIN AF21  IOSTANDARD LVCMOS33 } [get_ports { vga_blue_o[2] }]; #IO_L19N_T3_VREF_12 Sch=vga_b[5]
set_property -dict { PACKAGE_PIN AK20  IOSTANDARD LVCMOS33 } [get_ports { vga_blue_o[3] }]; #IO_L24P_T3_12 Sch=vga_b[6]
set_property -dict { PACKAGE_PIN AG22  IOSTANDARD LVCMOS33 } [get_ports { vga_blue_o[4] }]; #IO_L20P_T3_12 Sch=vga_b[7]

set_property -dict { PACKAGE_PIN AJ23  IOSTANDARD LVCMOS33 } [get_ports { vga_green_o[0] }]; #IO_L21N_T3_DQS_12 Sch=vga_g[2]
set_property -dict { PACKAGE_PIN AJ22  IOSTANDARD LVCMOS33 } [get_ports { vga_green_o[1] }]; #IO_L21P_T3_DQS_12 Sch=vga_g[3]
set_property -dict { PACKAGE_PIN AH22  IOSTANDARD LVCMOS33 } [get_ports { vga_green_o[2] }]; #IO_L20N_T3_12 Sch=vga_g[4]
set_property -dict { PACKAGE_PIN AK21  IOSTANDARD LVCMOS33 } [get_ports { vga_green_o[3] }]; #IO_L24N_T3_12 Sch=vga_g[5]
set_property -dict { PACKAGE_PIN AJ21  IOSTANDARD LVCMOS33 } [get_ports { vga_green_o[4] }]; #IO_L23N_T3_12 Sch=vga_g[6]
set_property -dict { PACKAGE_PIN AK23  IOSTANDARD LVCMOS33 } [get_ports { vga_green_o[5] }]; #IO_L17P_T2_12 Sch=vga_g[7]

set_property -dict { PACKAGE_PIN AK25  IOSTANDARD LVCMOS33 } [get_ports { vga_red_o[0] }]; #IO_L15N_T2_DQS_12 Sch=vga_r[3]
set_property -dict { PACKAGE_PIN AG25  IOSTANDARD LVCMOS33 } [get_ports { vga_red_o[1] }]; #IO_L18P_T2_12 Sch=vga_r[4]
set_property -dict { PACKAGE_PIN AH25  IOSTANDARD LVCMOS33 } [get_ports { vga_red_o[2] }]; #IO_L18N_T2_12 Sch=vga_r[5]
set_property -dict { PACKAGE_PIN AK24  IOSTANDARD LVCMOS33 } [get_ports { vga_red_o[3] }]; #IO_L17N_T2_12 Sch=vga_r[6]
set_property -dict { PACKAGE_PIN AJ24  IOSTANDARD LVCMOS33 } [get_ports { vga_red_o[4] }]; #IO_L15P_T2_DQS_12 Sch=vga_r[7]

set_property -dict { PACKAGE_PIN AF20  IOSTANDARD LVCMOS33 } [get_ports { vga_hsync_o }]; #IO_L19P_T3_12 Sch=vga_hs
set_property -dict { PACKAGE_PIN AG23  IOSTANDARD LVCMOS33 } [get_ports { vga_vsync_o }]; #IO_L13N_T2_MRCC_12 Sch=vga_vs

## Fan Control
set_property -dict { PACKAGE_PIN W19   IOSTANDARD LVCMOS33 } [get_ports { fan_pwm }]; #IO_25_14 Sch=fan_pwm

# DPTI
# Note: DPTI and DSPI constraints cannot be used in the same design, as they share pins.
set_property -dict { PACKAGE_PIN AD27  IOSTANDARD LVCMOS33 } [get_ports { jtag_tck_i }]; #IO_L11P_T1_SRCC_13 Sch=prog_d0/sck
set_property -dict { PACKAGE_PIN W27   IOSTANDARD LVCMOS33 } [get_ports { jtag_tdi_i }]; #IO_L2P_T0_13 Sch=prog_d1/mosi
set_property -dict { PACKAGE_PIN W28   IOSTANDARD LVCMOS33 } [get_ports { jtag_tdo_o }]; #IO_L2N_T0_13 Sch=prog_d2/miso
set_property -dict { PACKAGE_PIN W29   IOSTANDARD LVCMOS33 } [get_ports { jtag_tms_i }]; #IO_L4P_T0_13 Sch=prog_d3/ss
set_property -dict { PACKAGE_PIN Y29   IOSTANDARD LVCMOS33 } [get_ports { jtag_trst_ni }]; #IO_L4N_T0_13 Sch=prog_d[4]

# I2C Bus
set_property -dict { PACKAGE_PIN AE30  IOSTANDARD LVCMOS33 } [get_ports { i2c_scl_io }]; #IO_L16P_T2_13 Sch=sys_scl
set_property -dict { PACKAGE_PIN AF30  IOSTANDARD LVCMOS33 } [get_ports { i2c_sda_io }]; #IO_L16N_T2_13 Sch=sys_sda

# PMOD Header JA (USB 1.1 Adapter)
set_property -dict { PACKAGE_PIN U27   IOSTANDARD LVCMOS33 } [get_ports { usb_dm_io[3] }]; #IO_L13P_T2_MRCC_14 Sch=ja_p[1]
set_property -dict { PACKAGE_PIN U28   IOSTANDARD LVCMOS33 } [get_ports { usb_dp_io[3] }]; #IO_L13N_T2_MRCC_14 Sch=ja_n[1]
set_property -dict { PACKAGE_PIN T26   IOSTANDARD LVCMOS33 } [get_ports { usb_dm_io[2] }]; #IO_L12P_T1_MRCC_14 Sch=ja_p[2]
set_property -dict { PACKAGE_PIN T27   IOSTANDARD LVCMOS33 } [get_ports { usb_dp_io[2] }]; #IO_L12N_T1_MRCC_14 Sch=ja_n[2]
set_property -dict { PACKAGE_PIN T22   IOSTANDARD LVCMOS33 } [get_ports { usb_dm_io[1] }]; #IO_L5P_T0_D06_14 Sch=ja_p[3]
set_property -dict { PACKAGE_PIN T23   IOSTANDARD LVCMOS33 } [get_ports { usb_dp_io[1] }]; #IO_L5N_T0_D07_14 Sch=ja_n[3]
set_property -dict { PACKAGE_PIN T20   IOSTANDARD LVCMOS33 } [get_ports { usb_dm_io[0] }]; #IO_L4P_T0_D04_14 Sch=ja_p[4]
set_property -dict { PACKAGE_PIN T21   IOSTANDARD LVCMOS33 } [get_ports { usb_dp_io[0] }]; #IO_L4N_T0_D05_14 Sch=ja_n[4]

# tclint-enable line-length, spacing
