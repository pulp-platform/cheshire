# Copyright 2024 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: SHL-0.51
#
# Florian Zaruba <zarubaf@iis.ee.ethz.ch>
# Cyril Koenig <cykoenig@iis.ee.ethz.ch>
# Paul Scheffler <paulsc@iis.ee.ethz.ch>
# Yvan Tortorella <yvan.tortorella@gmail.com>

# Initialize implementation
set xilinx_root [file dirname [file dirname [file normalize [info script]]]]
source ${xilinx_root}/scripts/common.tcl
init_impl $xilinx_root $argc $argv

# Create and configure selected IP
switch $proj {

    clkwiz {
        create_ip -name clk_wiz -vendor xilinx.com -library ip -version 6.0 -module_name $proj
        switch $board {
            genesys2 {
                set_property -dict [list \
                    CONFIG.PRIM_SOURCE {No_buffer} \
                    CONFIG.PRIM_IN_FREQ {200.000} \
                    CONFIG.CLKOUT1_USED {true} \
                    CONFIG.CLKOUT2_USED {true} \
                    CONFIG.CLKOUT3_USED {true} \
                    CONFIG.CLKOUT4_USED {true} \
                    CONFIG.CLK_OUT1_PORT {clk_50} \
                    CONFIG.CLK_OUT2_PORT {clk_48} \
                    CONFIG.CLK_OUT3_PORT {clk_20} \
                    CONFIG.CLK_OUT4_PORT {clk_10} \
                    CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {50.000} \
                    CONFIG.CLKOUT2_REQUESTED_OUT_FREQ {48.000} \
                    CONFIG.CLKOUT3_REQUESTED_OUT_FREQ {20.000} \
                    CONFIG.CLKOUT4_REQUESTED_OUT_FREQ {10.000} \
                    CONFIG.CLKIN1_JITTER_PS {50.0} \
                    CONFIG.MMCM_CLKFBOUT_MULT_F {6.000} \
                    CONFIG.MMCM_CLKIN1_PERIOD {5.000} \
                    CONFIG.MMCM_CLKOUT1_DIVIDE {24} \
                    CONFIG.MMCM_CLKOUT2_DIVIDE {25} \
                    CONFIG.MMCM_CLKOUT3_DIVIDE {60} \
                    CONFIG.MMCM_CLKOUT4_DIVIDE {120} \
                    CONFIG.NUM_OUT_CLKS {4} \
                    CONFIG.CLKOUT1_JITTER {112.316} \
                    CONFIG.CLKOUT1_PHASE_ERROR {89.971} \
                    CONFIG.CLKOUT2_JITTER {129.198} \
                    CONFIG.CLKOUT2_PHASE_ERROR {89.971} \
                    CONFIG.CLKOUT3_JITTER {155.330} \
                    CONFIG.CLKOUT3_PHASE_ERROR {89.971} \
                    CONFIG.CLKOUT4_JITTER {178.053} \
                    CONFIG.CLKOUT4_PHASE_ERROR {89.971} \
                    ] [get_ips $proj]
            }
            vcu128 {
                set_property -dict [list \
                    CONFIG.CLK_IN1_BOARD_INTERFACE {Custom} \
                    CONFIG.RESET_BOARD_INTERFACE {Custom} \
                    CONFIG.USE_RESET {true} \
                    CONFIG.PRIM_SOURCE {No_buffer} \
                    CONFIG.PRIM_IN_FREQ {100.000} \
                    CONFIG.CLKOUT1_USED {true} \
                    CONFIG.CLKOUT2_USED {true} \
                    CONFIG.CLKOUT3_USED {true} \
                    CONFIG.CLKOUT4_USED {true} \
                    CONFIG.CLK_OUT1_PORT {clk_50} \
                    CONFIG.CLK_OUT2_PORT {clk_48} \
                    CONFIG.CLK_OUT3_PORT {clk_20} \
                    CONFIG.CLK_OUT4_PORT {clk_10} \
                    CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {50.000} \
                    CONFIG.CLKOUT2_REQUESTED_OUT_FREQ {48.000} \
                    CONFIG.CLKOUT3_REQUESTED_OUT_FREQ {20.000} \
                    CONFIG.CLKOUT4_REQUESTED_OUT_FREQ {10.000} \
                    CONFIG.MMCM_CLKFBOUT_MULT_F {12.000} \
                    CONFIG.MMCM_CLKIN1_PERIOD {5.000} \
                    CONFIG.MMCM_CLKOUT1_DIVIDE {24} \
                    CONFIG.MMCM_CLKOUT2_DIVIDE {25} \
                    CONFIG.MMCM_CLKOUT3_DIVIDE {60} \
                    CONFIG.MMCM_CLKOUT4_DIVIDE {120} \
                    CONFIG.NUM_OUT_CLKS {4} \
                    CONFIG.CLKOUT1_JITTER {112.316} \
                    CONFIG.CLKOUT1_PHASE_ERROR {89.971} \
                    CONFIG.CLKOUT2_JITTER {129.198} \
                    CONFIG.CLKOUT2_PHASE_ERROR {89.971} \
                    CONFIG.CLKOUT3_JITTER {155.330} \
                    CONFIG.CLKOUT3_PHASE_ERROR {89.971} \
                    CONFIG.CLKOUT4_JITTER {178.053} \
                    CONFIG.CLKOUT4_PHASE_ERROR {89.971} \
                    ] [get_ips $proj]
            }
            vcu118 {
                set_property -dict [list \
                    CONFIG.CLK_IN1_BOARD_INTERFACE {Custom} \
                    CONFIG.RESET_BOARD_INTERFACE {Custom} \
                    CONFIG.USE_RESET {true} \
                    CONFIG.PRIM_SOURCE {No_buffer} \
                    CONFIG.PRIM_IN_FREQ {250.000} \
                    CONFIG.CLKOUT1_USED {true} \
                    CONFIG.CLKOUT2_USED {true} \
                    CONFIG.CLKOUT3_USED {true} \
                    CONFIG.CLKOUT4_USED {true} \
                    CONFIG.CLK_OUT1_PORT {clk_50} \
                    CONFIG.CLK_OUT2_PORT {clk_48} \
                    CONFIG.CLK_OUT3_PORT {clk_20} \
                    CONFIG.CLK_OUT4_PORT {clk_10} \
                    CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {50.000} \
                    CONFIG.CLKOUT2_REQUESTED_OUT_FREQ {48.000} \
                    CONFIG.CLKOUT3_REQUESTED_OUT_FREQ {20.000} \
                    CONFIG.CLKOUT4_REQUESTED_OUT_FREQ {10.000} \
                    CONFIG.MMCM_CLKFBOUT_MULT_F {24.000} \
                    CONFIG.MMCM_CLKIN1_PERIOD {4.000} \
                    CONFIG.MMCM_CLKOUT0_DIVIDE_F {24.000} \
                    CONFIG.MMCM_CLKOUT1_DIVIDE {25} \
                    CONFIG.MMCM_CLKOUT2_DIVIDE {60} \
                    CONFIG.MMCM_CLKOUT3_DIVIDE {120} \
                    CONFIG.MMCM_CLKOUT4_DIVIDE {1} \
                    CONFIG.NUM_OUT_CLKS {4} \
                    CONFIG.CLKOUT1_JITTER {153.164} \
                    CONFIG.CLKOUT1_PHASE_ERROR {154.678} \
                    CONFIG.CLKOUT2_JITTER {154.376} \
                    CONFIG.CLKOUT2_PHASE_ERROR {154.678} \
                    CONFIG.CLKOUT3_JITTER {184.746} \
                    CONFIG.CLKOUT3_PHASE_ERROR {154.678} \
                    CONFIG.CLKOUT4_JITTER {213.887} \
                    CONFIG.CLKOUT4_PHASE_ERROR {154.678} \
                    ] [get_ips $proj]
            }
            default { nocfgexit $proj $board }
        }
    }

    vio {
        create_ip -name vio -vendor xilinx.com -library ip -version 3.0 -module_name $proj
        switch $board {
            genesys2 {
                set_property -dict [list \
                    CONFIG.C_NUM_PROBE_OUT {3} \
                    CONFIG.C_PROBE_OUT0_INIT_VAL {0x0} \
                    CONFIG.C_PROBE_OUT1_INIT_VAL {0x0} \
                    CONFIG.C_PROBE_OUT2_INIT_VAL {0x0} \
                    CONFIG.C_PROBE_OUT1_WIDTH {2} \
                    CONFIG.C_EN_PROBE_IN_ACTIVITY {0} \
                    CONFIG.C_NUM_PROBE_IN {0} \
                    ] [get_ips $proj]
            }
            vcu118 -
            vcu128 {
                set_property -dict [list \
                    CONFIG.C_NUM_PROBE_OUT {3} \
                    CONFIG.C_PROBE_OUT0_INIT_VAL {0x0} \
                    CONFIG.C_PROBE_OUT1_INIT_VAL {0x2} \
                    CONFIG.C_PROBE_OUT2_INIT_VAL {0x1} \
                    CONFIG.C_PROBE_OUT1_WIDTH {2} \
                    CONFIG.C_EN_PROBE_IN_ACTIVITY {0} \
                    CONFIG.C_NUM_PROBE_IN {0} \
                    ] [get_ips $proj]
            }
            default { nocfgexit $proj $board }
        }
    }

    mig7s {
        create_ip -name mig_7series -vendor xilinx.com -library ip -module_name $proj
        # Inject existing project file
        file copy ${xilinx_root}/src/ips/${board}.${proj}.prj \
            ${project_root}/${proj}.srcs/sources_1/ip/${proj}/mig_a.prj
        switch $board {
            genesys2 {
                set_property -dict [list \
                    CONFIG.XML_INPUT_FILE {mig_a.prj} \
                    CONFIG.RESET_BOARD_INTERFACE {Custom} \
                    CONFIG.MIG_DONT_TOUCH_PARAM {Custom} \
                    CONFIG.BOARD_MIG_PARAM {Custom} \
                    ] [get_ips $proj]
            }
            default { nocfgexit $proj $board }
        }
    }

    ddr4 {
        create_ip -name ddr4 -vendor xilinx.com -library ip -version 2.2 -module_name $proj
        switch $board {
            vcu128 {
                set_property -dict [list \
                    CONFIG.C0.DDR4_Clamshell {true} \
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
                    ] [get_ips $proj]
            }
            vcu118 {
                set_property -dict [list \
                    CONFIG.System_Clock {No_Buffer} \
                    CONFIG.Reference_Clock {No_Buffer} \
                    CONFIG.C0_DDR4_BOARD_INTERFACE {ddr4_sdram_c1_062} \
                    CONFIG.C0.DDR4_InputClockPeriod {4000} \
                    CONFIG.C0.DDR4_CLKOUT0_DIVIDE {5} \
                    CONFIG.C0.DDR4_MemoryPart {MT40A256M16LY-062E} \
                    CONFIG.C0.DDR4_TimePeriod {833} \
                    CONFIG.C0.DDR4_DataWidth {64} \
                    CONFIG.C0.DDR4_DataMask {DM_NO_DBI} \
                    CONFIG.C0.DDR4_MCS_ECC {false} \
                    CONFIG.C0.DDR4_CasWriteLatency {12} \
                    CONFIG.C0.DDR4_CasLatency {18} \
                    CONFIG.C0.DDR4_AxiDataWidth {512} \
                    CONFIG.C0.DDR4_AxiAddressWidth {31} \
                    CONFIG.C0.DDR4_AxiIDWidth {8} \
                    CONFIG.C0.BANK_GROUP_WIDTH {1} \
                    CONFIG.C0.DDR4_AxiSelection {true} \
                    ] [get_ips $proj]
            }
            default { nocfgexit $proj $board }
        }
    }

}

# Generate targets
set xci ${project_root}/${proj}.srcs/sources_1/ip/${proj}/${proj}.xci
generate_target all [get_files $xci]

# Synthesize proj
create_ip_run [get_files -of_objects [get_fileset sources_1] $xci]
launch_run -jobs $num_jobs ${proj}_synth_1
wait_on_run ${proj}_synth_1

# Symlink proj for easy access and build tracking, ensuring its update
file delete -force ${project_root}/out.xci
file link -symbolic ${project_root}/out.xci $xci
