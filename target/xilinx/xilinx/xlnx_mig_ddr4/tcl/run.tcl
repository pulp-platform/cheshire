# Copyright 2018 ETH Zurich and University of Bologna.
# Solderpad Hardware License, Version 0.51, see LICENSE for details.
# SPDX-License-Identifier: SHL-0.51
#

set partNumber $::env(XILINX_PART)
set boardName  $::env(XILINX_BOARD)

set ipName xlnx_mig_ddr4

create_project $ipName . -force -part $partNumber
set_property board_part $boardName [current_project]

create_ip -name ddr4 -vendor xilinx.com -library ip -version 2.2 -module_name $ipName

# Note DDR4_AxiAddressWidth {30} is non supported

set_property -dict [list CONFIG.C0.DDR4_AxiSelection {true} \
                         CONFIG.C0.DDR4_AxiDataWidth {64} \
                         CONFIG.C0.DDR4_AxiAddressWidth {32} \
                         CONFIG.C0.DDR4_AxiIDWidth {6} \
                         CONFIG.C0.DDR4_AxiNarrowBurst {0} \
                         CONFIG.C0.DDR4_Clamshell {true} \
                         CONFIG.C0_DDR4_BOARD_INTERFACE {ddr4_sdram} \
                         CONFIG.C0_CLOCK_BOARD_INTERFACE {default_100mhz_clk} \
                         CONFIG.RESET_BOARD_INTERFACE {Custom} \
                         CONFIG.ADDN_UI_CLKOUT1_FREQ_HZ {200} \
                   ] [get_ips $ipName]

generate_target {instantiation_template} [get_files ./$ipName.srcs/sources_1/ip/$ipName/$ipName.xci]
generate_target all [get_files  ./$ipName.srcs/sources_1/ip/$ipName/$ipName.xci]
create_ip_run [get_files -of_objects [get_fileset sources_1] ./$ipName.srcs/sources_1/ip/$ipName/$ipName.xci]
launch_run -jobs 8 ${ipName}_synth_1
wait_on_run ${ipName}_synth_1