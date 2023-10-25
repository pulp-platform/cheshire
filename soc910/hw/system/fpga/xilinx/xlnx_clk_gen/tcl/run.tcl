set partNumber $::env(XILINX_PART)
set boardName  $::env(XILINX_BOARD)

set ipName xlnx_clk_gen

create_project $ipName . -force -part $partNumber
set_property board_part $boardName [current_project]

create_ip -name clk_wiz -vendor xilinx.com -library ip -module_name $ipName

# set_property -dict [list CONFIG.PRIM_IN_FREQ {200.000} \
#                         CONFIG.NUM_OUT_CLKS {4} \
#                         CONFIG.CLKOUT2_USED {true} \
#                         CONFIG.CLKOUT3_USED {true} \
#                         CONFIG.CLKOUT4_USED {true} \
#                         CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {50} \
#                         CONFIG.CLKOUT2_REQUESTED_OUT_FREQ {125} \
#                         CONFIG.CLKOUT3_REQUESTED_OUT_FREQ {125} \
#                         CONFIG.CLKOUT3_REQUESTED_PHASE {90.000} \
#                         CONFIG.CLKOUT4_REQUESTED_OUT_FREQ {50} \
#                         CONFIG.CLKIN1_JITTER_PS {50.0} \
#                        ] [get_ips $ipName]

set_property -dict [list CONFIG.CLK_IN1_BOARD_INTERFACE {default_100mhz_clk} \
                         CONFIG.CLKOUT2_USED {true} \
                         CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {40} \
                         CONFIG.CLKOUT2_REQUESTED_OUT_FREQ {250} \
                         CONFIG.PRIM_SOURCE {Differential_clock_capable_pin} \
                         CONFIG.MMCM_CLKFBOUT_MULT_F {12.500} \
                         CONFIG.MMCM_CLKOUT0_DIVIDE_F {31.250} \
                         CONFIG.MMCM_CLKOUT1_DIVIDE {5} \
                         CONFIG.NUM_OUT_CLKS {2} \
                         CONFIG.CLKOUT1_JITTER {133.842} \
                         CONFIG.CLKOUT1_PHASE_ERROR {84.520} \
                         CONFIG.CLKOUT2_JITTER {94.797} \
                         CONFIG.CLKOUT2_PHASE_ERROR {84.520}] [get_ips $ipName]

generate_target {instantiation_template} [get_files ./$ipName.srcs/sources_1/ip/$ipName/$ipName.xci]
generate_target all [get_files  ./$ipName.srcs/sources_1/ip/$ipName/$ipName.xci]
create_ip_run [get_files -of_objects [get_fileset sources_1] ./$ipName.srcs/sources_1/ip/$ipName/$ipName.xci]
launch_run -jobs 8 ${ipName}_synth_1
wait_on_run ${ipName}_synth_1
