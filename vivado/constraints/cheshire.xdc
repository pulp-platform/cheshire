# Copyright 2022 ETH Zurich and University of Bologna.
# Solderpad Hardware License, Version 0.51, see LICENSE for details.
# SPDX-License-Identifier: SHL-0.51
#
# Nicole Narr <narrn@student.ethz.ch>
# Christopher Reinwardt <creinwar@student.ethz.ch>

###################
# Global Settings #
###################

# Testmode is set to 0 during normal use
set_case_analysis 0 [get_ports testmode_i]

# Preserve the output mux of the main clock divider
set_property DONT_TOUCH TRUE [get_cells i_sys_clk_div/i_clk_bypass_mux]

# The pin we get the 200 MHz single ended clock from the MIG
set MIG_CLK_SRC {i_dram/u_xlnx_mig_7_ddr3_mig/u_ddr3_infrastructure/gen_mmcm.mmcm_i/CLKFBOUT}

#####################
# Timing Parameters #
#####################

# 200 MHz FPGA diff clock
set FPGA_TCK 5.0

# 50 MHz SoC clock
set SOC_TCK 20.0

# 8.3 MHz JTAG clock
set JTAG_TCK 120.0

# I2C High-speed mode is 3.2 Mb/s
set I2C_IO_SPEED 312.5

# UART speed is at most 5 Mb/s
set UART_IO_SPEED 200.0


##########
# Clocks #
##########

# 50 MHz system Clock
create_generated_clock -name clk_soc -source [get_pins $MIG_CLK_SRC] -divide_by 4 [get_pins i_sys_clk_div/i_clk_bypass_mux/i_BUFGMUX/O]

# 10 MHz clock for JTAG
create_clock -period $JTAG_TCK -name clk_jtag [get_ports jtag_tck_i]
set_input_jitter clk_jtag 1.000


################
# Clock Groups #
################

# JTAG Clock is asynchronous to all other clocks
set_clock_groups -name jtag_async -asynchronous -group [get_clocks clk_jtag]

# The SoC clock will never come in contact with any other clock (except in CDCs)
set_clock_groups -name soc_phys_excl -physically_exclusive -group [get_clocks clk_soc]


#######################
# Placement Overrides #
#######################

# Accept suboptimal BUFG-BUFG cascades
#set_property CLOCK_DEDICATED_ROUTE BACKBONE [get_nets i_dram/u_xlnx_mig_7_ddr3_mig/u_ddr3_clk_ibuf/sys_clk_ibufg]
set_property CLOCK_DEDICATED_ROUTE ANY_CMT_COLUMN [get_nets i_sys_clk_div/i_clk_mux/generated_clock]
set_property CLOCK_DEDICATED_ROUTE ANY_CMT_COLUMN [get_nets i_cheshire_soc/gen_vga.i_axi_vga/i_pixel_clk_div/i_clk_mux/generated_clock]
set_property CLOCK_DEDICATED_ROUTE ANY_CMT_COLUMN [get_nets i_cheshire_soc/gen_vga.i_axi_vga/i_pixel_clk_div/i_clk_mux/clk_o]
set_property CLOCK_DEDICATED_ROUTE ANY_CMT_COLUMN [get_nets i_sys_clk_div/i_clk_mux/clk_o]
set_property CLOCK_DEDICATED_ROUTE ANY_CMT_COLUMN [get_nets i_sys_clk_div/i_clk_mux/clk0_i]


########
# JTAG #
########

set_input_delay  -min -clock clk_jtag [expr 0.10 * $JTAG_TCK] [get_ports {jtag_tdi_i jtag_tms_i}]
set_input_delay  -max -clock clk_jtag [expr 0.20 * $JTAG_TCK] [get_ports {jtag_tdi_i jtag_tms_i}]

set_output_delay -min -clock clk_jtag [expr 0.10 * $JTAG_TCK] [get_ports jtag_tdo_o]
set_output_delay -max -clock clk_jtag [expr 0.20 * $JTAG_TCK] [get_ports jtag_tdo_o]

set_max_delay  -from [get_ports jtag_trst_ni] $JTAG_TCK
set_false_path -hold -from [get_ports jtag_trst_ni]


