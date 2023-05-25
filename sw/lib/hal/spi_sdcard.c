// Copyright 2023 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Nicole Narr <narrn@student.ethz.ch>
// Christopher Reinwardt <creinwar@student.ethz.ch>
// Paul Scheffler <paulsc@iis.ee.ethz.ch>

#include "hal/spi_sdcard.h"
#include "spi_host_regs.h"
#include "util.h"
#include "params.h"

typedef enum {
    kSpiSdcardRespR1,
    kSpiSdcardRespR1b,
    kSpiSdcardRespR2,
    kSpiSdcardRespR3,
    kSpiSdcardRespR7
} spi_sdcard_resp_t;

const uint64_t __spi_sdcard_resp_len[] = {
    1, // R1
    1, // R1b
    2, // R2
    5, // R3
    5  // R7
};

// Lookup table for crc7 polynomial G(x) = x^7 + x^3 + 1
static const uint8_t __spi_sdcard_crc7_lookup[] = {
    0x00, 0x12, 0x24, 0x36, 0x48, 0x5a, 0x6c, 0x7e, 0x90, 0x82, 0xb4, 0xa6, 0xd8, 0xca, 0xfc, 0xee,
    0x32, 0x20, 0x16, 0x04, 0x7a, 0x68, 0x5e, 0x4c, 0xa2, 0xb0, 0x86, 0x94, 0xea, 0xf8, 0xce, 0xdc,
    0x64, 0x76, 0x40, 0x52, 0x2c, 0x3e, 0x08, 0x1a, 0xf4, 0xe6, 0xd0, 0xc2, 0xbc, 0xae, 0x98, 0x8a,
    0x56, 0x44, 0x72, 0x60, 0x1e, 0x0c, 0x3a, 0x28, 0xc6, 0xd4, 0xe2, 0xf0, 0x8e, 0x9c, 0xaa, 0xb8,
    0xc8, 0xda, 0xec, 0xfe, 0x80, 0x92, 0xa4, 0xb6, 0x58, 0x4a, 0x7c, 0x6e, 0x10, 0x02, 0x34, 0x26,
    0xfa, 0xe8, 0xde, 0xcc, 0xb2, 0xa0, 0x96, 0x84, 0x6a, 0x78, 0x4e, 0x5c, 0x22, 0x30, 0x06, 0x14,
    0xac, 0xbe, 0x88, 0x9a, 0xe4, 0xf6, 0xc0, 0xd2, 0x3c, 0x2e, 0x18, 0x0a, 0x74, 0x66, 0x50, 0x42,
    0x9e, 0x8c, 0xba, 0xa8, 0xd6, 0xc4, 0xf2, 0xe0, 0x0e, 0x1c, 0x2a, 0x38, 0x46, 0x54, 0x62, 0x70,
    0x82, 0x90, 0xa6, 0xb4, 0xca, 0xd8, 0xee, 0xfc, 0x12, 0x00, 0x36, 0x24, 0x5a, 0x48, 0x7e, 0x6c,
    0xb0, 0xa2, 0x94, 0x86, 0xf8, 0xea, 0xdc, 0xce, 0x20, 0x32, 0x04, 0x16, 0x68, 0x7a, 0x4c, 0x5e,
    0xe6, 0xf4, 0xc2, 0xd0, 0xae, 0xbc, 0x8a, 0x98, 0x76, 0x64, 0x52, 0x40, 0x3e, 0x2c, 0x1a, 0x08,
    0xd4, 0xc6, 0xf0, 0xe2, 0x9c, 0x8e, 0xb8, 0xaa, 0x44, 0x56, 0x60, 0x72, 0x0c, 0x1e, 0x28, 0x3a,
    0x4a, 0x58, 0x6e, 0x7c, 0x02, 0x10, 0x26, 0x34, 0xda, 0xc8, 0xfe, 0xec, 0x92, 0x80, 0xb6, 0xa4,
    0x78, 0x6a, 0x5c, 0x4e, 0x30, 0x22, 0x14, 0x06, 0xe8, 0xfa, 0xcc, 0xde, 0xa0, 0xb2, 0x84, 0x96,
    0x2e, 0x3c, 0x0a, 0x18, 0x66, 0x74, 0x42, 0x50, 0xbe, 0xac, 0x9a, 0x88, 0xf6, 0xe4, 0xd2, 0xc0,
    0x1c, 0x0e, 0x38, 0x2a, 0x54, 0x46, 0x70, 0x62, 0x8c, 0x9e, 0xa8, 0xba, 0xc4, 0xd6, 0xe0, 0xf2};

