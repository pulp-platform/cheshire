// Copyright 2022 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Nicole Narr <narrn@student.ethz.ch>
// Christopher Reinwardt <creinwar@student.ethz.ch>

#pragma once

#include "opentitan_qspi.h"

#define SD_R1b_TIMEOUT 10000

typedef enum {
    SD_RESP_R1 = 0,
    SD_RESP_R1b,
    SD_RESP_R2,
    SD_RESP_R3,
    SD_RESP_R4,
    SD_RESP_R5,
    SD_RESP_UNUSED,
    SD_RESP_R7
} sd_resp_t;

int sd_init(opentitan_qspi_t *spi);

int sd_read_blocks(opentitan_qspi_t *spi, unsigned int lba, unsigned char *mem_addr, unsigned int num_blocks);

int sd_read_blocks_callback(void *priv, unsigned int lba, void *mem_addr, unsigned int num_blocks);

int sd_write_blocks(opentitan_qspi_t *spi, unsigned int lba, unsigned char *mem_addr, unsigned int num_blocks);

int sd_write_blocks_callback(void *priv, unsigned int lba, void *mem_addr, unsigned int num_blocks);
