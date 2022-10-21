// Copyright 2022 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Nicole Narr <narrn@student.ethz.ch>
// Christopher Reinwardt <creinwar@student.ethz.ch>

#ifndef SD_H_
#define SD_H_

#include "opentitan_qspi.h"

int sd_init(opentitan_qspi_t *spi);

int sd_copy_blocks(opentitan_qspi_t *spi, unsigned int lba, unsigned char *mem_addr, unsigned int num_blocks);

#endif