static inline uint8_t __spi_sdcard_crc7(uint8_t *data, uint64_t len) {
    uint8_t state = 0;
    for (uint64_t i = 0; i < len; ++i)
        state = __spi_sdcard_crc7_lookup[(data[i] ^ (state << 1)) & 0xFFU];
    return state;
}

// Lookup table for crc16 polynomial G(x) = x^16 + x^12 + x^5 + 1
static const uint16_t __spi_sdcard_crc16_lookup[] = {
    0x0000, 0x1021, 0x2042, 0x3063, 0x4084, 0x50a5, 0x60c6, 0x70e7, 0x8108, 0x9129, 0xa14a, 0xb16b,
    0xc18c, 0xd1ad, 0xe1ce, 0xf1ef, 0x1231, 0x0210, 0x3273, 0x2252, 0x52b5, 0x4294, 0x72f7, 0x62d6,
    0x9339, 0x8318, 0xb37b, 0xa35a, 0xd3bd, 0xc39c, 0xf3ff, 0xe3de, 0x2462, 0x3443, 0x0420, 0x1401,
    0x64e6, 0x74c7, 0x44a4, 0x5485, 0xa56a, 0xb54b, 0x8528, 0x9509, 0xe5ee, 0xf5cf, 0xc5ac, 0xd58d,
    0x3653, 0x2672, 0x1611, 0x0630, 0x76d7, 0x66f6, 0x5695, 0x46b4, 0xb75b, 0xa77a, 0x9719, 0x8738,
    0xf7df, 0xe7fe, 0xd79d, 0xc7bc, 0x48c4, 0x58e5, 0x6886, 0x78a7, 0x0840, 0x1861, 0x2802, 0x3823,
    0xc9cc, 0xd9ed, 0xe98e, 0xf9af, 0x8948, 0x9969, 0xa90a, 0xb92b, 0x5af5, 0x4ad4, 0x7ab7, 0x6a96,
    0x1a71, 0x0a50, 0x3a33, 0x2a12, 0xdbfd, 0xcbdc, 0xfbbf, 0xeb9e, 0x9b79, 0x8b58, 0xbb3b, 0xab1a,
    0x6ca6, 0x7c87, 0x4ce4, 0x5cc5, 0x2c22, 0x3c03, 0x0c60, 0x1c41, 0xedae, 0xfd8f, 0xcdec, 0xddcd,
    0xad2a, 0xbd0b, 0x8d68, 0x9d49, 0x7e97, 0x6eb6, 0x5ed5, 0x4ef4, 0x3e13, 0x2e32, 0x1e51, 0x0e70,
    0xff9f, 0xefbe, 0xdfdd, 0xcffc, 0xbf1b, 0xaf3a, 0x9f59, 0x8f78, 0x9188, 0x81a9, 0xb1ca, 0xa1eb,
    0xd10c, 0xc12d, 0xf14e, 0xe16f, 0x1080, 0x00a1, 0x30c2, 0x20e3, 0x5004, 0x4025, 0x7046, 0x6067,
    0x83b9, 0x9398, 0xa3fb, 0xb3da, 0xc33d, 0xd31c, 0xe37f, 0xf35e, 0x02b1, 0x1290, 0x22f3, 0x32d2,
    0x4235, 0x5214, 0x6277, 0x7256, 0xb5ea, 0xa5cb, 0x95a8, 0x8589, 0xf56e, 0xe54f, 0xd52c, 0xc50d,
    0x34e2, 0x24c3, 0x14a0, 0x0481, 0x7466, 0x6447, 0x5424, 0x4405, 0xa7db, 0xb7fa, 0x8799, 0x97b8,
    0xe75f, 0xf77e, 0xc71d, 0xd73c, 0x26d3, 0x36f2, 0x0691, 0x16b0, 0x6657, 0x7676, 0x4615, 0x5634,
    0xd94c, 0xc96d, 0xf90e, 0xe92f, 0x99c8, 0x89e9, 0xb98a, 0xa9ab, 0x5844, 0x4865, 0x7806, 0x6827,
    0x18c0, 0x08e1, 0x3882, 0x28a3, 0xcb7d, 0xdb5c, 0xeb3f, 0xfb1e, 0x8bf9, 0x9bd8, 0xabbb, 0xbb9a,
    0x4a75, 0x5a54, 0x6a37, 0x7a16, 0x0af1, 0x1ad0, 0x2ab3, 0x3a92, 0xfd2e, 0xed0f, 0xdd6c, 0xcd4d,
    0xbdaa, 0xad8b, 0x9de8, 0x8dc9, 0x7c26, 0x6c07, 0x5c64, 0x4c45, 0x3ca2, 0x2c83, 0x1ce0, 0x0cc1,
    0xef1f, 0xff3e, 0xcf5d, 0xdf7c, 0xaf9b, 0xbfba, 0x8fd9, 0x9ff8, 0x6e17, 0x7e36, 0x4e55, 0x5e74,
    0x2e93, 0x3eb2, 0x0ed1, 0x1ef0};

