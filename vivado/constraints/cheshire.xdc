# Copyright 2022 ETH Zurich and University of Bologna.
# Solderpad Hardware License, Version 0.51, see LICENSE for details.
# SPDX-License-Identifier: SHL-0.51
#
# Nicole Narr <narrn@student.ethz.ch>
# Christopher Reinwardt <creinwar@student.ethz.ch>

# Standard 200 MHz differential clock for Genesys 2 FPGA
create_clock -period 5.000 -name sys_clk_pin -add [get_ports sysclk_p]

# 50 MHz system Clock
create_generated_clock -name soc_clk -source [get_pins i_sys_clk_div/t_ff1_q_reg/C] -divide_by 4 [get_pins i_sys_clk_div/t_ff1_q_reg/Q]

# 10 MHz clock for JTAG
create_clock -period 100.000 -name jtag_clk -add [get_ports jtag_tck_i]

set_input_jitter jtag_clk 1.000

# JTAG Clock is asynchronous to all other clocks
set_clock_groups -name jtag_async -asynchronous -group [get_clocks jtag_clk]

# Accept suboptimal BUFG-BUFG cascades
#set_property CLOCK_DEDICATED_ROUTE BACKBONE [get_nets i_dram/u_xlnx_mig_7_ddr3_mig/u_ddr3_clk_ibuf/sys_clk_ibufg]
set_property CLOCK_DEDICATED_ROUTE ANY_CMT_COLUMN [get_nets i_sys_clk_div/i_clk_mux/generated_clock]
set_property CLOCK_DEDICATED_ROUTE ANY_CMT_COLUMN [get_nets i_cheshire_soc/gen_vga.i_axi_vga/i_pixel_clk_div/i_clk_mux/generated_clock]

# Set conservative input/output delays for SPI
set_input_delay -clock soc_clk 10.000 [get_ports sd_d_io*]

# minimize routing delay
set_input_delay -clock jtag_clk -clock_fall 5.000 [get_ports jtag_tdi_i]
set_input_delay -clock jtag_clk -clock_fall 5.000 [get_ports jtag_tms_i]
set_output_delay -clock jtag_clk 5.000 [get_ports jtag_tdo_o]
set_false_path -from [get_ports jtag_trst_ni]

set_max_delay -to [get_ports jtag_tdo_o] 20.000
set_max_delay -from [get_ports jtag_tms_i] 20.000
set_max_delay -from [get_ports jtag_tdi_i] 20.000
set_max_delay -from [get_ports jtag_trst_ni] 20.000

set_false_path -from [get_pins i_dram/u_xlnx_mig_7_ddr3_mig/u_ddr3_infrastructure/rstdiv0_sync_r1_reg_rep/C]

# Constrain clock domain crossings
# cdc_fifo_gray
set async_pins [get_pins -of_objects [get_cells {i_axi_cdc_mig/*/*}] -filter {NAME=~*async*}]
set_max_delay -through ${async_pins} -through ${async_pins} 5
set_false_path -hold -through ${async_pins} -through ${async_pins}

# rst comes from MIG => Is already synchronous to 200 MHz -> Only need to enforce synch to soc_clk
set_max_delay -from [get_pins {i_rstgen_main/i_rstgen_bypass/synch_regs_q_reg[3]/C}] 14.000
