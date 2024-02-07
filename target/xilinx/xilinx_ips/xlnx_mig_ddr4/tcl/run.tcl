# Copyright 2023 ETH Zurich and University of Bologna.
# Solderpad Hardware License, Version 0.51, see LICENSE for details.
# SPDX-License-Identifier: SHL-0.51
#
# Cyril Koenig <cykoenig@iis.ee.ethz.ch>

set partNumber $::env(xilinx_part)
set boardName  $::env(xilinx_board_long)

set ipName xlnx_mig_ddr4

create_project $ipName . -force -part $partNumber
set_property board_part $boardName [current_project]

create_ip -name ddr4 -vendor xilinx.com -library ip -version 2.2 -module_name $ipName


if {$::env(chs_xilinx_board) eq "vcu128"} {
  set_property -dict [list CONFIG.C0.DDR4_Clamshell {true} \
                           CONFIG.C0_DDR4_BOARD_INTERFACE {ddr4_sdram} \
                           CONFIG.System_Clock {No_Buffer} \
                           CONFIG.Reference_Clock {No_Buffer} \
                           CONFIG.C0.DDR4_InputClockPeriod {10000} \
                           CONFIG.C0.DDR4_CLKOUT0_DIVIDE {3} \
                           CONFIG.C0.DDR4_MemoryPart {MT40A512M16HA-075E} \
                           CONFIG.C0.DDR4_DataWidth {72} \
                           CONFIG.C0.DDR4_DataMask {NO_DM_NO_DBI} \
                           CONFIG.C0.DDR4_Ecc {true} \
                           CONFIG.C0.DDR4_AxiDataWidth {512} \
                           CONFIG.C0.DDR4_AxiAddressWidth {32} \
                           CONFIG.C0.DDR4_AxiIDWidth {8} \
                           CONFIG.ADDN_UI_CLKOUT1_FREQ_HZ {100} \
                           CONFIG.C0.BANK_GROUP_WIDTH {1} \
                           CONFIG.C0.CS_WIDTH {2} \
                           CONFIG.C0.DDR4_AxiSelection {true} \
                      ] [get_ips $ipName]
}


generate_target {instantiation_template} [get_files ./$ipName.srcs/sources_1/ip/$ipName/$ipName.xci]
generate_target all [get_files  ./$ipName.srcs/sources_1/ip/$ipName/$ipName.xci]
create_ip_run [get_files -of_objects [get_fileset sources_1] ./$ipName.srcs/sources_1/ip/$ipName/$ipName.xci]
launch_run -jobs 8 ${ipName}_synth_1
wait_on_run ${ipName}_synth_1
