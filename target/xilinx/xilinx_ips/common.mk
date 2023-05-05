# Copyright 2022 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
#
# Cyril Koenig <cykoenig@iis.ee.ethz.ch>

all: load-artifacts $(PROJECT).xpr save-artifacts

# Build IP
xlnx_%.xpr:
	$(vivado_env) $(VIVADO) -mode batch -source tcl/run.tcl

save-artifacts:

load-artifacts:

clean:
	@rm -rf ip/*
	@mkdir -p ip
	@rm -rf ${PROJECT}.*
	@rm -rf component.xml
	@rm -rf vivado*.jou
	@rm -rf vivado*.log
	@rm -rf vivado*.str
	@rm -rf xgui
	@rm -rf .Xil
	@rm -rf tmp
	@rm -rf .generated*

.PHONY: clean save-artifacts load-artifacts

#
# Artifacts management (IIS internal)
#

ifeq ($(XILINX_USE_ARTIFACTS),1)

# Note: We do not use Memora as it is bound to Git versionning
# and not standalone on files hash / environment variables
ARTIFACTS_PATH=/usr/scratch2/wuerzburg/cykoenig/memora/cheshire
TERM_GREEN='\033[0;32m'
TERM_NC='\033[0m'

# Generate a sha based on env variables and artifacts_in
.generated_sha256:
	@echo $(VIVADO) $(PROJECT) > .generated_env
	@echo $(vivado_env) | tr " " "\n" | grep $(foreach var,$(ARTIFACTS_VARS), $(addprefix -e ,$(var)))  >> .generated_env
	@sha256sum $(ARTIFACTS_IN) >> .generated_env
	@sha256sum .generated_env | awk '{print $$1}' > .generated_sha256

# Load artifacts based on .generated_sha256
load-artifacts: .generated_sha256
	@if [ -d "$(ARTIFACTS_PATH)/`cat $<`" ]; then\
		echo -e $(TERM_GREEN)"Fetching $(PROJECT) from $(ARTIFACTS_PATH)/`cat $<`"$(TERM_NC); \
		cp -r $(ARTIFACTS_PATH)/`cat $<`/* .; \
	fi

# Save artifacts (this folder) based on .generated_sha256
save-artifacts: .generated_sha256 $(PROJECT).xpr
	@if [ ! -d "$(ARTIFACTS_PATH)/`cat .generated_sha256`" ]; then \
		cp -r . $(ARTIFACTS_PATH)/`cat .generated_sha256`; \
		chmod -R g+rw $(ARTIFACTS_PATH)/`cat .generated_sha256`; \
	fi

endif # ifeq ($(USE_ARTIFACTS),1)
