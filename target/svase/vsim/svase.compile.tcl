# Copyright 2022 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

if {[catch {vlog -incr -sv \
    -suppress 2583 -suppress 13314 \
    +define+TARGET_CV64A6_IMAFDC_SV39 \
    +define+TARGET_CVA6 \
    +define+TARGET_SIM \
    +define+TARGET_SIMULATION \
    +define+TARGET_TEST \
    +define+TARGET_VSIM \
    "../cheshire_svase.sv"
}]} {return 1}