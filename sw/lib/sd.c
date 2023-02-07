// Copyright 2022 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Nicole Narr <narrn@student.ethz.ch>
// Christopher Reinwardt <creinwar@student.ethz.ch>

#ifndef SD_C_
#define SD_C_

//#define DEBUG 1

#include "sd.h"
#include "crc.h"
#include "printf.h"
#include <stddef.h>

unsigned char const sd_resp_len[] = {
    1, // R1
    1, // R1b
    2, // R2
    5, // R3
    0, // R4 -- Unused
    0, // R5 -- Unused
    0, // Unused
    5  // R7
};

static int sd_cmd(opentitan_qspi_t *spi, unsigned long int cmd, unsigned char *resp, sd_resp_t rtyp) {
    unsigned int resp_len = (unsigned char)sd_resp_len[rtyp];
    unsigned int rcv_len = 4 * ((resp_len + 3) / 4);
    int rcv_left = (int)resp_len, ret = 0;
    char txbuf[6], rxbuf[8], rcvd = 0, r1_busy = 1, fst = 0;

    if (rcv_len > 8) {
#ifdef DEBUG
        printf("[sd] resp_len 0x%x too large for sd_cmd (max is 8)\r\n", resp_len);
#endif
        return -1;
    }

    // Fill command buffer
    txbuf[0] = (cmd >> 40) & 0xFFL;
    txbuf[1] = (cmd >> 32) & 0xFFL;
    txbuf[2] = (cmd >> 24) & 0xFFL;
    txbuf[3] = (cmd >> 16) & 0xFFL;
    txbuf[4] = (cmd >> 8) & 0xFFL;
    txbuf[5] = cmd & 0xFFL;

    // Send the command to the SD Card
    ret = opentitan_qspi_xfer(spi, 48, txbuf, NULL, SPI_XFER_BEGIN);
    if (ret)
        return ret;

    // Wait on the response
    while (rcv_left > 0) {
        ret = opentitan_qspi_xfer(spi, 8 * rcv_len, NULL, rxbuf, 0);
        if (ret)
            return ret;

        for (unsigned int i = 0; i < rcv_len; i++) {
            // CMD12 -> Skip the first byte immediately following the command
            if (!fst && txbuf[0] == 0x4C) {
                fst = 1;
                continue;
            }

            if (!rcvd && !(rxbuf[i] & 0x80)) {
                rcvd = 1;
            }

            if (rcvd) {
                if (rcv_left > 0) {
                    resp[rcv_left-- - 1] = rxbuf[i];
                } else if (rtyp == SD_RESP_R1b && r1_busy) {
                    r1_busy = (rxbuf[i] == 0);
                }
            }

#ifdef DEBUG
            // printf("[sd] sd_cmd received 0x%x\r\n", rxbuf[i]);
            // printf("[sd] rcv_left = %d\r\n", rcv_left);
#endif
        }
    }

    if ((rtyp == SD_RESP_R1b) && r1_busy) {
        for (int b = 0; b < SD_R1b_TIMEOUT; b++) {
            ret = opentitan_qspi_xfer(spi, 4 * 8, NULL, rxbuf, 0);

            for (int i = 0; i < 4; i++) {
                if (rxbuf[i]) {
                    r1_busy = 0;
                    break;
                }
            }

            if (!r1_busy)
                break;
        }
    }

    return opentitan_qspi_xfer(spi, 0, NULL, NULL, SPI_XFER_END);
}

