# Copyright 2022 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
#
# Nicole Narr <narrn@student.ethz.ch>
# Christopher Reinwardt <creinwar@student.ethz.ch>
# Alessandro Ottaviano <aottaviano@iis.ee.ethz.ch>
# Paul Scheffler <paulsc@iis.ee.ethz.ch>

set TESTBENCH tb_cheshire_soc

# Set full path to c++ compiler.
if { ![info exists CXX_PATH] } {
    if { ![info exists CXX] } {
        if { ![info exists ::env(CXX)] } {
            set CXX "g++"
        } else {
            set CXX $::env(CXX)
        }
    }
    set CXX_PATH [exec which $CXX]
}

# Set voptargs only if not already set to make overridable.
# Default on fast simulation flags.
if { ![info exists VOPTARGS] } {
    set VOPTARGS "-O5 +acc=npr+tb_cheshire_soc. +acc=npr+cheshire_soc. +acc=r+stream_xbar"
}

set flags "-permissive -suppress 3009 -suppress 8386 -error 7 -cpppath ${CXX_PATH} "
if { [info exists SELCFG] } { append flags "-GSelectedCfg=${SELCFG} " }

set pargs ""
if { [info exists BOOTMODE] } { append pargs "+BOOTMODE=${BOOTMODE} " }
if { [info exists PRELMODE] } { append pargs "+PRELMODE=${PRELMODE} " }
if { [info exists BINARY] } { append pargs "+BINARY=${BINARY} " }
if { [info exists IMAGE] } { append pargs "+IMAGE=${IMAGE} " }

# DRAMSys
if { [info exists USE_DRAMSYS] } {
    append flags "-GUseDramSys=${USE_DRAMSYS} "
    if { ${USE_DRAMSYS} } {
        set DRAMSYS_ROOT "../dramsys"
        set DRAMSYS_LIB "${DRAMSYS_ROOT}/build/lib"
        append flags "-sv_lib ${DRAMSYS_LIB}/libsystemc "
        append flags "-sv_lib ${DRAMSYS_LIB}/libDRAMSys_Simulator "
        append pargs "+DRAMSYS_RES=${DRAMSYS_ROOT}/configs "
    }
}

# tclint-disable-next-line command-args
eval "vsim -c ${TESTBENCH} -t 1ps -vopt -voptargs=\"${VOPTARGS}\"" ${pargs} ${flags}

set StdArithNoWarnings 1
set NumericStdNoWarnings 1
