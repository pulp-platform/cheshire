// Copyright 2023 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Nicole Narr <narrn@student.ethz.ch>
// Christopher Reinwardt <creinwar@student.ethz.ch>
// Paul Scheffler <paulsc@iis.ee.ethz.ch>

#pragma once

#include <stdint.h>
#include "sw/device/lib/dif/dif_i2c.h"

// Sets up only this device; other functions may be used with own setup if requirements are met.
int i2c_24fc1025_init(dif_i2c_t *i2c, uint64_t core_freq);

int i2c_24fc1025_read(void *priv, void* buf, uint64_t addr, uint64_t len);

int i2c_24fc1025_write(void *priv, void* buf, uint64_t addr, uint64_t len);