static inline uint16_t __spi_sdcard_crc16(uint8_t *data, uint64_t len) {
    uint16_t state = 0;
    for (uint64_t i = 0; i < len; ++i)
        state =
            (__spi_sdcard_crc16_lookup[(data[i] ^ (state >> 8)) & 0xFFU] ^ (state << 8)) & 0xFFFFU;
    // Data block CRC is returned from the card *big endian*, so we accomodate this here
    return ((state & 0xFF) << 8) | ((state & 0xFF00) >> 8);
}

// Launch a single transfer or dummy segment *without* releasing CS afterward
static inline int __spi_sdcard_xfer_csaat(spi_sdcard_t *handle, void *rx, void *tx, uint64_t len) {
    // We should never receive bidirectional transfers
    CHECK_ASSERT(0x11, !(tx && rx))
    // Prepare segment
    dif_spi_host_segment_t seg;
    // Receive bytes
    if (tx)
        seg = (dif_spi_host_segment_t){
            kDifSpiHostSegmentTypeTx,
            {.tx = {.width = kDifSpiHostWidthStandard, .buf = tx, .length = len}}};
    // Send bytes
    else if (rx)
        seg = (dif_spi_host_segment_t){
            kDifSpiHostSegmentTypeRx,
            {.rx = {.width = kDifSpiHostWidthStandard, .buf = rx, .length = len}}};
    // Issue dummy cycles (here, len is *cycles* and not bytes)
    else
        seg = (dif_spi_host_segment_t){
            kDifSpiHostSegmentTypeDummy,
            {.dummy = {.width = kDifSpiHostWidthStandard, .length = 8 * len}}};
    // Issue segment, but keep CS Asserted After Transaction (CSAAT)
    return dif_spi_host_transaction_csaat(&handle->spi_host, handle->csid, &seg, 1);
}

// Issue 8 dummy cycles on an internal dummy CS.
// This deasserts our chip select and ensures the SD card releases sd[1].
static inline int __spi_sdcard_csfree(spi_sdcard_t *handle) {
    dif_spi_host_segment_t seg = {kDifSpiHostSegmentTypeDummy,
                                  {.dummy = {.width = kDifSpiHostWidthStandard, .length = 8}}};
    return dif_spi_host_transaction(&handle->spi_host, handle->csid_dummy, &seg, 1);
}