int sd_init(opentitan_qspi_t *spi) {
    unsigned long int buf = 0;
    int ret = 0;

    // Issue 80 dummy cycles for the SD Card to wake up
    ret = opentitan_qspi_xfer(spi, 80, NULL, NULL, 0);
    if (ret)
        return ret;

    //--------------
    //    CMD0 - 0x400000000095
    //--------------
    ret = sd_cmd(spi, 0x400000000095L, (unsigned char *)&buf, SD_RESP_R1);

    if (ret)
        return ret;

#ifdef DEBUG
    printf("[sd] CMD0 response: 0x%x\r\n", buf);
#endif

    if ((buf & 0xFF) != 0x1)
        return (buf & 0xFF);

    buf = 0;

    //--------------
    //    CMD8 - 0x48000001AA87
    //--------------
    ret = sd_cmd(spi, 0x48000001AA87L, (unsigned char *)&buf, SD_RESP_R7);

    if (ret)
        return ret;

#ifdef DEBUG
    printf("[sd] CMD8 response: 0x%lx\r\n", buf);
#endif

    if ((buf & 0xFFFFFFFFFFL) != 0x01000001AA)
        return (buf & 0xFF);

    buf = 0;

    //--------------
    //    CMD55 - 0x770000000065
    //--------------
    ret = sd_cmd(spi, 0x770000000065, (unsigned char *)&buf, SD_RESP_R1);

    if (ret)
        return ret;

#ifdef DEBUG
    printf("[sd] CMD55 response: 0x%lx\r\n", buf);
#endif

    buf = 0;

    //--------------
    //   ACMD41 - 0x694000000077
    //--------------
    ret = sd_cmd(spi, 0x694000000077, (unsigned char *)&buf, SD_RESP_R1);

    if (ret)
        return ret;

#ifdef DEBUG
    printf("[sd] ACMD41 response: 0x%lx\r\n", buf);
#endif

    // ACMD41 may need to be repeated
    while ((buf & 0xFF) != 0x0) {

        buf = 0;
        //--------------
        //    CMD55 - 0x770000000065
        //--------------
        ret = sd_cmd(spi, 0x770000000065, (unsigned char *)&buf, SD_RESP_R1);

        if (ret)
            return ret;

#ifdef DEBUG
        printf("[sd] CMD55 response: 0x%lx\r\n", buf);
#endif
        buf = 0;

        //--------------
        //   ACMD41 - 0x694000000077
        //--------------
        ret = sd_cmd(spi, 0x694000000077, (unsigned char *)&buf, SD_RESP_R1);

        if (ret)
            return ret;

#ifdef DEBUG
        printf("[sd] ACMD41 response: 0x%lx\r\n", buf);
#endif
    }

    buf = 0;

    //--------------
    //    CMD58 - 0x7A00000000FD
    //--------------
    ret = sd_cmd(spi, 0x7A00000000FDL, (unsigned char *)&buf, SD_RESP_R3);

    if (ret)
        return ret;

#ifdef DEBUG
    printf("[sd] CMD58 response: 0x%x\r\n", buf);
#endif

    buf = 0;

    //--------------
    //    CMD16 - 0x500000020015
    //--------------
    ret = sd_cmd(spi, 0x500000020015L, (unsigned char *)&buf, SD_RESP_R1);

    if (ret)
        return ret;

#ifdef DEBUG
    printf("[sd] CMD16 response: 0x%x\r\n", buf);
#endif

    if ((buf & 0xFF) != 0x0)
        return (buf & 0xFF);

    return 0;
}

int sd_read_blocks(opentitan_qspi_t *spi, unsigned int lba, unsigned char *mem_addr, unsigned int num_blocks) {
    unsigned long int cmd = 0;
    int ret = 0;
    unsigned short crc = 0, exp_crc = 0;
    char txbuf[6];
    char cmd_stat = 0;

    if (num_blocks == 0) {
        return 0;
    } else if (num_blocks == 1) {
        cmd = (0x51L << 40) | (lba << 8); // CMD17 - Single 512 byte block transfer
#ifdef DEBUG
        printf("[sd] Single block transfer from LBA 0x%lx to 0x%lx\r\n", lba, mem_addr);
#endif
    } else {
        cmd = (0x52L << 40) | (lba << 8); // CMD18 - Multi-block transfer
#ifdef DEBUG
        printf("[sd] Multi block transfer of %d blocks from LBA 0x%lx to 0x%lx\r\n", num_blocks, lba, mem_addr);
#endif
    }

    // Calculate the CRC for the command
    cmd |= (crc7((unsigned char *)&cmd, 5, 0) << 1) | 1;

    // Fill command buffer
    txbuf[0] = (cmd >> 40) & 0xFFL;
    txbuf[1] = (cmd >> 32) & 0xFFL;
    txbuf[2] = (cmd >> 24) & 0xFFL;
    txbuf[3] = (cmd >> 16) & 0xFFL;
    txbuf[4] = (cmd >> 8) & 0xFFL;
    txbuf[5] = cmd & 0xFFL;

    // Send the command to the SD Card
    ret = opentitan_qspi_xfer(spi, 6 * 8, txbuf, NULL, SPI_XFER_BEGIN);
    if (ret)
        return ret;

    for (unsigned int i = 0; i < num_blocks; i++) {
        unsigned int bytes_left = 512;
        char rxbuf[4];
        char rcvd = 0;

        // Wait for the begin of the block transfer
        while (!rcvd) {
            ret = opentitan_qspi_xfer(spi, 4 * 8, NULL, rxbuf, 0);
            if (ret)
                return ret;

            // Scan
            for (int b = 0; b < 4; b++) {
                if (!rcvd) {
                    if (!cmd_stat) {
                        if (!(rxbuf[b] & 0x80)) {
                            cmd_stat = 1;
#ifdef DEBUG
                            printf("[sd] Got block read command response: 0x%x\r\n", rxbuf[b]);
#endif
                        }
                    } else {
                        if (rxbuf[b] == 0xFE) {
                            rcvd = 1;
#ifdef DEBUG
                            // printf("[sd] Start token received!\r\n");
#endif
                        } else if (!(rxbuf[b] & 0xF0)) {
#ifdef DEBUG
                            printf("[sd] Error token received: 0x%x\r\n", rxbuf[b]);
#endif
                            opentitan_qspi_xfer(spi, 0, NULL, NULL, SPI_XFER_END);
                            return (int)rxbuf[b];
                        }
                    }
                } else {
                    mem_addr[(i + 1) * 512 - bytes_left--] = rxbuf[b];
                }
            }
        }

        // We have the start token (and potentially already some data)
        // so lets transfer the rest in bulk
        ret =
            opentitan_qspi_xfer(spi, bytes_left * 8, NULL, (unsigned char *)(mem_addr + (i + 1) * 512 - bytes_left), 0);
        if (ret)
            return ret;

        // And then we read the CRC16
        ret = opentitan_qspi_xfer(spi, 2 * 8, NULL, rxbuf, 0);
        if (ret)
            return ret;

        crc = (rxbuf[0] << 8) | rxbuf[1];

        exp_crc = crc16((unsigned char *)(mem_addr + i * 512), 512, 1);

        if (crc != exp_crc) {
#ifdef DEBUG
            printf("[sd] Block read to 0x%lx has a CRC mismatch: Read: 0x%x, computed: 0x%x\r\n",
                   (unsigned long int)(mem_addr + i * 512), crc, exp_crc);
#endif
            return -1;
        }
    }

    if (num_blocks > 1) {
        unsigned long int buf = 0;
        ret = sd_cmd(spi, 0x4C0000000061L, (unsigned char *)&buf, SD_RESP_R1b);

#ifdef DEBUG
        printf("[sd] CMD12 response: 0x%x\r\n", buf);
#endif
    } else {
        opentitan_qspi_xfer(spi, 0, NULL, NULL, SPI_XFER_END);
    }

    return ret;
}

