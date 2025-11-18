# #!/usr/bin/env bash
# Copyright 2022 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
#
# Yvan Tortorella <yvan.tortorella@gmail.com>

TESTBENCH=tb_cheshire_soc

# Set full path to c++ compiler.
if [ -z "${CXX_PATH}" ]; then
    if [ -z "${CXX}" ]; then
        CXX="gcc"
    fi
    CXX_PATH=`which ${CXX}`
fi

# Set default Xcelium binary
[[ -z "${XCELIUM_VERSION}" ]] && XCELIUM_VERSION=""
[[ -z "${XCELIUM_BIN}" ]]     && XCELIUM_BIN="${XCELIUM_VERSION} xrun"

# Set default to fast simulation flags.
flags="-timescale 1ns/1ps -64bit -sv "
if [ -z "${XCELIUMARGS}" ]; then
    # Use -access +rwc for waveform debugging
    flags+="-access +r -enable_typeparam_cfn "
fi

if [ -n "${SELCFG}" ]; then
    flags+="-gpg "SelectedCfg => ${SELCFG}" "
    pargs="-gpg "SelectedCfg => ${SELCFG}" "
fi

[[-n "${USE_GUI}"]]      && pargs+="-gui "
[[ -n "${BOOTMODE}" ]]   && pargs+="+BOOTMODE=${BOOTMODE} "
[[ -n "${PRELMODE}" ]]   && pargs+="+PRELMODE=${PRELMODE} "
[[ -n "${BINARY}" ]]     && pargs+="+BINARY=${BINARY} "
[[ -n "${IMAGE}" ]]      && pargs+="+IMAGE=${IMAGE} "

# # DRAMSys
if [ -n "${USE_DRAMSYS}" ]; then
    flags+="-gpg UseDramSys=${USE_DRAMSYS} "
    if [[ "${USE_DRAMSYS}" == 1 ]]; then
        DRAMSYS_ROOT="../dramsys"
        DRAMSYS_LIB="${DRAMSYS_ROOT}/build/lib"
        pargs+="+DRAMSYS_RES=${DRAMSYS_ROOT}/configs "
        pargs+="-sv_lib ${DRAMSYS_LIB}/libDRAMSys_Simulator "
    fi
fi

# Obtain path to XCelium includes to compile DPIs
XCELIUM_INC="$(dirname "$(dirname "$(realpath "$(which ${XCELIUM_BIN})")")")/include"
mkdir dpilib && ${CXX} ../src/elfloader.cpp -fpic -shared -o dpilib/libmydpi.so -I${XCELIUM_INC}

${XCELIUM_BIN} -elaborate ${flags} -f compile.cheshire_soc.f -top ${TESTBENCH} -create_sharedlib -lmydpi -L./dpilib -snapshot ${TESTBENCH}_snap
${XCELIUM_BIN} ${pargs} -R -snapshot ${TESTBENCH}_snap

