# Copyright 2022 ETH Zurich and University of Bologna.
# Solderpad Hardware License, Version 0.51, see LICENSE for details.
# SPDX-License-Identifier: SHL-0.51
#
# Nicole Narr <narrn@student.ethz.ch>
# Christopher Reinwardt <creinwar@student.ethz.ch>

if {![info exists BINARY]} {
    puts "Set the \"BINARY\" variable before sourcing the start script"
    set BINARY ""
}

vsim -c tb_cheshire_soc -t 1ps -voptargs=+acc +BINARY=$BINARY -permissive -suppress 3009

set StdArithNoWarnings 1
set NumericStdNoWarnings 1

log -r *
