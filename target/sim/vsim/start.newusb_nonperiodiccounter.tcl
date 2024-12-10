# Copyright 2022 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
#
# Fabian Hauser <fhauser@student.ethz.ch>

set TESTBENCH tb_new_usb_nonperiodiccounter

set StdArithNoWarnings 1
set NumericStdNoWarnings 1

eval vsim -c ${TESTBENCH} -t 1ps -vopt -voptargs="+acc"
add wave -position insertpoint sim:/tb_new_usb_nonperiodiccounter/clk_i
add wave -position insertpoint sim:/tb_new_usb_nonperiodiccounter/rst_ni
add wave -position insertpoint sim:/tb_new_usb_nonperiodiccounter/overflow
add wave -position insertpoint sim:/tb_new_usb_nonperiodiccounter/threshold
add wave -position insertpoint sim:/tb_new_usb_nonperiodiccounter/i_nonperiodiccounter/count
add wave -position insertpoint sim:/tb_new_usb_nonperiodiccounter/i_nonperiodiccounter/reload_cbsr
add wave -position insertpoint sim:/tb_new_usb_nonperiodiccounter/i_nonperiodiccounter/cbsr_i
add wave -position insertpoint sim:/tb_new_usb_nonperiodiccounter/i_nonperiodiccounter/i_counter/en_i
add wave -position insertpoint sim:/tb_new_usb_nonperiodiccounter/i_nonperiodiccounter/served_control_td_i
add wave -position insertpoint sim:/tb_new_usb_nonperiodiccounter/i_nonperiodiccounter/served_control_td_prev
add wave -position insertpoint sim:/tb_new_usb_nonperiodiccounter/i_nonperiodiccounter/restart_counter
add wave -position insertpoint sim:/tb_new_usb_nonperiodiccounter/i_nonperiodiccounter/served_bulk_td_i
add wave -position insertpoint sim:/tb_new_usb_nonperiodiccounter/i_nonperiodiccounter/served_bulk_td_prev


run 1us