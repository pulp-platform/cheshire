# Copyright 2026 ETH Zurich and University of Bologna.
# Solderpad Hardware License, Version 0.51, see LICENSE for details.
# SPDX-License-Identifier: SHL-0.51
#
# Design object lookups used by `cheshire_asic.sdc`, for Synopsys tools.
# Each tool has its own naming of inferred registers and hierarchical objects;
# an adapter hides this so the constraints themselves stay tool-agnostic.

# Output pins of the single-bit registers inferred for signal `reg`, inside
# instances whose hierarchical name matches the glob `scope`
proc chs_asic_reg_q { scope reg } {
    return [filter_collection [get_pins -quiet -hierarchical ${reg}_reg/Q] "full_name =~ ${scope}"]
}

# Number of objects in a collection
proc chs_asic_count { objs } {
    return [sizeof_collection ${objs}]
}
