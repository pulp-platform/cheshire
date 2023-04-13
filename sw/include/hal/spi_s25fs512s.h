// Copyright 2023 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Nicole Narr <narrn@student.ethz.ch>
// Christopher Reinwardt <creinwar@student.ethz.ch>
// Paul Scheffler <paulsc@iis.ee.ethz.ch>

#pragma once

#include <stdint.h>
#include "sw/device/lib/dif/dif_spi_host.h"

// Handle identifying relevant configuration of the device; *considered constant after init*.
typedef struct {
    dif_spi_host_t spi_host; // Will be set by init
    uint64_t spi_freq;       // Should be set before init
    int csid;                // Should be set before init
} spi_s25fs512s_t;

// Sets up only this device; other functions may be used with own setup if requirements are met.
// This assumes the power-up period of s25fs512 will be elapsed *before* issuing further commands.
int spi_s25fs512s_init(spi_s25fs512s_t *handle, uint64_t core_freq);

int spi_s25fs512s_single_read(void *priv, void *buf, uint64_t addr, uint64_t len);

// Flashing is done as whole 512B pages
int spi_s25fs512s_single_flash(void *priv, void *buf, uint64_t page, uint64_t num_pages);