// Send an SD card command and obtain the data for the expected response
static inline int __spi_sdcard_cmd(spi_sdcard_t *handle, uint64_t cmd, spi_sdcard_resp_t resp,
                                   uint8_t *rdata, int csaat) {
    uint8_t rdummy;
    // If a command is provided, Start CS phase by sending 6-byte command or a 1-byte stop tran
    if (cmd) CHECK_CALL(__spi_sdcard_xfer_csaat(handle, NULL, &cmd, cmd == 0xFD ? 1 : 6))
    // If we sent CMD12, discard stuff byte after command
    if ((cmd & 0xFF) == 0x4C) CHECK_CALL(__spi_sdcard_xfer_csaat(handle, &rdummy, NULL, 1))
    // Poll bytes until we get a response (i.e. most significant bit low)
    int timeout = 8;
    do CHECK_CALL(__spi_sdcard_xfer_csaat(handle, rdata, NULL, 1))
    while (--timeout && *rdata & 0x80);
    if (timeout == 0) return 0x12;
    // Compute how many response bytes remain
    uint64_t rem_bytes = __spi_sdcard_resp_len[resp] - 1;
    // If we expect R1b response, read until busy flag is cleared
    if (resp == kSpiSdcardRespR1b) {
        timeout = __spi_sdcard_r1b_timeout;
        do CHECK_CALL(__spi_sdcard_xfer_csaat(handle, &rdummy, NULL, 1))
        while (--timeout && rdummy == 0);
        if (timeout == 0) return 0x13;
    }
    // Otherwise, read remaining response
    else if (rem_bytes)
        CHECK_CALL(__spi_sdcard_xfer_csaat(handle, rdata + 1, NULL, rem_bytes))
    // Release CS and data lanes if requested
    if (!csaat) CHECK_CALL(__spi_sdcard_csfree(handle));
    // Nothing went wrong
    return 0;
}

// Handle a command and check its response against an expected value or discard it
static inline int __spi_sdcard_cmd_check(spi_sdcard_t *handle, uint64_t cmd, spi_sdcard_resp_t resp,
                                         int check_exp, uint64_t exp) {
    uint64_t buf;
    CHECK_CALL(__spi_sdcard_cmd(handle, cmd, resp, (uint8_t *)&buf, 0))
    uint64_t resp_mask = (1 << (8UL * __spi_sdcard_resp_len[resp])) - 1;
    if (check_exp && ((buf & resp_mask) != (exp & resp_mask))) return buf & resp_mask;
    return 0;
}

// Send commands to SD card needed for initialization
static int __spi_sdcard_activate(spi_sdcard_t *handle) {
    // Issue 80 dummy cycles for the SD Card to wake up
    CHECK_CALL(__spi_sdcard_xfer_csaat(handle, NULL, NULL, 10))
    // SD initialization sequence (repeat ACMD41 if necessary)
    /*CMD0*/ CHECK_CALL(
        __spi_sdcard_cmd_check(handle, 0x950000000040UL, kSpiSdcardRespR1, 1, 0x01UL))
    /*CMD8*/ CHECK_CALL(
        __spi_sdcard_cmd_check(handle, 0x87AA01000048UL, kSpiSdcardRespR7, 1, 0xAA01000001UL))
    uint8_t ret = 1;
    do {
        /*CMD55*/ CHECK_CALL(
            __spi_sdcard_cmd_check(handle, 0x650000000077UL, kSpiSdcardRespR1, 0, 0))
        /*ACMD41*/ CHECK_CALL(__spi_sdcard_cmd(handle, 0x770000004069UL, kSpiSdcardRespR1, &ret, 0))
    } while (ret);
    /*CMD58*/ CHECK_CALL(__spi_sdcard_cmd_check(handle, 0xFD000000007AUL, kSpiSdcardRespR3, 0, 0))
    /*CMD16*/ CHECK_CALL(
        __spi_sdcard_cmd_check(handle, 0x150002000050UL, kSpiSdcardRespR1, 1, 0x00UL))
    // Nothing went wrong
    return 0;
}

