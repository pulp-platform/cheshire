// Copyright 2022 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Yvan Tortorella <yvan.tortorella@unibo.it>
//
// Library containing IO init/close functions.

#include "cheshire_io.h"

void cheshire_init_io() {
    // Initialize UART first
    uart_open();

    // Initialize other IOs
    // .
    // .
    // .
};
