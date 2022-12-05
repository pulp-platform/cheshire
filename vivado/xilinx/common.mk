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

all:
	$(VIVADO) -mode batch -source tcl/run.tcl

gui:
	$(VIVADO) -mode gui -source tcl/run.tcl &

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
