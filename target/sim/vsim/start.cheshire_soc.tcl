# Copyright 2022 ETH Zurich and University of Bologna.
# Solderpad Hardware License, Version 0.51, see LICENSE for details.
# SPDX-License-Identifier: SHL-0.51
#
# Nicole Narr <narrn@student.ethz.ch>
# Christopher Reinwardt <creinwar@student.ethz.ch>
# Alessandro Ottaviano <aottaviano@iis.ee.ethz.ch>

if {![info exists BINARY ]} {
    return -code error -errorinfo "\[ERRORINFO\] You must set the \"BINARY\" variable before sourcing the start script."
    set BINARY ""
}

if {![info exists TESTBENCH ]} {
    return -code error -errorinfo "\[ERRORINFO\] You must set the \"TESTBENCH\" variable before sourcing the start script."
    set TESTBENCH ""
}

if {![info exists BOOTMODE ]} {
    puts "You can choose a \"BOOTMODE\" for the simulation. By default, JTAG bootmode will be used."
    set BOOTMODE 3
}

if {![info exists TESTMODE ]} {
    puts "You can choose whether to activate testmode by setting the \"TESTMODE\" variable to 1. By default, testmode is disabled."
    set TESTMODE 0
}

vsim -c $TESTBENCH -t 1ps -voptargs=+acc +BINARY=$BINARY +BOOTMODE=$BOOTMODE +TESTMODE=$TESTMODE -permissive -suppress 3009

set StdArithNoWarnings 1
set NumericStdNoWarnings 1

log -r *

# check exit status in tb and quit the simulation accordingly
proc run_and_exit {} {
    onfinish stop
    run -all

    set hier [env]
    # 0 is sim:
    # 1 is the first module in the hierarchy (the testbench)
    set sim_top [lindex [split $hier /] 1]

    if {[coverage attribute -concise -name TESTSTATUS] >= 3} {
        # exit with error if we had a $fatal somewhere
        quit -code 1
    } else {
        # assume there is an `exit_status` signal that contains the status of
        # the simulation
        if {![examine -radix decimal sim:/$sim_top/exit_status]} {
            puts "TEST SUCCESS"
            quit -code [examine -radix decimal sim:/$sim_top/exit_status]
        } else {
            puts "TEST FAIL"
            quit -code [examine -radix decimal sim:/$sim_top/exit_status]
        }
    }
}
