// Copyright 2023 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Nicole Narr <narrn@student.ethz.ch>
// Christopher Reinwardt <creinwar@student.ethz.ch>

#ifndef SPI_FLASH_C_
#define SPI_FLASH_C_

#include "opentitan_qspi.h"
#include "printf.h"
#include "spi_flash.h"

int spi_flash_read_blocks_callback(void *priv, unsigned int lba, void *mem_addr, unsigned int num_blocks)
{
    return spi_flash_read_blocks((opentitan_qspi_t *) priv, lba, (unsigned char *) mem_addr, num_blocks);
}

int spi_flash_read_blocks(opentitan_qspi_t *spi, unsigned int lba, unsigned char *mem_addr, unsigned int num_blocks)
{
    unsigned int byte_addr = lba * 512;
    char txbuf[5] = {0};

    // So you don't want data?
    if(num_blocks == 0)
        return 0;

    // This overflows our address space so no way to get to that LBA
    if(lba >= 0x800000)
        return -1;

    // We can only transfer 500 MB with a single transaction
    if(num_blocks >= 0x100000)
        return -1;

    // Command 0x13 is slower but can read the whole flash memory... let's use that then
    txbuf[0] = 0x13;
    txbuf[1] = (byte_addr >> 24) & 0xFF;
    txbuf[2] = (byte_addr >> 16) & 0xFF;
    txbuf[3] = (byte_addr >>  8) & 0xFF;
    txbuf[4] =  byte_addr        & 0xFF;

    // Send command to SPI flash
    opentitan_qspi_xfer(spi, 5 * 8, txbuf, NULL, SPI_XFER_BEGIN);

    // And now we read out the data
    return opentitan_qspi_xfer(spi, num_blocks * 512 * 8, NULL, mem_addr, SPI_XFER_END);
}


#endif
