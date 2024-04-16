# Copyright 2022 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
#
# Nicole Narr <narrn@student.ethz.ch>
# Christopher Reinwardt <creinwar@student.ethz.ch>
# Paul Scheffler <paulsc@iis.ee.ethz.ch>

CHS_ROOT ?= $(shell pwd)
BENDER	 ?= bender -d $(CHS_ROOT)

include cheshire.mk

# Inside the repo, forward (prefixed) all, nonfree, and clean targets
all:
	@$(MAKE) chs-all

%-all:
	@$(MAKE) chs-$*-all

nonfree-%:
	@$(MAKE) chs-nonfree-$*

clean-%:
	@$(MAKE) chs-clean-$*
