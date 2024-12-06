# Copyright 2022 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
#
# Fabian Hauser <fhauser@student.ethz.ch>
#
# Recompile only newusb (way faster)

# includes
set common_cells [glob ../../../.bender/git/checkouts/common_cells-*]
set axi          [glob ../../../.bender/git/checkouts/axi-*]
set deps +incdir+${common_cells}/include+${axi}/include
echo $deps

# testbenches and sources
set tb [glob ../../../hw/newusb_tb/tb_new_usb*sv]
set hw [glob ../../../hw/newusb/new_usb*sv]

eval vlog -work work ${deps} -sv $tb