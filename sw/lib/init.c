// Copyright 2022 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Yvan Tortorella <yvan.tortorella@unibo.it>
//
// Library containing general SoC init/close functions.

#include "init.h"

void soc_init() {
    // IO initialization
    cheshire_init_io();
};