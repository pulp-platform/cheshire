# Copyright 2022 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

# TODO change once we have correct tools installed with DZ
OPENROAD_ROOT := /usr/scratch/schneematt/janniss/Documents/openroad-build/install
# sourcing yosys and sv2v
export PATH := $(OPENROAD_ROOT)/bin:$(PATH)
# sourcing svase and morty
export PATH := $(PATH):/usr/scratch/pisoc11/sem23f30/tools/bin
