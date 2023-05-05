# Copyright 2020 ETH Zurich and University of Bologna.
# Solderpad Hardware License, Version 0.51, see LICENSE for details.
# SPDX-License-Identifier: SHL-0.51
#
# Cyril Koenig <cykoenig@iis.ee.ethz.ch>

# Create project
set project $::env(XILINX_PROJECT)

create_project $project ./$project -force -part $::env(XILINX_PART)
set_property board_part $::env(XILINX_BOARD_LONG) [current_project]
set_property XPM_LIBRARIES XPM_MEMORY [current_project]

# set number of threads to 8 (maximum, unfortunately)
set_param general.maxThreads 8

# Define sources
set_property ip_repo_paths ./cheshire_ip [current_project]
update_ip_catalog

import_files -fileset constrs_1 -norecurse constraints/$::env(XILINX_BOARD).xdc

source scripts/cheshire_bd_$::env(XILINX_BOARD).tcl

source scripts/add_includes.tcl

# Add the ext_jtag pins to block design
if {[info exists ::env(GEN_EXT_JTAG)] && ($::env(GEN_EXT_JTAG)==1)} {
  source scripts/cheshire_bd_ext_jtag.tcl
  import_files -fileset constrs_1 -norecurse constraints/$::env(XILINX_BOARD)_ext_jtag.xdc
}

make_wrapper -files [get_files $project/$project.srcs/sources_1/bd/design_1/design_1.bd] -top
add_files -norecurse $project/$project.gen/sources_1/bd/design_1/hdl/design_1_wrapper.v

# Create OOC runs
generate_target all [get_files *design_1.bd]
export_ip_user_files -of_objects  [get_files *design_1.bd] -no_script
create_ip_run [get_files *design_1.bd]

# Start OOC synthesis of changed IPs
set synth_runs [get_runs *synth*]
# Exclude the whole design (synth_1) and the cheshire IP (bug)
set all_ooc_synth [lsearch -regexp -all -inline -not $synth_runs {^synth_1$|cheshire}]
set runs_queued {}
foreach run $all_ooc_synth {
    if {[get_property PROGRESS [get_run $run]] != "100%"} {
        puts "Launching run $run"
        lappend runs_queued $run
        # Default synthesis strategy
        set_property strategy Flow_RuntimeOptimized [get_runs $run]
    } else {
        puts "Skipping 100% complete run: $run"
    }
}
if {[llength $runs_queued] != 0} {
    reset_run $runs_queued
    launch_runs $runs_queued -jobs 16
    puts "Waiting on $runs_queued"
    foreach run $runs_queued {
        wait_on_run $run
    }
    # reset main synthesis
    reset_run synth_1
}

set_property strategy Flow_RuntimeOptimized [get_runs synth_1]
set_property strategy Flow_RuntimeOptimized [get_runs impl_1]

set_property STEPS.SYNTH_DESIGN.ARGS.RETIMING true [get_runs synth_1]
# Enable sfcu due to package conflicts
set_property -name {STEPS.SYNTH_DESIGN.ARGS.MORE OPTIONS} -value {-sfcu} -objects [get_runs synth_1]

launch_runs synth_1
wait_on_run synth_1
open_run synth_1 -name synth_1

# Instantiate ILA
set DEBUG [llength [get_nets -hier -filter {MARK_DEBUG == 1}]]
if ($DEBUG) {
  # Create core
  puts "Creating debug core..."
  create_debug_core u_ila_0 ila
  set_property -dict "ALL_PROBE_SAME_MU true ALL_PROBE_SAME_MU_CNT 4 C_ADV_TRIGGER true C_DATA_DEPTH 16384 \
   C_EN_STRG_QUAL true C_INPUT_PIPE_STAGES 0 C_TRIGIN_EN false C_TRIGOUT_EN false" [get_debug_cores u_ila_0]
  ## Clock
  set_property port_width 1 [get_debug_ports u_ila_0/clk]
  connect_debug_port u_ila_0/clk [get_nets design_1_i/clk_wiz_0_clk_50]
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
  set_property target_constrs_file [get_files $::env(XILINX_BOARD).xdc] [current_fileset -constrset]
  save_constraints -force
  implement_debug_core
  write_debug_probes -force probes.ltx
}

# Incremental implementation
if {[info exists ::env(ROUTED_DCP)] && [file exists $::env(ROUTED_DCP)]} {
  set_property incremental_checkpoint $::env(ROUTED_DCP) [get_runs impl_1]
}

# Implementation
launch_runs impl_1
wait_on_run impl_1
launch_runs impl_1 -to_step write_bitstream
wait_on_run impl_1