int sd_read_blocks_callback(void *priv, unsigned int lba, void *mem_addr, unsigned int num_blocks) {
    return sd_read_blocks((opentitan_qspi_t *)priv, lba, (unsigned char *)mem_addr, num_blocks);
}

int sd_write_blocks(opentitan_qspi_t *spi, unsigned int lba, unsigned char *mem_addr, unsigned int num_blocks) {
    unsigned long int cmd = 0;
    int ret = 0;
    unsigned short crc = 0;
    unsigned short status = 0xFF;
    unsigned char txbuf[6] = {0};
    unsigned char rxbuf[4] = {0};
    unsigned char resp = 0xFF;

    if (num_blocks == 0) {
        return 0;
    } else if (num_blocks == 1) {
        cmd = (0x58L << 40) | (lba << 8); // CMD24 - Single 512 byte block write
#ifdef DEBUG
        printf("[sd] Single block write from 0x%lx to LBA 0x%lx\r\n", mem_addr, lba);
#endif
    } else {
        cmd = (0x59L << 40) | (lba << 8); // CMD25 - Multi-block write
#ifdef DEBUG
        printf("[sd] Multi block write of %d blocks from 0x%lx to LBA 0x%lx\r\n", num_blocks, mem_addr, lba);
#endif
    }

    // Calculate the CRC for the command
    cmd |= (crc7((unsigned char *)&cmd, 5, 0) << 1) | 1;

    // Fill command buffer
    txbuf[0] = (cmd >> 40) & 0xFFL;
    txbuf[1] = (cmd >> 32) & 0xFFL;
    txbuf[2] = (cmd >> 24) & 0xFFL;
    txbuf[3] = (cmd >> 16) & 0xFFL;
    txbuf[4] = (cmd >> 8) & 0xFFL;
    txbuf[5] = cmd & 0xFFL;

    // Send the command to the SD Card
    ret = opentitan_qspi_xfer(spi, 6 * 8, txbuf, NULL, SPI_XFER_BEGIN);
    if (ret)
        return ret;

    // Wait for the response
    while (resp & 0x80) {
        ret = opentitan_qspi_xfer(spi, 4 * 8, NULL, rxbuf, 0);
        for (int i = 0; i < 4; i++) {
            if (!(rxbuf[i] & 0x80)) {
                resp = rxbuf[i];
                break;
            }
        }
    }

    if (resp != 0) {
#ifdef DEBUG
        printf("[sd] CMD%u got response 0x%x\r\n", txbuf[0] & 0x3F, resp);
#endif
        ret = resp;
        goto sd_write_blocks_end_transaction_out;
    }

    // Send out the block(s)
    for (int i = 0; i < num_blocks; i++) {
        unsigned char token = 0xFC; // Multi block write start token

        if (num_blocks == 1) {
            token = 0xFE; // Single block write start token
        }

        // Send the start token to the SD Card
        ret = opentitan_qspi_xfer(spi, 1 * 8, (unsigned char *)&token, NULL, 0);
        if (ret)
            return ret;

        // Send the data block to the SD Card
        ret = opentitan_qspi_xfer(spi, 512 * 8, mem_addr + i * 512, NULL, 0);
        if (ret)
            return ret;

        // Calculate the block CRC and send it to the card
        crc = crc16((unsigned char *)(mem_addr + i * 512), 512, 1);
#ifdef DEBUG
        printf("[sd] Block No. %u written to LBA 0x%lx with CRC 0x%x\r\n", i, lba + i, crc);
#endif

        ret = opentitan_qspi_xfer(spi, 2 * 8, (unsigned char *)&crc, NULL, 0);
        if (ret)
            return ret;

        // Read status response and wait for busy to clear
        unsigned char data_resp = 0xFF;

        while (data_resp & 0x10) {
            ret = opentitan_qspi_xfer(spi, 4 * 8, NULL, rxbuf, 0);
            if (ret)
                return ret;

            for (int rx = 0; rx < 4; rx++) {
                if (rxbuf[rx] & 0x01 && !(rxbuf[rx] & 0x10)) {
                    data_resp = rxbuf[rx];
                    break;
                }
            }
        }

        switch ((data_resp >> 1) & 0x07) {
        // status = 010 ==> Data accepted
        case 0x02:
            break;

        // status = 101 ==> Data rejected due to CRC error
        case 0x05:
#ifdef DEBUG
            printf("[sd] Card rejected block No. %u with CRC error\r\n", i);
#endif
            ret = -1;
            goto sd_write_blocks_end_transaction_out;
            break;

        // status = 110 ==> Data rejected due to write error
        case 0x06:
#ifdef DEBUG
            printf("[sd] Card rejected block No. %u with write error\r\n", i);
#endif
            ret = -1;
            goto sd_write_blocks_end_transaction_out;
            break;

        // unknown status
        default:
#ifdef DEBUG
            printf("[sd] Card returned unknown status on block No. %u\r\n", i);
#endif
            ret = -1;
            goto sd_write_blocks_end_transaction_out;
            break;
        }

        // Now we finally wait for the busy to clear
        unsigned char busy = 1;
        for (int b = 0; b < SD_R1b_TIMEOUT; b++) {
            ret = opentitan_qspi_xfer(spi, 4 * 8, NULL, rxbuf, 0);

            for (int i = 0; i < 4; i++) {
                if (rxbuf[i]) {
                    busy = 0;
                    break;
                }
            }

            if (!busy)
                break;
        }

        if (busy) {
#ifdef DEBUG
            printf("[sd] Timed out while waiting for busy to clear after block write\r\n");
#endif
            ret = -1;
            goto sd_write_blocks_end_transaction_out;
        }
    }

    // Send stop token and wait for busy to clear
    // if we wrote more than one block
    if (num_blocks > 1) {
        unsigned char token = 0xFD;

        ret = opentitan_qspi_xfer(spi, 1 * 8, (unsigned char *)&token, NULL, 0);
        if (ret)
            return ret;

        // Wait for the busy to clear
        unsigned char busy = 1;
        for (int b = 0; b < SD_R1b_TIMEOUT; b++) {
            ret = opentitan_qspi_xfer(spi, 4 * 8, NULL, rxbuf, 0);
            if (ret)
                return ret;

            for (int i = 0; i < 4; i++) {
                if (rxbuf[i]) {
                    busy = 0;
                    break;
                }
            }

            if (!busy)
                break;
        }

        if (busy) {
#ifdef DEBUG
            printf("[sd] Timed out while waiting for busy to clear after stop token\r\n");
#endif
            ret = -1;
            goto sd_write_blocks_end_transaction_out;
        }
    }

sd_write_blocks_end_transaction_out:
    opentitan_qspi_xfer(spi, 0, NULL, NULL, SPI_XFER_END);

    //--------------
    //    CMD13 - 0x4D0000000006
    //--------------
    if (!ret) {
        ret = sd_cmd(spi, 0x4D0000000006L, (unsigned char *)&status, SD_RESP_R2);
    } else {
        (void)sd_cmd(spi, 0x4D0000000006L, (unsigned char *)&status, SD_RESP_R2);
    }

#ifdef DEBUG
    printf("[sd] Status after write: 0x%x\r\n", status);
#endif

    return ret;
}

int sd_write_blocks_callback(void *priv, unsigned int lba, void *mem_addr, unsigned int num_blocks) {
    return sd_write_blocks((opentitan_qspi_t *)priv, lba, (unsigned char *)mem_addr, num_blocks);
}

#endif