#######
# MIG #
#######

set_max_delay  -from [get_pins i_dram/u_xlnx_mig_7_ddr3_mig/u_ddr3_infrastructure/rstdiv0_sync_r1_reg_rep/C] $FPGA_TCK
set_false_path -hold -from [get_pins i_dram/u_xlnx_mig_7_ddr3_mig/u_ddr3_infrastructure/rstdiv0_sync_r1_reg_rep/C]


########
# SPIM #
########

set_input_delay  -min -clock clk_soc [expr 0.10 * $SOC_TCK] [get_ports {sd_d_* sd_cd_i}]
set_input_delay  -max -clock clk_soc [expr 0.35 * $SOC_TCK] [get_ports {sd_d_* sd_cd_i}]
set_output_delay -min -clock clk_soc [expr 0.10 * $SOC_TCK] [get_ports {sd_d_* sd_*_o}]
set_output_delay -max -clock clk_soc [expr 0.20 * $SOC_TCK] [get_ports {sd_d_* sd_*_o}]

#######
# I2C #
#######

set_max_delay [expr $I2C_IO_SPEED * 0.35] -from [get_ports {i2c_scl_io i2c_sda_io}]
set_false_path -hold -from [get_ports {i2c_scl_io i2c_sda_io}]

set_max_delay [expr $I2C_IO_SPEED * 0.35] -to [get_ports {i2c_scl_io i2c_sda_io}]
set_false_path -hold -to [get_ports {i2c_scl_io i2c_sda_io}]


########
# UART #
########

set_max_delay [expr $UART_IO_SPEED * 0.35] -from [get_ports uart_rx_i]
set_false_path -hold -from [get_ports uart_rx_i]

set_max_delay [expr $UART_IO_SPEED * 0.35] -to [get_ports uart_tx_o]
set_false_path -hold -to [get_ports uart_tx_o]

#######
# VGA #
#######

set_output_delay -min -clock clk_soc [expr $SOC_TCK * 0.10] [get_ports vga*]
set_output_delay -max -clock clk_soc [expr $SOC_TCK * 0.35] [get_ports vga*]


############
# Switches #
############

set_input_delay -min -clock clk_soc [expr $SOC_TCK * 0.10] [get_ports {boot_mode* fan_sw* testmode_i}]
set_input_delay -max -clock clk_soc [expr $SOC_TCK * 0.35] [get_ports {boot_mode* fan_sw* testmode_i}]

set_output_delay -min -clock clk_soc [expr $SOC_TCK * 0.10] [get_ports fan_pwm]
set_output_delay -max -clock clk_soc [expr $SOC_TCK * 0.35] [get_ports fan_pwm]

set_max_delay [expr 2 * $SOC_TCK] -from [get_ports {boot_mode* fan_sw* testmode_i}]
set_false_path -hold -from [get_ports {boot_mode* fan_sw* testmode_i}]

set_max_delay [expr 2 * $SOC_TCK] -to [get_ports fan_pwm]
set_false_path -hold -to [get_ports fan_pwm]

########
# CDCs #
########

# cdc_fifo_gray
set_max_delay -through [get_pins -of_objects [get_cells i_axi_cdc_mig/i_axi_cdc_src]] -through [get_pins -of_objects [get_cells i_axi_cdc_mig/i_axi_cdc_dst]] 10
set_min_delay -through [get_pins -of_objects [get_cells i_axi_cdc_mig/i_axi_cdc_src]] -through [get_pins -of_objects [get_cells i_axi_cdc_mig/i_axi_cdc_dst]] 5
set_false_path -hold -through [get_pins -of_objects [get_cells i_axi_cdc_mig/i_axi_cdc_src]] -through [get_pins -of_objects [get_cells i_axi_cdc_mig/i_axi_cdc_dst]]

###################
# Reset Generator #
###################

set_max_delay -from [get_pins {i_rstgen_main/i_rstgen_bypass/synch_regs_q_reg[3]/C}] $FPGA_TCK
set_false_path -hold -from [get_pins {i_rstgen_main/i_rstgen_bypass/synch_regs_q_reg[3]/C}]
