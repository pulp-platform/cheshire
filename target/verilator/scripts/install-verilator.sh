# Copyright 2022 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
# inspired from https://github.com/zchamski/core-v-verif/blob/046a50d58648bafdb2263dee53e1043e83057284/cva6/regress/install-verilator.sh
# Copyright 2021 Thales DIS design services SAS
# Original Author: Jean-Roch COULON - Thales
# Heavily adapted by Jannis Schönleber - ETH Zurich

set -e

export RISCV="/usr/pack/riscv-1.0-kgf/riscv64-gcc-11.2.0"
export PATH="${RISCV}/bin/:$PATH"    # 64-bit

export LIBRARY_PATH=$RISCV/lib
export LD_LIBRARY_PATH=$RISCV/lib
export C_INCLUDE_PATH=$RISCV/include
export CPLUS_INCLUDE_PATH=$RISCV/include

export TOP=${PWD}

export VERILATOR_BUILD_DIR=${TOP}/target/verilator/install/verilator
export PATH="$VERILATOR_INSTALL_DIR/bin:$PATH"



# install help2man on our internal machines it is not installed
# check if help2man is installed
if ! command -v help2man &> /dev/null
then
    echo "help2man could not be found, installing it"
    HELP2MAN_INSTALL_DIR=${TOP}/target/verilator/install/help2man
    wget https://ftp.gnu.org/gnu/help2man/help2man-1.49.3.tar.xz -O /tmp/help2man.tar.xz
    tar -xf /tmp/help2man.tar.xz -C /tmp
    cd /tmp/help2man-1.49.3
    ./configure  --prefix=${HELP2MAN_INSTALL_DIR}
    make
    make install
    export PATH=${HELP2MAN_INSTALL_DIR}/bin:$PATH
fi


# number of parallel jobs to use for make commands and simulation
export NUM_JOBS=16

if [ -z ${NUM_JOBS} ]; then
    NUM_JOBS=1
fi

# Ensure the location of tools is known (usually, .../core-v-verif/tools).
if [ -z "$TOP" ]; then
  echo "Error: location of core-v-verif 'tools' tree (\$TOP) is not defined."
  return
fi

VERILATOR_REPO="https://github.com/verilator/verilator.git"
VERILATOR_BRANCH="master"
# Use the release tag instead of a full SHA1 hash.
VERILATOR_HASH="v5.010"
VERILATOR_PATCH="$TOP/target/verilator/patches/verilator-v5.patch"

# Unset historical variable VERILATOR_ROOT as it collides with the build process.
if [ -n "$VERILATOR_ROOT" ]; then
  unset VERILATOR_ROOT
fi

# Define the default src+build location of Verilator.
# No need to force this location in Continuous Integration scripts.
if [ -z "$VERILATOR_BUILD_DIR" ]; then
  export VERILATOR_BUILD_DIR=${TOP}/target/verilator/install/verilator
fi

# Define the default installation location of Verilator: one level up
# from the source tree in the core-v-verif tree.
# Continuous Integration may need to override this particular variable
# to use a preinstalled build of Verilator.
if [ -z "$VERILATOR_INSTALL_DIR" ]; then
  export VERILATOR_INSTALL_DIR=$(dirname ${VERILATOR_BUILD_DIR})
fi

# Build and install Verilator only if not already installed at the expected
# location $VERILATOR_INSTALL_DIR.
if [ ! -f "$VERILATOR_INSTALL_DIR/bin/verilator" ]; then
    echo "Building Verilator in $VERILATOR_BUILD_DIR..."
    echo "Verilator will be installed in $VERILATOR_INSTALL_DIR"
    echo "VERILATOR_REPO=$VERILATOR_REPO"
    echo "VERILATOR_BRANCH=$VERILATOR_BRANCH"
    echo "VERILATOR_HASH=$VERILATOR_HASH"
    echo "VERILATOR_PATCH=$VERILATOR_PATCH"
    mkdir -p $VERILATOR_BUILD_DIR
    cd $VERILATOR_BUILD_DIR
    # Clone only if the ".git" directory does not exist.
    # Do not remove the content arbitrarily if ".git" does not exist in order
    # to preserve user content - let git fail instead.
    [ -d .git ] || git clone $VERILATOR_REPO -b $VERILATOR_BRANCH .
    git checkout $VERILATOR_HASH
    # if [ ! -z "$VERILATOR_PATCH" ] ; then
    #   # git apply $VERILATOR_PATCH || true
    # fi
    # Generate the config script and configure Verilator.
    autoconf && ./configure --prefix="$VERILATOR_INSTALL_DIR" && make -j${NUM_JOBS}
    # FORNOW: Accept failure in 'make test' (segfault issue on Debian10)
    # make test || true
    echo "Installing Verilator in $VERILATOR_INSTALL_DIR..."
    make install
    echo "VERILATOR is installed"
else
    echo "Using Verilator from cached directory $VERILATOR_INSTALL_DIR."
fi

