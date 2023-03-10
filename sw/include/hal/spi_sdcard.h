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
    dif_spi_host_t spi_host;    // Will be set by init
    uint64_t spi_freq;          // Should be set before init
    int csid;                   // Should be set before init
    int csid_dummy;             // Should be set before init
} spi_sdcard_t;

// Initialization clock speed (200kHz)
static const uint64_t __spi_sdcard_init_clock = 200000;

// How many cycles to wait for a non-yielding R1b response
static const uint64_t __spi_sdcard_r1b_timeout = 10000;

// How many cycles to wait for another data block
static const uint64_t __spi_sdcard_data_timeout = 10000;

// Sets up only this device; other functions may be used with own setup if requirements are met.
// This assumes the power-up period of 1ms will be elapsed *before* issuing further commands.
int spi_sdcard_init(spi_sdcard_t *handle, uint64_t core_freq);

int spi_sdcard_read_checkcrc(void *priv, void* buf, uint64_t addr, uint64_t len);

int spi_sdcard_read_ignorecrc(void *priv, void* buf, uint64_t addr, uint64_t len);