int spi_sdcard_init(spi_sdcard_t *handle, uint64_t core_freq) {
    // Check for legal arguments
    CHECK_ASSERT(0x14, handle != 0)
    CHECK_ASSERT(0x15, handle->csid < SPI_HOST_PARAM_NUM_C_S)
    CHECK_ASSERT(0x15, handle->csid_dummy < SPI_HOST_PARAM_NUM_C_S)
    CHECK_ASSERT(0x16, handle->spi_freq != 0)
    CHECK_ASSERT(0x17, handle->spi_freq <= 25 * 1000 * 1000) // Max SD spi speed is 25 MHz
    CHECK_ASSERT(0x18, handle->spi_freq <= core_freq)

    // Initialize handle
    mmio_region_t spi_host_base = (mmio_region_t){.base = (void *)&__base_spih};
    CHECK_CALL(dif_spi_host_init(spi_host_base, &handle->spi_host))
    // Reset SPI host
    dif_spi_host_reset(&handle->spi_host);
    // Configure SPI host for SD card
    dif_spi_host_config_t config = {// TODO: what are appropriate values for these?
                                    //.chip_select = {.idle = 0xF, .lead = 0xF, .trail = 0xF},
                                    .cpha = 0,
                                    .cpol = 0,
                                    .full_cycle = false,
                                    .peripheral_clock_freq_hz = core_freq,
                                    .spi_clock = __spi_sdcard_init_clock};
    // Configure both regular CS and dummy at same speed
    CHECK_CALL(dif_spi_host_configure_cs(&handle->spi_host, config, handle->csid))
    CHECK_CALL(dif_spi_host_configure_cs(&handle->spi_host, config, handle->csid_dummy))
    // Enable SPI host (no traps or interrupts)
    dif_spi_host_enable(&handle->spi_host, 1);
    CHECK_CALL(dif_spi_host_output_set_enabled(&handle->spi_host, 1))
    // Activate SD card
    CHECK_CALL(__spi_sdcard_activate(handle))
    // Update SPI clock to our desired speed
    CHECK_CALL(dif_spi_host_output_set_enabled(&handle->spi_host, 0))
    config.spi_clock = handle->spi_freq;
    CHECK_CALL(dif_spi_host_configure_cs(&handle->spi_host, config, handle->csid))
    CHECK_CALL(dif_spi_host_configure_cs(&handle->spi_host, config, handle->csid_dummy))
    CHECK_CALL(dif_spi_host_output_set_enabled(&handle->spi_host, 1))
    // Nothing went wrong
    return 0;
}

uint64_t __spi_sdcard_build_cmd(uint8_t opcode, uint32_t arg) {
    uint64_t cmd = opcode;
    // Like the CRC, the argument is expected in big endian
    cmd |= (((uint64_t)(arg) >> 24) & 0xff) << 8;
    cmd |= (((uint64_t)(arg) >> 16) & 0xff) << 16;
    cmd |= (((uint64_t)(arg) >> 8) & 0xff) << 24;
    cmd |= (((uint64_t)(arg) >> 0) & 0xff) << 32;
    uint64_t crcbyte = (__spi_sdcard_crc7((uint8_t *)&cmd, 5)) << 1 | 1;
    return (crcbyte << 40) | cmd;
}

// Transfer aligned 512B blocks. We write only part of the first & last block using a swap buffer.
// If the requested transfers are aligned, this buffer may be left unallocated (i.e. NULL).
static int __spi_sdcard_read_blocks(spi_sdcard_t *handle, void *buf, uint64_t block, uint64_t len,
                                    uint8_t *block_swap, uint64_t first_offs, uint64_t last_len,
                                    int check_crc) {
    uint8_t rx;
    // Check if no transfer
    if (len == 0) return 0;
    // CMD17 for single block transfer, CMD18 for multiple
    uint64_t cmd = __spi_sdcard_build_cmd((len > 1) ? 0x52 : 0x51, block);
    // TODO: handle CRC error for prior commands here?
    CHECK_CALL(__spi_sdcard_cmd(handle, cmd, kSpiSdcardRespR1, &rx, 1))
    // Align target buffer with block boundaries
    buf -= first_offs;
    // Read blocks
    for (uint64_t b = 0; b < len; ++b) {
        // Poll bytes until we get a token
        int timeout = __spi_sdcard_data_timeout;
        do CHECK_CALL(__spi_sdcard_xfer_csaat(handle, &rx, NULL, 1))
        while (--timeout && rx == 0xFF);
        if (timeout == 0) return 0x19;
        // Quit on unexpected tokens
        if (rx != 0xFE) return 0x20;
        // Read block in chunks of at most FIFO size
        int first_block = (b == 0 && first_offs != 0);
        int last_block = (b == len - 1 && last_len != 512);
        void *block_dst = buf + 512 * b;
        void *block_buf = (first_block || last_block) ? block_swap : block_dst;
        for (uint64_t offs = 0; offs < 512; offs += 4 * SPI_HOST_PARAM_RX_DEPTH) {
            uint64_t chunk_len = MIN(4 * SPI_HOST_PARAM_RX_DEPTH, 512 - offs);
            CHECK_CALL(__spi_sdcard_xfer_csaat(handle, block_buf + offs, NULL, chunk_len))
        }
        // Read and check CRC16 of block
        uint16_t crc;
        CHECK_CALL(__spi_sdcard_xfer_csaat(handle, &crc, NULL, 2))
        if (check_crc && crc != __spi_sdcard_crc16((uint8_t *)block_buf, 512)) return 0x21;
        // If this block is buffered, copy only relevant contents to destination
        if (first_block && last_block)
            __builtin_memcpy(block_dst + first_offs, block_swap + first_offs,
                             last_len - first_offs);
        else if (first_block)
            __builtin_memcpy(block_dst + first_offs, block_swap + first_offs, 512 - first_offs);
        else if (last_block)
            __builtin_memcpy(block_dst, block_swap, last_len);
    }
    // If this is a multi-block transfer, send CMD12 to end the transaction and detach
    if (len > 1)
        return __spi_sdcard_cmd_check(handle, 0x61000000004CL, kSpiSdcardRespR1b, 0, 0);
    else
        return __spi_sdcard_csfree(handle);
}

