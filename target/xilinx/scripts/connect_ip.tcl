# Copyright 2018 ETH Zurich and University of Bologna.
# Solderpad Hardware License, Version 0.51, see LICENSE for details.
# SPDX-License-Identifier: SHL-0.51
#
# Author: Cyril Koenig <cykoenig@iis.ee.ethz.ch>
# Description: Connects ports on IP to top level based on Vivado constaints
# Usage: (from Vivado post synthesis)
#        set argv [list <path_to_board.xdc> <path_to_ip_instance>]
#        set argc 2

set argc 2
set board_xdc [lindex $argv 0]
set ip_path   [lindex $argv 1]

set fd [open $board_xdc r]
set constraints [read $fd]
close $fd

foreach pin_path [get_pins $ip_path/*] {

    set pin_hierarchy [split $pin_path "/"]
    set pin_name [lindex $pin_hierarchy end]
    set pin_parent_path [join [lrange $pin_hierarchy 0 end-1] "/"]
    set bus_name [regsub -all {\[.*\]} $pin_name ""]

    # When bus is only one element vivado mixes name[0] and name
    # FIXME potential prefix match
    if { [llength [get_pins "$pin_parent_path/$bus_name*" ]] == 1 } {
        #set pin_name $bus_name
    }

    common::send_gid_msg -ssname BD::TCL -id 2001 -severity "INFO" "Creating port port_$pin_name and connecting to $pin_path"

    # If the pin is present in the constraint file
    if {[string first $bus_name $constraints] != -1} {
        create_port -direction [get_property DIRECTION [get_pins $pin_path]] port_$pin_name
        create_net net_$pin_name

        # No idea why does vivado does not accept without eval here
        eval "connect_net -net net_$pin_name -objects {port_$pin_name $pin_path}"
        set_property DONT_TOUCH true [get_nets net_$pin_name] 
    }
}
