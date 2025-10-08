# Copyright 2024 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: SHL-0.51
#
# Paul Scheffler <paulsc@iis.ee.ethz.ch>
# Yvan Tortorella <yvan.tortorella@gmail.com>

# genesys2 board params
set bpart(genesys2) "digilentinc.com:genesys2:part0:1.1"
set fpart(genesys2) "xc7k325tffg900-2"
set hwdev(genesys2) "xc7k325t_0"
set cfgmp(genesys2) "s25fl256sxxxxxx0-spi-x1_x2_x4"

# vcu128 board params
set bpart(vcu128) "xilinx.com:vcu128:part0:1.0"
set fpart(vcu128) "xcvu37p-fsvh2892-2L-e"
set hwdev(vcu128) "xcvu37p_0"
set cfgmp(vcu128) "mt25qu02g-spi-x1_x2_x4"

# vcu118 board params
set bpart(vcu118) "xilinx.com:vcu118:part0:2.4"
set fpart(vcu118) "xcvu9p-flga2104-2L-e"
set hwdev(vcu118) "xcvu9p_0"
set cfgmp(vcu118) "mt25qu01g-spi-x1_x2_x4"


# Initialize an implementation project
proc init_impl {xilinx_root argc argv} {
    global fpart
    global bpart
    # We declare these variables into the global context
    global num_threads
    global num_jobs
    global project_root
    global board
    global proj
    # Check argument count
    if { $argc < 2 } {
        puts "Error: Insufficient implementation arguments (${argc}): ${argv}."
        return -code error
    }
    # Configure parallelism
    set num_threads 8
    set num_jobs 8
    # Get arguments
    set board [lindex $argv 0]
    set proj [lindex $argv 1]
    # Set up multithreading
    set_param general.maxThreads $num_threads
    # Remove prior build
    set project_root ${xilinx_root}/build/${board}.${proj}
    file delete -force [glob -nocomplain ${project_root}/*]
    # Create project
    create_project $proj $project_root -force -part $fpart($board)
    set_property board_part $bpart($board) [current_project]
}

# Open a target device in the hardware manager
proc open_target {xilinx_root argc argv suffix} {
    global hwdev
    # We declare these variables into the global context
    global project_root
    global board
    global hw_tgt
    global hw_device
    # Check argument count
    if { $argc < 3 } {
        puts "Error: Insufficient target arguments (${argc}): ${argv}."
        return -code error
    }
    # Get arguments
    set url [lindex $argv 0]
    set path [lindex $argv 1]
    set board [lindex $argv 2]
    # Remove prior build
    set project_root ${xilinx_root}/build/${board}.${suffix}
    file delete -force [glob -nocomplain ${project_root}/*]
    # Connect to HW server
    open_hw_manager
    connect_hw_server -url $url
    # Open HW target, set JTAG frequency
    set hw_tgts [get_hw_targets ${url}/${path}]
    # From all matching targets, choose last (most specific) one
    set hw_tgt [lindex ${hw_tgts} [expr { [llength ${hw_tgts}] - 1 }]]
    open_hw_target $hw_tgt
    set_property PARAM.FREQUENCY 15000000 $hw_tgt
    # Get hardware device
    set hw_device [get_hw_devices $hwdev($board)]
}

# Exit if a project does not support a given board
proc no_cfg_exit {proj board} {
    puts "Error: Unsupported board ${board} for ${proj}."
    return -code error
}

# Create timing reports
proc gen_reports {rptdir} {
    file delete -force $rptdir
    file mkdir ${rptdir}
    # tclint-disable spacing, line-length
    check_timing             -file ${rptdir}/check_timing.rpt       -verbose
    report_timing            -file ${rptdir}/timing_worst_100.rpt   -max_paths 100 -nworst 100 -delay_type max -sort_by slack
    report_timing            -file ${rptdir}/timing_worst.rpt       -nworst 1 -delay_type max -sort_by group
    report_utilization       -file ${rptdir}/utilization.rpt        -hierarchical
    report_cdc               -file ${rptdir}/cdc.rpt
    report_clock_interaction -file ${rptdir}/clock_interaction.rpt
    report_timing_summary    -file ${rptdir}/timing_summary.rpt
    # tclint-enable spacing, line-length
}

# Insert debug core and ILAs
proc insert_ilas {clk_net_name} {
    global project_root
    # Get nets to debug
    set debug_nets [lsort -dictionary [get_nets -hier -filter {MARK_DEBUG == 1}]]
    # Create debug core only if there are probes
    if { ![llength $debug_nets] } { return }
    # Create and configure debug core
    create_debug_core i_ila ila
    set_property -dict [list \
        ALL_PROBE_SAME_MU {true} ALL_PROBE_SAME_MU_CNT {4} C_ADV_TRIGGER {true} \
        C_DATA_DEPTH {16384} C_EN_STRG_QUAL {true} C_INPUT_PIPE_STAGES {0} \
        C_TRIGIN_EN {false} C_TRIGOUT_EN {false} \
        ] [get_debug_cores i_ila]
    # Connect SoC clock
    set_property port_width 1 [get_debug_ports i_ila/clk]
    connect_debug_port i_ila/clk [get_nets $clk_net_name]
    # Loop through debug nets (add extra list element to ensure last net is processed)
    set net_name_last ""
    set i 0
    foreach net [concat $debug_nets {""}] {
        # Remove trailing array index
        regsub {\[[0-9]*\]$} $net {} net_name
        # Create probe after all signals with the same name have been collected
        if { $net_name_last != $net_name } {
            if { $net_name_last != "" } {
                puts "Creating probe $i of width [llength $sig_list] for `$net_name_last`."
                # probe0 already exists, and does not need to be created
                if { $i != 0 } { create_debug_port i_ila probe }
                set_property port_width [llength $sig_list] [get_debug_ports i_ila/probe$i]
                set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports i_ila/probe$i]
                connect_debug_port i_ila/probe$i [get_nets $sig_list]
                incr i
            }
            set sig_list ""
        }
        lappend sig_list $net
        set net_name_last $net_name
    }
    # Save constraints, then implement the debug core
    save_constraints -force
    implement_debug_core
}
