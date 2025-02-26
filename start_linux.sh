#!/bin/sh
# Copyright (c) 2025 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
#
# Authors:
# - Philippe Sauter <phsauter@iis.ee.ethz.ch>

export UID=$(id -u)
export GID=$(id -g)

docker compose pull
docker compose run \
  -e PS1="\[\033[01;32m\]oseda: \[\033[00m\]\[\033[01;34m\]\w\[\033[00m\] $" \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  oseda
