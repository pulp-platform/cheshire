# #!/usr/bin/env bash
# Copyright 2022 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
#
# Cyril Koenig <cykoenig@iis.ee.ethz.ch>

# TESTBENCH=tb_cheshire_soc
# 
# # Set full path to c++ compiler.
# if [ -z "${CXX_PATH}" ]; then
#     if [ -z "${CXX}" ]; then
#         CXX="g++"
#     fi
#     CXX_PATH=`which ${CXX}`
# fi
# 
# # Set default VCS binary
# [[ -z "${XCELIUM_VERSION}" ]] && XCELIUM_VERSION=""
# [[ -z "${XCELIUM_BIN}" ]]     && XCELIUM_BIN="${XCELIUM_VERSION} vcs"
# 
# flags="-full64 -kdb "
# # Set default to fast simulation flags.
# if [ -z "${XCELIUMARGS}" ]; then
#     # Use -debug_access+all for waveform debugging
#     flags+="-O2 -debug_access=r -debug_region=1,${TESTBENCH} "
# fi
# 
# flags+="-cpp ${CXX_PATH} "
# [[ -n "${SELCFG}" ]]   && flags+="-pvalue+SelectedCfg=${SELCFG} "
# 
# pargs=""
# [[ -n "${BOOTMODE}" ]] && pargs+="+BOOTMODE=${BOOTMODE} "
# [[ -n "${PRELMODE}" ]] && pargs+="+PRELMODE=${PRELMODE} "
# [[ -n "${BINARY}" ]]   && pargs+="+BINARY=${BINARY} "
# [[ -n "${IMAGE}" ]]    && pargs+="+IMAGE=${IMAGE} "
# 
# # DRAMSys
# if [ -n "${USE_DRAMSYS}" ]; then
#     flags+="-pvalue UseDramSys=${USE_DRAMSYS} "
#     if [[ "${USE_DRAMSYS}" == 1 ]]; then
#         DRAMSYS_ROOT="../dramsys"
#         DRAMSYS_LIB="${DRAMSYS_ROOT}/build/lib"
#         pargs+="+DRAMSYS_RES=${DRAMSYS_ROOT}/configs "
#         pargs+="-sv_lib ${DRAMSYS_LIB}/libDRAMSys_Simulator "
#     fi
# fi
# 
# COLOR_NC='\e[0m'
# COLOR_BLUE='\e[0;34m'
# 
# ${XCELIUM_BIN} ${flags} ../src/elfloader.cpp ${TESTBENCH} | tee elaborate.log
# 
# # Start simulation
# printf ${COLOR_BLUE}"${XCELIUM_VERSION} ${XCELIUM_VERSION} ./simv ${pargs}"${COLOR_NC}"\n"
# ${XCELIUM_VERSION} ${XCELIUM_VERSION} ./simv ${pargs} | tee simulate.log
# 

XCELIUM="cds_ius-24.09.002"
XRUN="${XCELIUM} xrun -64bit -sv -licqueue -access +rwc -messages -smartorder -v200x -disable_sem2009 -enable_inout_out_def_arg"
TS="-timescale 1ns/1ps"
COMPILE_ARGS=""
ELAB_ARGS=""
RUN_ARGS=""
PLUSARGS=""
TOP=tb_cheshire_soc

${XRUN} -compile ${COMPILE_ARGS} -f compile.cheshire_soc.f;
# $(XRUN) $(TS) -elaborate $(ELAB_ARGS) -top $(TOP) -snapshot $(TOP)_snap; \
# $(XRUN) $(TS) $(RUN_ARGS) -R -snapshot $(TOP)_snap $(PLUSARGS)
