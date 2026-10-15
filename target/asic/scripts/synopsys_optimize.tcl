# Copyright 2026 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
#
# Design-specific optimization directives for Synopsys Design Compiler,
# independent of the technology. Sourced after elaboration, before compile.
# They follow the cva6-eval flow, so CVA6 is optimized as in core-only runs.

# Retime the registers of the pipelined FPU and multiplier
foreach pattern {fpnew_* multiplier_*} {
    set designs [get_designs -quiet ${pattern}]
    if { [sizeof_collection ${designs}] == 0 } {
        error "synopsys_optimize.tcl: no designs ${pattern} to retime"
    }
    set_optimize_registers true -justification_effort medium -designs ${designs}
}

# Flatten the contents of the ALU wrapper, where it exists (newer CVA6 versions)
foreach_in_collection wrapper [get_cells -quiet -hierarchical alu_wrapper_i] {
    set children [get_cells -quiet [get_object_name ${wrapper}]/* \
        -filter "is_hierarchical == true"]
    if { [sizeof_collection ${children}] > 0 } {
        ungroup -flatten ${children}
    }
}
