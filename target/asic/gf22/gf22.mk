# Copyright 2026 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
#
# GF22 technology target. Its implementation is not open: it lives in a
# separate repository, checked out at a pinned commit into CHS_ASIC_GF22_DIR,
# which is also the icdesign cockpit.

CHS_ASIC_GF22_REMOTE ?= git@iis-git.ee.ethz.ch:ezelioli/cheshire-gf22.git
CHS_ASIC_GF22_COMMIT ?= 97a3c6e9bd8511145e261af24ba511a4f0dacb7a
CHS_ASIC_GF22_DIR    ?= $(CHS_ASIC_DIR)/gf22/nonfree

CHS_PHONY += chs-asic-gf22-init
chs-asic-gf22-init:
	git clone $(CHS_ASIC_GF22_REMOTE) $(CHS_ASIC_GF22_DIR)
	cd $(CHS_ASIC_GF22_DIR) && git checkout $(CHS_ASIC_GF22_COMMIT)

ifneq ($(wildcard $(CHS_ASIC_GF22_DIR)/gf22.mk),)
include $(CHS_ASIC_GF22_DIR)/gf22.mk
else
chs-asic-gf22-%:
	@echo "error: no GF22 implementation in $(CHS_ASIC_GF22_DIR); run 'make chs-asic-gf22-init'" >&2
	@exit 1
endif
