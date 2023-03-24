# Copyright 2018 ETH Zurich and University of Bologna.
# Solderpad Hardware License, Version 0.51, see LICENSE for details.
# SPDX-License-Identifier: SHL-0.51
#

set partNumber $::env(XILINX_PART)
set boardName  $::env(XILINX_BOARD)

set ipName xlnx_sim_clk_gen

create_project $ipName . -force -part $partNumber
set_property board_part $boardName [current_project]

create_ip -name sim_clk_gen -vendor xilinx.com -library ip -version 1.0 -module_name $ipName

set_property -dict [list CONFIG.CLOCK_TYPE {Differential} \
                         CONFIG.FREQ_HZ {100000000} \
                   ] [get_ips $ipName]

generate_target {instantiation_template} [get_files ./$ipName.srcs/sources_1/ip/$ipName/$ipName.xci]
generate_target all [get_files  ./$ipName.srcs/sources_1/ip/$ipName/$ipName.xci]
#create_ip_run [get_files -of_objects [get_fileset sources_1] ./$ipName.srcs/sources_1/ip/$ipName/$ipName.xci]
#launch_run -jobs 8 ${ipName}_synth_1
#wait_on_run ${ipName}_synth_1