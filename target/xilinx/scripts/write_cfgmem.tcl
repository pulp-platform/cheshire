# Copyright 2018 ETH Zurich and University of Bologna.
# Solderpad Hardware License, Version 0.51, see LICENSE for details.
# SPDX-License-Identifier: SHL-0.51
#
# Author: Florian Zaruba <zarubaf@iis.ee.ethz.ch>
# Description: Generate a memory configuration file from a bitstream (Genesys II only right now)

if {$argc < 2 || $argc > 4} {
    puts $argc
    puts {Error: Invalid number of arguments}
    puts {Usage: write_cfgmem.tcl mcsfile bitfile [datafile]}
    exit 1
}

lassign $argv mcsfile bitfile

# https://scholar.princeton.edu/jbalkind/blog/programming-genesys-2-qspi-spi-x4-flash
# https://scholar.princeton.edu/jbalkind/blog/programming-vc707-virtex-7-bpi-flash
if {$::env(BOARD) eq "genesys2"} {
    #write_cfgmem -format mcs -interface SPIx4 -size 256  -loadbit "up 0x0 $bitfile" -file $mcsfile -force
    write_cfgmem -format mcs -interface SPIx1 -size 256  -loadbit "up 0x0 $bitfile" -file $mcsfile -force
} elseif {$::env(BOARD) eq "vc707"} {
    write_cfgmem -format mcs -interface bpix16 -size 128 -loadbit "up 0x0 $bitfile" -file $mcsfile -force
} elseif {$::env(BOARD) eq "kc705"} {
    write_cfgmem -format mcs -interface SPIx4 -size 128  -loadbit "up 0x0 $bitfile" -file $mcsfile -force
} else {
      exit 1
}
