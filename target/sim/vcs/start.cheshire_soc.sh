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
[[ -z "${VERDI_HOME}" ]]    && echo "Please set \$VERDI_HOME" && exit 1
[[ -z "${VCS_HOME}" ]]      && echo "Please set \$VCS_HOME"   && exit 1

flags="-full64 -kdb "
# Set default to fast simulation flags.
if [ -z "${VCSARGS}" ]; then
    flags+="-O2 -debug_access+all "
fi

# flags+="-cpp ${CXX_PATH} "
[[ -n "${SELCFG}" ]]   && flags+="-pvalue+SelectedCfg=${SELCFG} "

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
        flags+="-y ${DRAMSYS_LIB}/libsystemc "
        flags+="-y ${DRAMSYS_LIB}/libDRAMSys_Simulator "
        pargs+="+DRAMSYS_RES=${DRAMSYS_ROOT}/configs "
    fi
fi

${VERDI_VERSION} ${VCS_BIN} ${flags} ../src/elfloader.cpp ${TESTBENCH} | tee elaborate.log

echo "${VCS_VERSION} ${VERDI_VERSION} ./simv ${pargs}"
${VCS_VERSION} ${VERDI_VERSION} ./simv ${pargs}
