# Copyright 2022 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

# Author: Jannis Schoenleber <janniss@iis.ee.ethz.ch>

FROM ubuntu:22.04

SHELL ["/bin/bash", "-c"]

RUN apt update && apt upgrade -y && apt install -y curl python3 build-essential git cmake python3-pip wget unzip

# ARG RISCV_GCC_VERSION=8.3.0-2020.04.0
# risvc-gnu-compiler
RUN curl -Ls -o riscv-gcc.tar.gz https://github.com/riscv-collab/riscv-gnu-toolchain/releases/download/2022.06.10/riscv64-elf-ubuntu-20.04-nightly-2022.06.10-nightly.tar.gz && \
    mkdir -p /tools/riscv && chmod 777 /tools/riscv && \
    tar -C /tools/riscv -xf riscv-gcc.tar.gz --strip-components=1 && \
    rm riscv-gcc.tar.gz

ENV PATH="${PATH}:/tools/riscv/bin"

# bender
ARG BENDER_VERSION=0.27.1
RUN mkdir -p /tools/bender && chmod 777 /tools/bender && \
    cd /tools/bender && curl --proto '=https' --tlsv1.2 -sSf https://pulp-platform.github.io/bender/init | bash -s -- ${BENDER_VERSION}

ENV PATH="${PATH}:/tools/bender"

# slang
ARG SLANG_VERSION=v2.0
RUN mkdir -p /tools/slang && chmod 777 /tools/slang && \
    cd /tools/slang && git clone https://github.com/MikePopoloski/slang.git && \
    cd slang && git checkout ${SLANG_VERSION} && \
    cmake -B build && cmake --build build -j$(nproc) && \
    cmake --install build --strip

# install rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

ENV PATH="${PATH}:/root/.cargo/bin"
# install morty via cargo
RUN cargo install --git https://github.com/pulp-platform/morty.git

# install python dependencies
COPY .github/requirements.txt .
RUN pip3 install -r requirements.txt

# remove safe directory check in git
RUN git config --global --add safe.directory '*'