# Copyright 2022 ETH Zurich and University of Bologna.
# Solderpad Hardware License, Version 0.51, see LICENSE for details.
# SPDX-License-Identifier: SHL-0.51
#
# Nicole Narr <narrn@student.ethz.ch>
# Christopher Reinwardt <creinwar@student.ethz.ch>

###################
# Global Settings #
###################

# Preserve the output mux of the clock divider
set_property DONT_TOUCH TRUE [get_cells i_sys_clk_div/i_clk_bypass_mux]

# The net of which we get the 200 MHz single ended clock from the MIG
set MIG_CLK_SRC [get_pins -filter {DIRECTION == OUT} -leaf -of_objects [get_nets dram_clock_out]]
set MIG_RST_SRC [get_pins -filter {DIRECTION == OUT} -leaf -of_objects [get_nets dram_sync_reset]]

set SOC_RST_SRC [get_pins -filter {DIRECTION == OUT} -leaf -of_objects [get_nets rst_n]]

#####################
# Timing Parameters #
#####################

# 333 MHz (max) DRAM Axi clock
set FPGA_TCK 3.0

# 200 MHz DRAM Generated clock
set DRAM_TCK 5.0

# 50 MHz SoC clock
set SOC_TCK 20.0

# 10 MHz (max) JTAG clock
set JTAG_TCK 100.0

# I2C High-speed mode is 3.2 Mb/s
set I2C_IO_SPEED 312.5

# UART speed is at most 5 Mb/s
set UART_IO_SPEED 200.0

##########
# Clocks #
##########

# System Clock
create_generated_clock -name clk_soc -source $MIG_CLK_SRC -divide_by 4 [get_nets soc_clk]
# JTAG Clock
create_clock -period $JTAG_TCK -name clk_jtag [get_ports jtag_tck_i]
set_input_jitter clk_jtag 1.000

################
# Clock Groups #
################

# JTAG Clock is asynchronous to all other clocks
set_clock_groups -name jtag_async -asynchronous -group [get_clocks clk_jtag]

#######################
# Placement Overrides #
#######################

# Accept suboptimal BUFG-BUFG cascades
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

set_max_delay  -from $MIG_RST_SRC $FPGA_TCK
set_false_path -hold -from $MIG_RST_SRC

########
# UART #
########

set_max_delay [expr $UART_IO_SPEED * 0.35] -from [get_ports uart_rx_i]
set_false_path -hold -from [get_ports uart_rx_i]

set_max_delay [expr $UART_IO_SPEED * 0.35] -to [get_ports uart_tx_o]
set_false_path -hold -to [get_ports uart_tx_o]

########
# CDCs #
########

# cdc_fifo_gray: Disable hold checks, limit datapath delay and bus skew
set_property KEEP_HIERARCHY SOFT [get_cells i_dram_wrapper/i_axi_cdc_mig/i_axi_cdc_*/i_cdc_fifo_gray_*/*i_sync]
set_false_path -hold -through [get_pins -of_objects [get_cells i_dram_wrapper/i_axi_cdc_mig/i_axi_cdc_*]] -through [get_pins -of_objects [get_cells i_dram_wrapper/i_axi_cdc_mig/i_axi_cdc_*]]
set_max_delay -datapath -from [get_pins i_dram_wrapper/i_axi_cdc_mig/i_axi_cdc_*/i_cdc_fifo_gray_*/*reg*/C] -to [get_pins i_dram_wrapper/i_axi_cdc_mig/i_axi_cdc_*/i_cdc_fifo_gray_dst_*/*i_sync/reg*/D] $FPGA_TCK
set_max_delay -datapath -from [get_pins i_dram_wrapper/i_axi_cdc_mig/i_axi_cdc_*/i_cdc_fifo_gray_*/*reg*/C] -to [get_pins i_dram_wrapper/i_axi_cdc_mig/i_axi_cdc_*/i_cdc_fifo_gray_src_*/*i_sync/reg*/D] $FPGA_TCK
set_max_delay -datapath -from [get_pins i_dram_wrapper/i_axi_cdc_mig/i_axi_cdc_*/i_cdc_fifo_gray_*/*reg*/C] -to [get_pins i_dram_wrapper/i_axi_cdc_mig/i_axi_cdc_*/i_cdc_fifo_gray_*/i_spill_register/spill_register_flushable_i/*reg*/D] $FPGA_TCK

###################
# Reset Generator #
###################

set_max_delay -from $SOC_RST_SRC $SOC_TCK
set_false_path -hold -from $SOC_RST_SRC
