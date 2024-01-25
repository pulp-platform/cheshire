# Copyright 2024 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

ROOT_xlnx_mig_ddr4              := $(CHS_XIL_DIR)/xilinx_ips/xlnx_mig_ddr4
ARTIFACTS_FILES_xlnx_mig_ddr4   := xlnx_mig_ddr4.mk tcl/run.tcl
ARTIFACTS_VARS_xlnx_mig_ddr4    := xilinx_part XILINX_BOARD xilinx_board_long
XILINX_USE_ARTIFACTS_xlnx_mig_ddr4 := 1
