# Copyright 2022 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
#
# select IIS-internal tool commands if we run on IIS machines
ifneq (,$(wildcard /etc/iis.version))
	VIVADO ?= vitis-2020.2 vivado
else
	VIVADO ?= vivado
endif

# Note: We do not use Memora as it is bound to Git versionning
# and not standalone on files hash / environment variables
ARTIFACTS_PATH=/usr/scratch2/wuerzburg/cykoenig/memora/cheshire
GREEN='\033[0;32m'
NC='\033[0m'

all:

ifeq ($(USE_ARTIFACTS),1)
all: save-artifacts
else
all: $(PROJECT).xpr
endif

# Build IP
$(PROJECT).xpr:
	$(VIVADOENV) $(VIVADO) -mode batch -source tcl/run.tcl

.PHONY: generate_sha256 load-artifacts

# Generate a sha based on env variables and artifacts_in
generate_sha256:
	@echo $(VIVADO) $(PROJECT) > .generated_env
	@echo $(VIVADOENV) | tr " " "\n" | grep $(foreach var,$(ARTIFACTS_VARS), $(addprefix -e ,$(var)))  >> .generated_env
	@sha256sum $(ARTIFACTS_IN) >> .generated_env
	@sha256sum .generated_env | awk '{print $$1}' > .generated_sha256

# Load artifacts based on .generated_sha256
load-artifacts: .generated_sha256
	@if [ -d "$(ARTIFACTS_PATH)/`cat $<`" ]; then\
		echo -e $(GREEN)"Fetching $(PROJECT) from $(ARTIFACTS_PATH)/`cat $<`"$(NC); \
		cp -r $(ARTIFACTS_PATH)/`cat $<`/* .; \
	fi

# Save artifacts (this folder) based on .generated_sha256
save-artifacts: generate_sha256 load-artifacts $(PROJECT).xpr
	@if [ ! -d "$(ARTIFACTS_PATH)/`cat .generated_sha256`" ]; then \
		cp -r . $(ARTIFACTS_PATH)/`cat .generated_sha256`; \
		chmod -R o+rw $(ARTIFACTS_PATH)/`cat .generated_sha256`; \
	fi

gui:
	$(VIVADOENV) $(VIVADO) -mode gui -source tcl/run.tcl &

clean:
	rm -rf ip/*
	mkdir -p ip
	rm -rf ${PROJECT}.*
	rm -rf component.xml
	rm -rf vivado*.jou
	rm -rf vivado*.log
	rm -rf vivado*.str
	rm -rf xgui
	rm -rf .Xil
	rm -rf tmp
	rm -rf .generated*
