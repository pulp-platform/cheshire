# Copyright 2018 ETH Zurich and University of Bologna.
# Solderpad Hardware License, Version 0.51, see LICENSE for details.
# SPDX-License-Identifier: SHL-0.51
#
# Author: Florian Zaruba <zarubaf@iis.ee.ethz.ch>

# hard-coded to Genesys 2 for the moment

# Contraints files selection
switch $::env(BOARD) {
  "genesys2" - "kc705" - "vc707" - "vcu128" {
    add_files -fileset constrs_1 -norecurse constraints/$::env(BOARD).xdc
    #import_files -fileset constrs_1 constraints/$::env(BOARD).xdc
    #set_property used_in_synthesis false [get_files cheshire.srcs/constrs_1/imports/constraints/$::env(BOARD).xdc]
  }
  default {
      exit 1
  }
}

# Ips selection
switch $::env(BOARD) {
  "genesys2" - "kc705" - "vc707" {
    set ips { "xilinx/xlnx_mig_7_ddr3/xlnx_mig_7_ddr3.srcs/sources_1/ip/xlnx_mig_7_ddr3/xlnx_mig_7_ddr3.xci" }
  }
  "vcu128" {
    set ips { "xilinx/xlnx_mig_ddr4/xlnx_mig_ddr4.srcs/sources_1/ip/xlnx_mig_ddr4/xlnx_mig_ddr4.xci" }
  }
  default {
    set ips {}
  }
}

import_ip $ips

source scripts/add_sources.tcl

set_property top ${project}_top_xilinx [current_fileset]

update_compile_order -fileset sources_1

add_files -fileset constrs_1 -norecurse constraints/$project.xdc

set_property strategy Flow_RuntimeOptimized [get_runs synth_1]
set_property strategy Flow_RuntimeOptimized [get_runs impl_1]

set_property XPM_LIBRARIES XPM_MEMORY [current_project]

synth_design -rtl -name rtl_1

set_property STEPS.SYNTH_DESIGN.ARGS.RETIMING true [get_runs synth_1]

# Synthesis
launch_runs synth_1
wait_on_run synth_1
open_run synth_1 -name synth_1

exec mkdir -p reports/
exec rm -rf reports/*

check_timing -verbose                                                   -file reports/$project.check_timing.rpt
report_timing -max_paths 100 -nworst 100 -delay_type max -sort_by slack -file reports/$project.timing_WORST_100.rpt
report_timing -nworst 1 -delay_type max -sort_by group                  -file reports/$project.timing.rpt
report_utilization -hierarchical                                        -file reports/$project.utilization.rpt
report_cdc                                                              -file reports/$project.cdc.rpt
report_clock_interaction                                                -file reports/$project.clock_interaction.rpt

# Ddr specific ips
set ddr_constraints "/scratch2/cykoenig/education/cheshire/target/xilinx/constraints/dram/xlnx_mig_ddr4.xdc"

set argv [list $ddr_constraints i_dram]
set argc 2
source scripts/connect_ip.tcl
read_xdc $ddr_constraints

# Instantiate ILA
set DEBUG [llength [get_nets -hier -filter {MARK_DEBUG == 1}]]
set DEBUG 0
if ($DEBUG) {
    # Create core
    puts "Creating debug core..."
    create_debug_core u_ila_0 ila
    set_property -dict "ALL_PROBE_SAME_MU true ALL_PROBE_SAME_MU_CNT 4 C_ADV_TRIGGER true C_DATA_DEPTH 16384 \
     C_EN_STRG_QUAL true C_INPUT_PIPE_STAGES 0 C_TRIGIN_EN false C_TRIGOUT_EN false" [get_debug_cores u_ila_0]
    ## Clock
    set_property port_width 1 [get_debug_ports u_ila_0/clk]
    connect_debug_port u_ila_0/clk [get_pins i_sys_clk_div/i_clk_bypass_mux/i_BUFGMUX/O]
    # Get nets to debug
    set debugNets [lsort -dictionary [get_nets -hier -filter {MARK_DEBUG == 1}]]
    set netNameLast ""
    set probe_i 0
    # Loop through all nets (add extra list element to ensure last net is processed)
    foreach net [concat $debugNets {""}] {
        # Remove trailing array index
        regsub {\[[0-9]*\]$} $net {} netName
        # Create probe after all signals with the same name have been collected
        if {$netNameLast != $netName} {
            if {$netNameLast != ""} {
                puts "Creating probe $probe_i with width [llength $sigList] for signal '$netNameLast'"
                # probe0 already exists, and does not need to be created
                if {$probe_i != 0} {
                    create_debug_port u_ila_0 probe
                }
                set_property port_width [llength $sigList] [get_debug_ports u_ila_0/probe$probe_i]
                set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe$probe_i]
                connect_debug_port u_ila_0/probe$probe_i [get_nets $sigList]
                incr probe_i
            }
            set sigList ""
        }
        lappend sigList $net
        set netNameLast $netName
    }
    # Need to save save constraints before implementing the core
    set_property target_constrs_file cheshire.srcs/constrs_1/imports/constraints/$::env(BOARD).xdc [current_fileset -constrset]
    save_constraints -force
    implement_debug_core
    write_debug_probes -force probes.ltx
}

# Implementation
launch_runs impl_1
wait_on_run impl_1
launch_runs impl_1 -to_step write_bitstream
wait_on_run impl_1

# Check timing constraints
open_run impl_1
set timingrep [report_timing_summary -no_header -no_detailed_paths -return_string]
if {! [string match -nocase {*timing constraints are met*} $timingrep]} {
  send_msg_id {USER 1-1} ERROR {Timing constraints were not met.}
  return -code error
}

# Output Verilog netlist + SDC for timing simulation
write_verilog -force -mode funcsim out/${project}_funcsim.v
write_verilog -force -mode timesim out/${project}_timesim.v
write_sdf     -force out/${project}_timesim.sdf

# Reports
exec mkdir -p reports/
exec rm -rf reports/*
check_timing                                                              -file reports/${project}.check_timing.rpt
report_timing -max_paths 100 -nworst 100 -delay_type max -sort_by slack   -file reports/${project}.timing_WORST_100.rpt
report_timing -nworst 1 -delay_type max -sort_by group                    -file reports/${project}.timing.rpt
report_utilization -hierarchical                                          -file reports/${project}.utilization.rpt