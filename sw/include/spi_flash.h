// Copyright 2023 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Nicole Narr <narrn@student.ethz.ch>
// Christopher Reinwardt <creinwar@student.ethz.ch>

#pragma once

#include "opentitan_qspi.h"

int spi_flash_read_blocks(opentitan_qspi_t *spi, unsigned int lba, unsigned char *mem_addr, unsigned int num_blocks);

int spi_flash_read_blocks_callback(void *priv, unsigned int lba, void *mem_addr, unsigned int num_blocks);
