# Copyright 2026 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
#
# Questa simulation of `cheshire_asic_top` in Cheshire's VIP
# (`tb_cheshire_asic_top`): the RTL top, or a netlist of it with the
# technology's simulation models (library `gate`), without delays (zero-delay
# functional simulation). Runs in the simulation directory; parameters (asic.mk):
#   CHS_SIM_COMPILE     Bender-generated compile script of Cheshire's RTL, VIP
#                       and testbench
#   CHS_SIM_NETLIST     netlist of cheshire_asic_top, or empty for the RTL top
#   CHS_SIM_MODELS      script compiling the technology's simulation models for
#                       the netlist (cells, memory macros) into the library `gate`
#   CHS_SIM_GATE_VOPT   file of further vopt arguments for the netlist from the
#                       technology, or empty
#   CHS_SIM_BINARY, CHS_SIM_BOOTMODE, CHS_SIM_PRELMODE   program and boot (see
#                       tb_cheshire_asic_top)
#   CHS_SIM_CXX         C++ compiler of the testbench's DPI code (the one the
#                       compile script uses)
#   CHS_SIM_CLK_PERIOD  system clock period [ps]: the implemented one, so that
#                       recorded activity has the implemented toggle rates
#   CHS_SIM_SAIF        1: record the DUT's switching activity per workload phase
#                       into saif/phase_<marker>.saif; a phase lasts while the
#                       program holds a nonzero marker on the GPIO outputs

if { [file isdirectory work] } { file delete -force work }
vlib work
source ${CHS_SIM_COMPILE}

# Activity recording reads every net of the DUT
if { ${CHS_SIM_SAIF} } { set acc np } else { set acc p }
set voptargs "-O5 +acc=${acc}+tb_cheshire_asic_top. -permissive"
set libargs ""
if { ${CHS_SIM_NETLIST} ne "" } {
    # The netlist and the models form their own library, searched first, so it
    # binds the DUT and everything below it. Elaborating the netlist's top in
    # this library alone proves the netlist complete, so every module of the
    # DUT comes from the netlist or the models.
    if { [file isdirectory gate] } { file delete -force gate }
    vlib gate
    source ${CHS_SIM_MODELS}
    vlog -work gate -timescale 1ps/1ps ${CHS_SIM_NETLIST}
    if { [catch { vopt -work gate cheshire_asic_top -o cheshire_asic_top_check }] } {
        echo "Error: the netlist does not elaborate with the models alone"
        quit -f -code 1
    }
    append voptargs " +nospecify +notimingchecks"
    if { ${CHS_SIM_GATE_VOPT} ne "" } {
        set fh [open ${CHS_SIM_GATE_VOPT}]
        append voptargs " [join [split [string trim [read $fh]]] { }]"
        close $fh
    }
    set libargs "-Lf gate"
}

# The testbench's time unit is 1 ps (asic.mk), so the period is passed as is
vsim -c tb_cheshire_asic_top -t 1ps {*}${libargs} -voptargs=${voptargs} \
    -GClkPeriodSys=${CHS_SIM_CLK_PERIOD} \
    +BOOTMODE=${CHS_SIM_BOOTMODE} +PRELMODE=${CHS_SIM_PRELMODE} +BINARY=${CHS_SIM_BINARY} \
    -suppress 3009 -suppress 8386 -error 7 -cpppath ${CHS_SIM_CXX}
set StdArithNoWarnings 1
set NumericStdNoWarnings 1

# Each change of the GPIO marker ends the running phase (writing its activity)
# and, if the new marker is nonzero, starts the next one. Questa counts from
# the first `power add` (the first phase) and restarts the counts with
# `power reset -all`, but always writes the time since that first add as the
# SAIF's DURATION: each file gets its phase's length instead.
proc chs_saif_end { } {
    set file saif/phase_${::chs_saif_phase}.saif
    power report -all -bsaif ${file}
    set fh [open ${file}]
    set saif [read ${fh}]
    close ${fh}
    regsub {\(DURATION [0-9]+\)} ${saif} "(DURATION [expr { $::now - $::chs_saif_start }])" saif
    set fh [open ${file} w]
    puts -nonewline ${fh} ${saif}
    close ${fh}
    echo "\[SAIF\] Phase ${::chs_saif_phase} ends at $::now ps: ${file}"
    set ::chs_saif_phase ""
}
if { ${CHS_SIM_SAIF} } {
    file mkdir saif
    set ::chs_saif_phase ""
    set ::chs_saif_added 0
    when -label chs_saif {/tb_cheshire_asic_top/fix/gpio_o'event} {
        if { $::chs_saif_phase ne "" } { chs_saif_end }
        set marker [examine -radix hex /tb_cheshire_asic_top/fix/gpio_o]
        if { [regexp {^0*([1-9a-fA-F][0-9a-fA-F]*)$} $marker -> phase] } {
            if { $::chs_saif_added } {
                power reset -all
            } else {
                power add -nocellnet -r -in -out -inout -internal /tb_cheshire_asic_top/fix/dut/*
                set ::chs_saif_added 1
            }
            set ::chs_saif_phase ${phase}
            set ::chs_saif_start $::now
            echo "\[SAIF\] Phase ${phase} starts at $::now ps"
        }
    }
}
run -all
quit -f
