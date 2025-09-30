# Copyright 2022 ETH Zurich and University of Bologna.
# Solderpad Hardware License, Version 0.51, see LICENSE for details.
# SPDX-License-Identifier: SHL-0.51
#
# Nicole Narr <narrn@student.ethz.ch>
# Christopher Reinwardt <creinwar@student.ethz.ch>
# Cyril Koenig <cykoenig@iis.ee.ethz.ch>
# Paul Scheffler <paulsc@iis.ee.ethz.ch>
# Yvan Tortorella <yvan.tortorella@gmail.com>

#################
# Clock routing #
#################

# JTAG is on non-clock-capable GPIOs (if not using BSCANE)
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets -of [get_ports jtag_tck_i]]
set_property CLOCK_BUFFER_TYPE NONE [get_nets -of [get_ports jtag_tck_i]]

set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets -of [get_ports sys_reset*]]
set_property CLOCK_BUFFER_TYPE NONE [get_nets -of [get_ports sys_reset*]]

# Remove avoid tc_clk_mux2 to use global clock routing
set all_in_mux [get_nets -of [ get_pins -filter { DIRECTION == IN } -of \
    [get_cells -hier -filter { ORIG_REF_NAME == tc_clk_mux2 || REF_NAME == tc_clk_mux2 }]]]
set_property CLOCK_DEDICATED_ROUTE FALSE $all_in_mux
set_property CLOCK_BUFFER_TYPE NONE $all_in_mux

########
# JTAG #
########

# 10 MHz (max) JTAG clock
set JTAG_TCK 100.0

# JTAG Clock
create_clock -period $JTAG_TCK -name clk_jtag [get_ports jtag_tck_i]
set_input_jitter clk_jtag 1.000

# JTAG Clock is asynchronous to all other clocks
set_clock_groups -name jtag_async -asynchronous -group {clk_jtag}

set_input_delay -min -clock clk_jtag [expr { 0.10 * $JTAG_TCK }] [get_ports {jtag_tdi_i jtag_tms_i}]
set_input_delay -max -clock clk_jtag [expr { 0.20 * $JTAG_TCK }] [get_ports {jtag_tdi_i jtag_tms_i}]

set_output_delay -min -clock clk_jtag [expr { 0.10 * $JTAG_TCK }] [get_ports jtag_tdo_o]
set_output_delay -max -clock clk_jtag [expr { 0.20 * $JTAG_TCK }] [get_ports jtag_tdo_o]

set_max_delay -from [get_ports jtag_trst_ni] $JTAG_TCK
set_false_path -hold -from [get_ports jtag_trst_ni]

########
# UART #
########

# UART speed is at most 5 Mb/s
set UART_IO_SPEED 200.0

set_max_delay [expr { $UART_IO_SPEED * 0.35 }] -from [get_ports uart_rx_i]
set_false_path -hold -from [get_ports uart_rx_i]

set_max_delay [expr { $UART_IO_SPEED * 0.35 }] -to [get_ports uart_tx_o]
set_false_path -hold -to [get_ports uart_tx_o]

########
# CDCs #
########

# Disable hold checks on CDCs
set_property KEEP_HIERARCHY SOFT [get_cells -hier \
    -filter {ORIG_REF_NAME=="sync" || REF_NAME=="sync"}]
set_false_path -hold -through [get_pins -of_objects [get_cells -hier \
    -filter {ORIG_REF_NAME=="sync" || REF_NAME=="sync"}] -filter {NAME=~*serial_i}]

set_false_path -hold -through [get_pins -of_objects [get_cells -hier \
    -filter {ORIG_REF_NAME == axi_cdc_src || REF_NAME == axi_cdc_src}] -filter {NAME =~ *async*}]
set_false_path -hold -through [get_pins -of_objects [get_cells -hier \
    -filter {ORIG_REF_NAME == axi_cdc_dst || REF_NAME == axi_cdc_dst}] -filter {NAME =~ *async*}]

########
# QSPI #
########

# Configuring QSPI to load bitstream faster
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]
