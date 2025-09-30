# Copyright 2020 ETH Zurich and University of Bologna.
# Solderpad Hardware License, Version 0.51, see LICENSE for details.
# SPDX-License-Identifier: SHL-0.51
#
# Nils Wistoff <nwistoff@iis.ee.ethz.ch>
# Noah Huetter <huettern@iis.ee.ethz.ch>
# Paul Scheffler <paulsc@iis.ee.ethz.ch>
# Yvan Tortorella <yvan.tortorella@gmail.com>

# Open hardware target
set xilinx_root [file dirname [file dirname [file dirname [file normalize [info script]]]]]
source -quiet ${xilinx_root}/scripts/common.tcl
open_target $xilinx_root $argc $argv flash

# Additional argument provide image file and offset
set file [lindex $argv 3]
set offs [lindex $argv 4]

set hw_memdev [lindex [get_cfgmem_parts $cfgmp($board)] 0]
create_hw_cfgmem -hw_device $hw_device $hw_memdev
set hw_cfgmem [get_property PROGRAM.HW_CFGMEM $hw_device]

# Create image for and configure memory depending on board
switch $board {
    genesys2 -
    vcu118   -
    vcu128   {
        set mcs ${project_root}/image.mcs
        write_cfgmem -force -format mcs -size 256 -interface SPIx4 \
            -loaddata "up $offs $file" -checksum -file $mcs
        set_property -dict [list \
            PROGRAM.ADDRESS_RANGE {use_file} \
            PROGRAM.FILES [list $mcs] \
            PROGRAM.PRM_FILE {} \
            PROGRAM.UNUSED_PIN_TERMINATION {pull-none} \
            PROGRAM.BLANK_CHECK {0} \
            PROGRAM.ERASE {1} \
            PROGRAM.CFG_PROGRAM {1} \
            PROGRAM.VERIFY {1} \
            PROGRAM.CHECKSUM {0} \
            ] $hw_cfgmem
    }
    default { nocfgexit flash_spi $board }
}

# Create bitstream to access config memory
create_hw_bitstream -hw_device $hw_device [get_property PROGRAM.HW_CFGMEM_BITFILE $hw_device];
program_hw_devices $hw_device;
refresh_hw_device $hw_device;

# Program config memory
program_hw_cfgmem -hw_cfgmem $hw_cfgmem
