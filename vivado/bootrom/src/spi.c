// Copyright 2021 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#include "spi.h"

#include "mmio.h"
#include "bitfield.h"

// ---------------
//   REG GETTERS
// ---------------

volatile uint8_t spi_get_tx_queue_depth(spi_handle_t* spi) {
    volatile uint32_t status_reg = spi_get_status(spi);
    return bitfield_field32_read(status_reg, SPI_HOST_STATUS_TXQD_FIELD);
}


volatile spi_chstatus_t spi_get_tx_flags(spi_handle_t* spi) {
    volatile uint32_t status_reg = spi_get_status(spi);
    return (spi_chstatus_t){
        .empty = bitfield_bit32_read(status_reg, SPI_HOST_STATUS_TXEMPTY_BIT),
        .full = bitfield_bit32_read(status_reg, SPI_HOST_STATUS_TXFULL_BIT),
        .stall = bitfield_bit32_read(status_reg, SPI_HOST_STATUS_TXSTALL_BIT),
        .wm = bitfield_bit32_read(status_reg, SPI_HOST_STATUS_TXWM_BIT)
    };
}


volatile uint8_t spi_get_rx_queue_depth(spi_handle_t* spi) {
    volatile uint32_t status_reg = spi_get_status(spi);
    return bitfield_field32_read(status_reg, SPI_HOST_STATUS_RXQD_FIELD);
}


volatile spi_chstatus_t spi_get_rx_flags(spi_handle_t* spi) {
    volatile uint32_t status_reg = spi_get_status(spi);
    return (spi_chstatus_t){
        .empty = bitfield_bit32_read(status_reg, SPI_HOST_STATUS_RXEMPTY_BIT),
        .full = bitfield_bit32_read(status_reg, SPI_HOST_STATUS_RXFULL_BIT),
        .stall = bitfield_bit32_read(status_reg, SPI_HOST_STATUS_RXSTALL_BIT),
        .wm = bitfield_bit32_read(status_reg, SPI_HOST_STATUS_RXWM_BIT)
    };
}


volatile uint32_t spi_get_csid(spi_handle_t* spi) {
    return mmio_region_read32(spi->mmio, SPI_HOST_CSID_REG_OFFSET);
}


// ---------------
//   REG SETTERS
// ---------------

void spi_sw_reset(spi_handle_t* spi) {
    volatile uint32_t control_reg = mmio_region_read32(spi->mmio, SPI_HOST_CONTROL_REG_OFFSET);
    control_reg = bitfield_bit32_write(control_reg, SPI_HOST_CONTROL_SW_RST_BIT, 1);
    mmio_region_write32(spi->mmio, SPI_HOST_CONTROL_REG_OFFSET, control_reg);
}


void spi_set_host_enable(spi_handle_t* spi, bool enable) {
    volatile uint32_t control_reg = mmio_region_read32(spi->mmio, SPI_HOST_CONTROL_REG_OFFSET);
    control_reg = bitfield_bit32_write(control_reg, SPI_HOST_CONTROL_SPIEN_BIT, enable);
    mmio_region_write32(spi->mmio, SPI_HOST_CONTROL_REG_OFFSET, control_reg);
}


void spi_set_tx_watermark(spi_handle_t* spi, uint8_t mark) {
    volatile uint32_t control_reg = mmio_region_read32(spi->mmio, SPI_HOST_CONTROL_REG_OFFSET);
    control_reg = bitfield_field32_write(control_reg, SPI_HOST_CONTROL_TX_WATERMARK_FIELD, mark);
    mmio_region_write32(spi->mmio, SPI_HOST_CONTROL_REG_OFFSET, control_reg);
}


void spi_set_rx_watermark(spi_handle_t* spi, uint8_t mark) {
    volatile uint32_t control_reg = mmio_region_read32(spi->mmio, SPI_HOST_CONTROL_REG_OFFSET);
    control_reg = bitfield_field32_write(control_reg, SPI_HOST_CONTROL_RX_WATERMARK_FIELD, mark);
    mmio_region_write32(spi->mmio, SPI_HOST_CONTROL_REG_OFFSET, control_reg);
}


void spi_set_configopts(spi_handle_t* spi, uint32_t csid, const uint32_t co_reg) {
    mmio_region_write32(spi->mmio, sizeof(uint32_t) * csid + SPI_HOST_CONFIGOPTS_0_REG_OFFSET, co_reg);
}


void spi_set_csid(spi_handle_t* spi, uint32_t csid) {
    mmio_region_write32(spi->mmio, SPI_HOST_CSID_REG_OFFSET, csid);
}

void spi_set_command(spi_handle_t* spi, const uint32_t cmd_reg) {
    mmio_region_write32(spi->mmio, SPI_HOST_COMMAND_REG_OFFSET, cmd_reg);
}


void spi_write_word(spi_handle_t* spi, uint32_t word) {
    volatile uint32_t* fifo = spi->mmio.base + SPI_HOST_DATA_REG_OFFSET;
    asm volatile ("sw %[w], 0(%[fifo]);" :: [w]"r"(word), [fifo]"r"(fifo));
}


void spi_read_chunk_32B(spi_handle_t* spi, uint32_t* dst) {
    volatile uint32_t* fifo = spi->mmio.base + SPI_HOST_DATA_REG_OFFSET;
    asm volatile (
        "lwu    a7, 0 (%[fifo]);"
        "lwu    t0, 0 (%[fifo]);"
        "lwu    t1, 0 (%[fifo]);"
        "lwu    t2, 0 (%[fifo]);"
        "lwu    t3, 0 (%[fifo]);"
        "lwu    t4, 0 (%[fifo]);"
        "lwu    t5, 0 (%[fifo]);"
        "lwu    t6, 0 (%[fifo]);"
        "sw     a7, 0 (%[dst]);"
        "sw     t0, 4 (%[dst]);"
        "sw     t1, 8 (%[dst]);"
        "sw     t2, 12(%[dst]);"
        "sw     t3, 16(%[dst]);"
        "sw     t4, 20(%[dst]);"
        "sw     t5, 24(%[dst]);"
        "sw     t6, 28(%[dst]);"
        :: [fifo]"r"(fifo), [dst]"r"(dst)
        : "a7", "t0", "t1", "t2", "t3", "t4", "t5", "t6"
    );
}
