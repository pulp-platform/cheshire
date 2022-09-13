// Copyright 2021 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

// Basic device functions for opentitan SPI host; do not include interrupts yet!
// We use bitfields only to save on storage; we do *not* assume an implementation.

#pragma once

#include <stdint.h>

#include "util.h"
#include "mmio.h"

#include "spi_regs.h"


// ---------
//   TYPES
// ---------

// Handle to an SPI host instance
typedef struct {
    mmio_region_t mmio;
} spi_handle_t;

// SPI speed type
typedef enum {
    kSpiSpeedStandard   = 0,
    kSpiSpeedDual       = 1,
    kSpiSpeedQuad       = 2
} spi_speed_e;

// SPI directionality
typedef enum {
    kSpiDirDummy        = 0,
    kSpiDirRxOnly       = 1,
    kSpiDirTxOnly       = 2,
    kSpiDirBidir        = 3
} spi_dir_e;

// Configuration options for a chip
typedef struct {
    uint16_t clkdiv     : 16;
    uint8_t  csnidle    : 4;
    uint8_t  csntrail   : 4;
    uint8_t  csnlead    : 4;
    bool     __rsvd0    : 1;
    bool     fullcyc    : 1;
    bool     cpha       : 1;
    bool     cpol       : 1;
} spi_configopts_t;

// Readable status flags for a channel
typedef struct {
    bool empty : 1;
    bool full  : 1;
    bool wm    : 1;
    bool stall : 1;
} spi_chstatus_t;

// SPI host command
typedef struct {
    uint16_t    len         : 9;
    bool        csaat       : 1;
    spi_speed_e speed       : 2;
    spi_dir_e   direction   : 2;
} spi_command_t;

// ---------------
//   REG EXTERNS
// ---------------

volatile uint8_t spi_get_tx_queue_depth(spi_handle_t* spi);

volatile spi_chstatus_t spi_get_tx_flags(spi_handle_t* spi);

volatile uint8_t spi_get_rx_queue_depth(spi_handle_t* spi);

volatile spi_chstatus_t spi_get_rx_flags(spi_handle_t* spi);

volatile uint32_t spi_get_csid(spi_handle_t* spi);

void spi_sw_reset(spi_handle_t* spi);

void spi_set_host_enable(spi_handle_t* spi, bool enable);

void spi_set_tx_watermark(spi_handle_t* spi, uint8_t mark);

void spi_set_rx_watermark(spi_handle_t* spi, uint8_t mark);

void spi_set_configopts(spi_handle_t* spi, uint32_t csid, uint32_t co_reg);

void spi_set_csid(spi_handle_t* spi, uint32_t csid);

void spi_set_command(spi_handle_t* spi, uint32_t cmd_reg);

// Write single word to TX FIFO
void spi_write_word(spi_handle_t* spi, uint32_t word);

// Batch-read chunk of data for timeliness. Ensure RX FIFO contains at least 128B!
void spi_read_chunk_32B(spi_handle_t* spi, uint32_t* dst);

// -----------
//   INLINES
// -----------


STATIC_INLINE volatile uint32_t spi_get_status(spi_handle_t* spi) {
    return mmio_region_read32(spi->mmio, SPI_HOST_STATUS_REG_OFFSET);
}

STATIC_INLINE volatile bool spi_get_active(spi_handle_t* spi) {
    volatile uint32_t status_reg = spi_get_status(spi);
    return bitfield_bit32_read(status_reg, SPI_HOST_STATUS_ACTIVE_BIT);
}


STATIC_INLINE volatile bool spi_get_ready(spi_handle_t* spi) {
    volatile uint32_t status_reg = spi_get_status(spi);
    return bitfield_bit32_read(status_reg, SPI_HOST_STATUS_READY_BIT);
}



STATIC_INLINE CONST uint32_t spi_assemble_configopts(const spi_configopts_t configopts) {
    uint32_t co_reg = 0;
    co_reg = bitfield_field32_write(co_reg, SPI_HOST_CONFIGOPTS_0_CLKDIV_0_FIELD, configopts.clkdiv);
    co_reg = bitfield_field32_write(co_reg, SPI_HOST_CONFIGOPTS_0_CSNIDLE_0_FIELD, configopts.csnidle);
    co_reg = bitfield_field32_write(co_reg, SPI_HOST_CONFIGOPTS_0_CSNTRAIL_0_FIELD, configopts.csntrail);
    co_reg = bitfield_field32_write(co_reg, SPI_HOST_CONFIGOPTS_0_CSNLEAD_0_FIELD, configopts.csnlead);
    co_reg = bitfield_bit32_write(co_reg, SPI_HOST_CONFIGOPTS_0_FULLCYC_0_BIT, configopts.fullcyc);
    co_reg = bitfield_bit32_write(co_reg, SPI_HOST_CONFIGOPTS_0_CPHA_0_BIT, configopts.cpha);
    co_reg = bitfield_bit32_write(co_reg, SPI_HOST_CONFIGOPTS_0_CPOL_0_BIT, configopts.cpol);
    return co_reg;
}

STATIC_INLINE CONST uint32_t spi_assemble_command(const spi_command_t command) {
    uint32_t cmd_reg = 0;
    cmd_reg = bitfield_field32_write(cmd_reg, SPI_HOST_COMMAND_LEN_FIELD, command.len);
    cmd_reg = bitfield_bit32_write(cmd_reg, SPI_HOST_COMMAND_CSAAT_BIT, command.csaat);
    cmd_reg = bitfield_field32_write(cmd_reg, SPI_HOST_COMMAND_SPEED_FIELD, command.speed);
    cmd_reg = bitfield_field32_write(cmd_reg, SPI_HOST_COMMAND_DIRECTION_FIELD, command.direction);
    return cmd_reg;
}

STATIC_INLINE CONST volatile spi_handle_t spi_get_handle(const uintptr_t spi_base) {
    return (spi_handle_t){
        .mmio = mmio_region_from_addr(spi_base),
    };
}

STATIC_INLINE void spi_wait_for_ready(spi_handle_t* spi) {
    while (!spi_get_ready(spi));
}

STATIC_INLINE void spi_wait_for_tx_watermark(spi_handle_t* spi) {
    while (!mmio_region_get_bit32(spi->mmio, SPI_HOST_STATUS_REG_OFFSET, SPI_HOST_STATUS_TXWM_BIT));
}

STATIC_INLINE void spi_wait_for_rx_watermark(spi_handle_t* spi) {
    while (!mmio_region_get_bit32(spi->mmio, SPI_HOST_STATUS_REG_OFFSET, SPI_HOST_STATUS_RXWM_BIT));
}