// Read any alignment abstracted through blocks with or without CRC
static int __spi_sdcard_read(void *priv, void *buf, uint64_t addr, uint64_t len, int check_crc) {
    // Allocate swap buffer
    uint8_t swap[512];
    // Handle block alignment
    if (len == 0) return 0;
    uint64_t block = addr / 512;
    uint64_t first_offs = addr % 512;
    uint64_t pte_offs = (addr + len) % 512;
    uint64_t last_len = (pte_offs == 0) ? 512 : pte_offs;
    uint64_t len_blocks = (len + first_offs + 511) / 512;
    // Read blocks
    return __spi_sdcard_read_blocks((spi_sdcard_t *)priv, buf, block, len_blocks, swap, first_offs,
                                    last_len, check_crc);
}

int spi_sdcard_read_checkcrc(void *priv, void *buf, uint64_t addr, uint64_t len) {
    return __spi_sdcard_read(priv, buf, addr, len, 1);
}

int spi_sdcard_read_ignorecrc(void *priv, void *buf, uint64_t addr, uint64_t len) {
    return __spi_sdcard_read(priv, buf, addr, len, 0);
}

int spi_sdcard_write_blocks(spi_sdcard_t *handle, void *buf, uint64_t block, uint64_t len,
                            int compute_crc) {
    uint8_t rx;
    // Check if no transfer
    if (len == 0) return 0;
    // TODO: in case of CMD25, issue ACMD23 for pre-erase here
    // CMD24 for single block transfer, CMD25 for multiple
    uint64_t cmd = __spi_sdcard_build_cmd((len > 1) ? 0x59 : 0x58, block);
    uint8_t tok = (len > 1) ? 0xFE : 0xFC;
    // TODO: handle CRC error for prior commands here?
    CHECK_CALL(__spi_sdcard_cmd(handle, cmd, kSpiSdcardRespR1, &rx, 1))
    // Insert safety dummy byte
    CHECK_CALL(__spi_sdcard_xfer_csaat(handle, NULL, NULL, 1));
    // Write blocks
    for (uint64_t b = 0; b < len; ++b) {
        // Send token
        CHECK_CALL(__spi_sdcard_xfer_csaat(handle, NULL, &tok, 1));
        // Write block in chunks of at most FIFO size
        void *block_src = buf + 512 * b;
        for (uint64_t offs = 0; offs < 512; offs += 4 * SPI_HOST_PARAM_RX_DEPTH)
            CHECK_CALL(__spi_sdcard_xfer_csaat(handle, NULL, block_src + offs, 512))
        // Write CRC16 of block
        uint16_t crc = compute_crc ? __spi_sdcard_crc16((uint8_t *)block_src, 512) : 0;
        CHECK_CALL(__spi_sdcard_xfer_csaat(handle, NULL, &crc, 2))
        // Get response and wait until no longer busy
        CHECK_CALL(__spi_sdcard_cmd(handle, 0, kSpiSdcardRespR1b, &rx, 1))
        // Verify that response is 'data accepted'
        if ((rx & 0x1F) != 0x09) return 0x22;
    }
    // If this is a multi-block transfer, send stop tran to end the transaction and detach
    if (len > 1)
        return __spi_sdcard_cmd(handle, 0xFD, kSpiSdcardRespR1b, &rx, 0);
    else
        return __spi_sdcard_csfree(handle);
}
