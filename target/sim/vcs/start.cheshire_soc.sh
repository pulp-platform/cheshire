# #!/usr/bin/env bash
# Copyright 2022 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
#
# Cyril Koenig <cykoenig@iis.ee.ethz.ch>

TESTBENCH=tb_cheshire_soc

# Set full path to c++ compiler.
if [ -z "${CXX_PATH}" ]; then
    if [ -z "${CXX}" ]; then
        CXX="g++"
    fi
    CXX_PATH=`which ${CXX}`
fi

# Set default VCS binary
[[ -z "${VERDI_VERSION}" ]] && VERDI_VERSION=""
[[ -z "${VCS_VERSION}" ]]   && VCS_VERSION=""
[[ -z "${VCS_BIN}" ]]       && VCS_BIN="${VCS_VERSION} vcs"

flags="-full64 -kdb "
# Set default to fast simulation flags.
if [ -z "${VCSARGS}" ]; then
    # Use -debug_access+all for waveform debugging
    flags+="-O2 -debug_access=r -debug_region=1,${TESTBENCH} "
fi

flags+="-cpp ${CXX_PATH} "
[[ -n "${SELCFG}" ]]   && flags+="-pvalue+SelectedCfg=${SELCFG} "

if [ -n "${ZOIX}" ]; then
    flags+="-fsim=dut:${TESTBENCH}.fix.dut.gen_cva6_cores[0].i_core_cva6 -fsim=portfaults "
fi

pargs=""
[[ -n "${BOOTMODE}" ]] && pargs+="+BOOTMODE=${BOOTMODE} "
[[ -n "${PRELMODE}" ]] && pargs+="+PRELMODE=${PRELMODE} "
[[ -n "${BINARY}" ]]   && pargs+="+BINARY=${BINARY} "
[[ -n "${IMAGE}" ]]    && pargs+="+IMAGE=${IMAGE} "

# DRAMSys
if [ -n "${USE_DRAMSYS}" ]; then
    flags+="-pvalue UseDramSys=${USE_DRAMSYS} "
    if [[ "${USE_DRAMSYS}" == 1 ]]; then
        DRAMSYS_ROOT="../dramsys"
        DRAMSYS_LIB="${DRAMSYS_ROOT}/build/lib"
        pargs+="+DRAMSYS_RES=${DRAMSYS_ROOT}/configs "
        pargs+="-sv_lib ${DRAMSYS_LIB}/libDRAMSys_Simulator "
    fi
fi

COLOR_NC='\e[0m'
COLOR_BLUE='\e[0;34m'

if [ "${ZOIX:-0}" = "1" ]; then
    # ZoiX flow: script runs from target/zoix_rtl, simv is launched by the Makefile
    ${VCS_BIN} ${flags} ${CHS_ROOT}/target/sim/src/elfloader.cpp ${TESTBENCH} | tee elaborate.log
else
    # Basic RTL flow: script runs from target/sim/vcs, so run simv here too
    ${VCS_BIN} ${flags} ../src/elfloader.cpp ${TESTBENCH} | tee elaborate.log

    # Start simulation
    printf ${COLOR_BLUE}"${VCS_VERSION} ${VERDI_VERSION} ./simv ${pargs}"${COLOR_NC}"\n"
    ${VCS_VERSION} ${VERDI_VERSION} ./simv ${pargs} | tee simulate.log
fi
