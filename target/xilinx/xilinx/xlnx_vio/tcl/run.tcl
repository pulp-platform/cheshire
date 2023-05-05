# Copyright 2023 ETH Zurich and University of Bologna.
# Solderpad Hardware License, Version 0.51, see LICENSE for details.
# SPDX-License-Identifier: SHL-0.51
#
# Cyril Koenig <cykoenig@iis.ee.ethz.ch>

set partNumber $::env(XILINX_PART)
set boardName  $::env(XILINX_BOARD)

set ipName xlnx_vio

create_project $ipName . -force -part $partNumber
set_property board_part $boardName [current_project]

create_ip -name vio -vendor xilinx.com -library ip -version 3.0 -module_name $ipName

if {$::env(BOARD) eq "vcu128"} {
set_property -dict [list CONFIG.C_NUM_PROBE_OUT {3} \
                         CONFIG.C_PROBE_OUT0_INIT_VAL {0x0} \
                         CONFIG.C_PROBE_OUT1_INIT_VAL {0x2} \
                         CONFIG.C_PROBE_OUT2_INIT_VAL {0x1} \
                         CONFIG.C_PROBE_OUT1_WIDTH {2} \
                         CONFIG.C_EN_PROBE_IN_ACTIVITY {0} \
                         CONFIG.C_NUM_PROBE_IN {0} \
                   ] [get_ips $ipName]
} elseif {$::env(BOARD) eq "genesys2"} {
set_property -dict [list CONFIG.C_NUM_PROBE_OUT {3} \
                         CONFIG.C_PROBE_OUT0_INIT_VAL {0x0} \
                         CONFIG.C_PROBE_OUT1_INIT_VAL {0x0} \
                         CONFIG.C_PROBE_OUT2_INIT_VAL {0x0} \
                         CONFIG.C_PROBE_OUT1_WIDTH {2} \
                         CONFIG.C_EN_PROBE_IN_ACTIVITY {0} \
                         CONFIG.C_NUM_PROBE_IN {0} \
                   ] [get_ips $ipName]
}

generate_target {instantiation_template} [get_files ./$ipName.srcs/sources_1/ip/$ipName/$ipName.xci]
generate_target all [get_files  ./$ipName.srcs/sources_1/ip/$ipName/$ipName.xci]
create_ip_run [get_files -of_objects [get_fileset sources_1] ./$ipName.srcs/sources_1/ip/$ipName/$ipName.xci]
launch_run -jobs 8 ${ipName}_synth_1
wait_on_run ${ipName}_synth_1
