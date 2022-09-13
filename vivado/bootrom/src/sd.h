// Copyright 2022 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Nicole Narr <narrn@student.ethz.ch>
// Christopher Reinwardt <creinwar@student.ethz.ch>

#include "neo_uart.h"
#include "printf.h"
#include "mmio.h"
#include "util.h"
#include "spi.h"
#include <stdint.h>

extern void *__base_spi_sym;

// Reorder the 6 bytes of the command
uint64_t sd_cmd_shuffle(uint64_t cmd);

// Wait for a response of the SD Card (i.e. wait for some byte with bit 7 = 0)
void sd_wait_response(spi_handle_t *spi, uint32_t resp_bytes, uint8_t *buf);

// Execute a SD command and wait for resp_len response bytes
void sd_cmd(spi_handle_t *spi, uint64_t cmd, uint8_t *resp, uint64_t resp_len);

// Bring SD Card out of reset into idle mode
int sd_init(spi_handle_t *spi);

// Read one 512 byte block (in two 256 byte steps) and return the CRC-16
uint16_t sd_read_block(spi_handle_t *spi, uint8_t *soc_addr);

// Copy
void sd_copy_blocks(spi_handle_t *spi, uint64_t sd_addr, uint8_t *soc_addr, uint32_t num_blocks);

