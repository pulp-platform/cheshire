// Copyright 2023 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Nicole Narr <narrn@student.ethz.ch>
// Christopher Reinwardt <creinwar@student.ethz.ch>

#pragma once

#include "sw/device/lib/dif/dif_i2c.h"

int i2c_flash_read_blocks(dif_i2c_t *i2c, unsigned int lba, unsigned char *mem_addr, unsigned int num_blocks);

int i2c_flash_read_blocks_callback(void *priv, unsigned int lba, void *mem_addr, unsigned int num_blocks);
