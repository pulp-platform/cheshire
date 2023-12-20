# Copyright 2022 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
#
# Nicole Narr <narrn@student.ethz.ch>
# Christopher Reinwardt <creinwar@student.ethz.ch>
# Alessandro Ottaviano <aottaviano@iis.ee.ethz.ch>
# Paul Scheffler <paulsc@iis.ee.ethz.ch>

set TESTBENCH tb_cheshire_soc

# Set voptargs only if not already set to make overridable.
# Default on fast simulation flags.
# if {![info exists VOPTARGS]} {
#     set VOPTARGS "-O5 +acc=p+tb_cheshire_soc. +noacc=p+cheshire_soc. +acc=r+stream_xbar"
# }

if {![info exists VOPTARGS]} {
    set VOPTARGS "+acc"
}


set flags "-permissive -suppress 3009 -suppress 8386 -error 7 "
if {[info exists SELCFG]} { append flags "-GSelectedCfg=${SELCFG} " }

set pargs ""
if {[info exists BOOTMODE]} { append pargs "+BOOTMODE=${BOOTMODE} " }
if {[info exists PRELMODE]} { append pargs "+PRELMODE=${PRELMODE} " }
if {[info exists BINARY]}   { append pargs "+BINARY=${BINARY} " }
if {[info exists IMAGE]}    { append pargs "+IMAGE=${IMAGE} " }

set questa-cmd "-gblso ../src/riscv-isa-sim/install/lib/libriscv.so \
                -gblso /usr/pack/riscv-1.0-kgf/riscv64-gcc-11.2.0/lib/libfesvr.so \
                -sv_lib ../../../work-dpi/ariane_dpi"

set questa-define "+define+SPIKE_TANDEM"

eval "vsim -c ${TESTBENCH} -t 1ps -vopt -voptargs=\"${VOPTARGS}\"" ${pargs} ${flags} ${questa-define} ${questa-cmd}

set StdArithNoWarnings 1
set NumericStdNoWarnings 1
