set partNumber $::env(XILINX_PART)
set boardName  $::env(XILINX_BOARD)
set boardNameShort $::env(BOARD)

set ipName xlnx_hbm

create_project $ipName . -force -part $partNumber
set_property board_part $boardName [current_project]

create_ip -name hbm -vendor xilinx.com -library ip -module_name $ipName

set_property -dict [list CONFIG.USER_HBM_DENSITY {4GB} \
                         CONFIG.USER_HBM_STACK {1} \
                         CONFIG.USER_MEMORY_DISPLAY {4096} \
                         CONFIG.USER_SWITCH_ENABLE_01 {FALSE} \
                         CONFIG.USER_HBM_CP_1 {3} \
                         CONFIG.USER_HBM_RES_1 {11} \
                         CONFIG.USER_HBM_LOCK_REF_DLY_1 {10} \
                         CONFIG.USER_HBM_LOCK_FB_DLY_1 {10} \
                         CONFIG.USER_HBM_FBDIV_1 {5} \
                         CONFIG.USER_HBM_HEX_CP_RES_1 {0x0000B300} \
                         CONFIG.USER_HBM_HEX_LOCK_FB_REF_DLY_1 {0x00000a0a} \
                         CONFIG.USER_HBM_HEX_FBDIV_CLKOUTDIV_1 {0x00000142} \
                         CONFIG.USER_CLK_SEL_LIST0 {AXI_00_ACLK} \
                         CONFIG.USER_CLK_SEL_LIST1 {AXI_23_ACLK} \
                         CONFIG.USER_MC_ENABLE_01 {FALSE} \
                         CONFIG.USER_MC_ENABLE_02 {FALSE} \
                         CONFIG.USER_MC_ENABLE_03 {FALSE} \
                         CONFIG.USER_MC_ENABLE_04 {FALSE} \
                         CONFIG.USER_MC_ENABLE_05 {FALSE} \
                         CONFIG.USER_MC_ENABLE_06 {FALSE} \
                         CONFIG.USER_MC_ENABLE_07 {FALSE} \
                         CONFIG.USER_MC_ENABLE_08 {FALSE} \
                         CONFIG.USER_MC_ENABLE_09 {FALSE} \
                         CONFIG.USER_MC_ENABLE_10 {FALSE} \
                         CONFIG.USER_MC_ENABLE_11 {FALSE} \
                         CONFIG.USER_MC_ENABLE_12 {FALSE} \
                         CONFIG.USER_MC_ENABLE_13 {FALSE} \
                         CONFIG.USER_MC_ENABLE_14 {FALSE} \
                         CONFIG.USER_MC_ENABLE_15 {FALSE} \
                         CONFIG.USER_MC_ENABLE_APB_01 {FALSE} \
                         CONFIG.USER_SAXI_01 {false} \
                         CONFIG.USER_SAXI_02 {false} \
                         CONFIG.USER_SAXI_03 {false} \
                         CONFIG.USER_SAXI_04 {false} \
                         CONFIG.USER_SAXI_05 {false} \
                         CONFIG.USER_SAXI_06 {false} \
                         CONFIG.USER_SAXI_07 {false} \
                         CONFIG.USER_SAXI_08 {false} \
                         CONFIG.USER_SAXI_09 {false} \
                         CONFIG.USER_SAXI_10 {false} \
                         CONFIG.USER_SAXI_11 {false} \
                         CONFIG.USER_SAXI_12 {false} \
                         CONFIG.USER_SAXI_13 {false} \
                         CONFIG.USER_SAXI_14 {false} \
                         CONFIG.USER_SAXI_15 {false} \
                         CONFIG.USER_APB_EN {false} \
                         CONFIG.USER_AXI_CLK_FREQ {250} \
                         CONFIG.USER_AXI_INPUT_CLK_FREQ {250} \
                         CONFIG.USER_AXI_INPUT_CLK_NS {4.000} \
                         CONFIG.USER_AXI_INPUT_CLK_PS {4000} \
                         CONFIG.USER_AXI_INPUT_CLK_XDC {4.000} \
                         CONFIG.HBM_MMCM_FBOUT_MULT0 {4} \
                         CONFIG.USER_PHY_ENABLE_08 {FALSE} \
                         CONFIG.USER_PHY_ENABLE_09 {FALSE} \
                         CONFIG.USER_PHY_ENABLE_10 {FALSE} \
                         CONFIG.USER_PHY_ENABLE_11 {FALSE} \
                         CONFIG.USER_PHY_ENABLE_12 {FALSE} \
                         CONFIG.USER_PHY_ENABLE_13 {FALSE} \
                         CONFIG.USER_PHY_ENABLE_14 {FALSE} \
                         CONFIG.USER_PHY_ENABLE_15 {FALSE}] [get_ips $ipName]

generate_target {instantiation_template} [get_files ./$ipName.srcs/sources_1/ip/$ipName/$ipName.xci]
generate_target all [get_files  ./$ipName.srcs/sources_1/ip/$ipName/$ipName.xci]
create_ip_run [get_files -of_objects [get_fileset sources_1] ./$ipName.srcs/sources_1/ip/$ipName/$ipName.xci]
launch_run -jobs 8 ${ipName}_synth_1
wait_on_run ${ipName}_synth_1
