# Copyright 2022 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
#
# Nicole Narr <narrn@student.ethz.ch>
# Christopher Reinwardt <creinwar@student.ethz.ch>
# Alessandro Ottaviano <aottaviano@iis.ee.ethz.ch>
# Paul Scheffler <paulsc@iis.ee.ethz.ch>

set TESTBENCH tb_cheshire_soc
set SDF_PATH /scratch2/zexifu/cheshire_try_bak/cva6pp_gf22/gf22/synopsys/runs/c910__T1000___17_47_59__28_04_2024/c910_axi_wrap_synth.sdf   

# Set voptargs only if not already set to make overridable.
# Default on fast simulation flags.
# if {![info exists VOPTARGS]} {
#     set VOPTARGS "-O5 +acc=p+tb_cheshire_soc. +noacc=p+cheshire_soc. +acc=r+stream_xbar"
# }

if {![info exists VOPTARGS]} {
    set VOPTARGS "+acc"
}


set flags "-permissive -suppress 3009 -suppress 8386 -suppress 12090 -error 7 "
if {[info exists SELCFG]} { append flags "-GSelectedCfg=${SELCFG} " }

set pargs ""
if {[info exists BOOTMODE]} { append pargs "+BOOTMODE=${BOOTMODE} " }
if {[info exists PRELMODE]} { append pargs "+PRELMODE=${PRELMODE} " }
if {[info exists BINARY]}   { append pargs "+BINARY=${BINARY} " }
if {[info exists BINARY2]}   { append pargs "+BINARY2=${BINARY2} " }
if {[info exists BINARY3]}   { append pargs "+BINARY3=${BINARY3} " }
if {[info exists IMAGE]}    { append pargs "+IMAGE=${IMAGE} " }
# +PRELOAD=/scratch/zexifu/c910_sw/cheshire_3/sw/deps/cva6-sdk/install64/spike_fw_payload.elf
# +PRELOAD=/scratch/zexifu/c910_pulp/merge_with_cyril/cheshire_with_c910/hw/riscv-tests/isa/rv64ua-p-amoor_d_aqrl
set questa-cmd ""

set questa-define ""

eval "vsim -c ${TESTBENCH} -t 1ps -vopt -voptargs=\"${VOPTARGS}\"" ${pargs} ${flags} ${questa-define} ${questa-cmd}
# eval "vsim -c ${TESTBENCH} -t 1ps -vopt -voptargs=\"${VOPTARGS}\"" ${pargs} ${flags} ${questa-define} ${questa-cmd} -sdfmax /tb_cheshire_soc/fix/dut/gen_cva6_cores[0]/gen_c910_core/i_c910_axi_wrap=${SDF_PATH} +sdf_verbose

set StdArithNoWarnings 1
set NumericStdNoWarnings 1
