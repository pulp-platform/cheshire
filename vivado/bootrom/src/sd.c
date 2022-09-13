// Copyright 2022 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Nicole Narr <narrn@student.ethz.ch>
// Christopher Reinwardt <creinwar@student.ethz.ch>

#include "sd.h"

uint64_t sd_cmd_shuffle(uint64_t cmd)
{
    uint64_t real_cmd = 0;
    real_cmd = (cmd >> 40) & 0xFF;
    real_cmd |= (cmd >> 24) & (0xFFL << 8);
    real_cmd |= (cmd >> 8) & (0xFFL << 16);
    real_cmd |= (cmd << 8) & (0xFFL << 24);
    real_cmd |= (cmd << 24) & (0xFFL << 32);
    real_cmd |= (cmd << 40) & (0xFFL << 40);
    return real_cmd;
}

void sd_wait_response(spi_handle_t *spi, uint32_t resp_bytes, uint8_t *buf)
{
    volatile spi_chstatus_t rxstat;
    volatile uint32_t* fifo = spi->mmio.base + SPI_HOST_DATA_REG_OFFSET;
    uint32_t recvd_bytes = 0;
    uint8_t resp = 0;
    
    do {
        rxstat = spi_get_rx_flags(spi);
    } while(rxstat.empty || spi_get_rx_queue_depth(spi) < (resp_bytes+3)/4);

    buf = buf + (resp_bytes - 1);

    while(spi_get_rx_queue_depth(spi) > 0){
        // Read fifo contents
        uint32_t tmp = *fifo;

        for(int i = 0; i < 4; i++){
            uint8_t rb = (uint8_t) (tmp >> 8*i) & 0xFF;
            if(!resp && !(rb & 0x80)){
                    resp = 1;
            }

            if(resp && recvd_bytes < resp_bytes){
                *buf = rb;
                buf--;
                recvd_bytes++;
            }

            // Read as many bytes as we were supposed to
            if(recvd_bytes >= resp_bytes){
                return;
            }
        }
    }
}


void sd_cmd(spi_handle_t *spi, uint64_t cmd, uint8_t *resp, uint64_t resp_len)
{
    uint64_t real_cmd = sd_cmd_shuffle(cmd);

    // Write 4 MSB bytes of CMD
    uint32_t spi_cmd = spi_assemble_command((spi_command_t){
        .len        = 3,
        .csaat      = true,
        .speed      = kSpiSpeedStandard,
        .direction  = kSpiDirTxOnly
    });

    // High 4 bytes of CMD
    spi_write_word(spi, real_cmd & 0xFFFFFFFF);
    spi_wait_for_ready(spi);

    // Send first 4 byte
    spi_set_command(spi, spi_cmd);
    spi_wait_for_ready(spi);

    spi_write_word(spi, (real_cmd >> 32) & 0xFFFF);
    spi_wait_for_ready(spi);

    // Send last 2 byte
    spi_cmd = spi_assemble_command((spi_command_t){
        .len        = 1,
        .csaat      = true,
        .speed      = kSpiSpeedStandard,
        .direction  = kSpiDirTxOnly
    });
    spi_set_command(spi, spi_cmd);
    spi_wait_for_ready(spi);

    // Merge 8 dummy cycles with the read
    spi_cmd = spi_assemble_command((spi_command_t){
        .len        = ((resp_len + 3)/4)*4 - 1,
        .csaat      = false,
        .speed      = kSpiSpeedStandard,
        .direction  = kSpiDirRxOnly
    });
    spi_set_command(spi, spi_cmd);
    spi_wait_for_ready(spi);

    sd_wait_response(spi, resp_len, resp);
}


// Bring SD Card out of reset into idle mode
int sd_init(spi_handle_t *spi)
{
    //--------------
    //    CMD0 - 0x400000000095
    //--------------

    uint64_t buf = 0;

    sd_cmd(spi, 0x400000000095L, (uint8_t *) &buf, 1);

#ifdef DEBUG
    printf_("CMD0 response: 0x%x\r\n", buf);
#endif

    if((buf & 0xFF) != 0x1)
        return (buf & 0xFF);

    buf = 0;

    //--------------
    //    CMD8 - 0x48000001AA87
    //--------------

    sd_cmd(spi, 0x48000001AA87L, (uint8_t *) &buf, 5);

#ifdef DEBUG
    printf_("CMD8 response: 0x%lx\r\n", buf);
#endif

    if((buf & 0xFFFFFFFFFFL) != 0x01000001AA)
        return (buf & 0xFF);

    buf = 0;
 
    //--------------
    //    CMD55 - 0x770000000065
    //--------------

    sd_cmd(spi, 0x770000000065, (uint8_t *) &buf, 1);

#ifdef DEBUG
    printf_("CMD55 response: 0x%lx\r\n", buf);
#endif

    buf = 0;

    //--------------
    //   ACMD41 - 0x694000000077
    //--------------

    sd_cmd(spi, 0x694000000077, (uint8_t *) &buf, 1);

#ifdef DEBUG
    printf_("ACMD41 response: 0x%lx\r\n", buf);
#endif

    // ACMD41 may need to be repeated
    while((buf & 0xFF) != 0x0){

        //--------------
        //    CMD55 - 0x770000000065
        //--------------

        buf = 0;

        sd_cmd(spi, 0x770000000065, (uint8_t *) &buf, 1);

#ifdef DEBUG
        printf_("CMD55 response: 0x%lx\r\n", buf);
#endif
        buf = 0;

        //--------------
        //   ACMD41 - 0x694000000077
        //--------------

        sd_cmd(spi, 0x694000000077, (uint8_t *) &buf, 1);

#ifdef DEBUG
        printf_("ACMD41 response: 0x%lx\r\n", buf);
#endif
    }

    //--------------
    //    CMD16 - 0x5000000200FF
    //--------------

    buf = 0;
    sd_cmd(spi, 0x5000000200FFL, (uint8_t *) &buf, 1);

#ifdef DEBUG
    printf_("CMD16 response: 0x%x\r\n", buf);
#endif

    if((buf & 0xFF) != 0x0)
        return (buf & 0xFF);

    return 0;
}

// Read one 512 byte block (in two 256 byte steps) and return the CRC-16
uint16_t sd_read_block(spi_handle_t *spi, uint8_t *soc_addr)
{
    volatile spi_chstatus_t rxstat;
    volatile uint32_t* fifo = spi->mmio.base + SPI_HOST_DATA_REG_OFFSET;
    uint32_t spi_cmd = 0;
    uint8_t start_token_received = 0;
    uint32_t bytes_left = 512;

    // Now we wait for a start block token (0xFE)
    do {
        uint32_t data = 0;
        uint8_t tmp = 0;
        // Read 4 bytes and check each one
        // discarding the ones before the start block token
        // and transferring the ones after to their destination
        spi_cmd = spi_assemble_command((spi_command_t){
            .len        = 3,
            .csaat      = true,
            .speed      = kSpiSpeedStandard,
            .direction  = kSpiDirRxOnly
        });

        spi_wait_for_ready(spi);
        spi_set_command(spi, spi_cmd);

        do {
            rxstat = spi_get_rx_flags(spi);
        } while(rxstat.empty || spi_get_rx_queue_depth(spi) < 1);

        data = *fifo;

        for(int i = 0; i < 4; i++){
            tmp = (data >> 8*i) & 0xFF;

            if(!start_token_received){
                if(tmp == 0xFE){
                    start_token_received = 1;
                    #ifdef DEBUG
                    printf_("Got start token!\r\n");
                    #endif
                }

                #ifdef DEBUG
                if(!(tmp & 0x80)){
                    printf_("Block Read status: 0x%x\r\n", tmp);
                }
                #endif

            } else {
                *soc_addr = tmp;
                soc_addr++;
                bytes_left--;
            }
        }

    } while (!start_token_received);

    // Read data in chunks of 256 bytes
#ifdef DEBUG
    printf_("Started first chunk transfer\r\n");
#endif

    uint32_t data = 0;

    spi_cmd = spi_assemble_command((spi_command_t){
        .len        = 255,
        .csaat      = true,
        .speed      = kSpiSpeedStandard,
        .direction  = kSpiDirRxOnly
    });

    spi_wait_for_ready(spi);
    spi_set_command(spi, spi_cmd);
    
    do {
        rxstat = spi_get_rx_flags(spi);
    } while(rxstat.empty || spi_get_rx_queue_depth(spi) < 64);

    for(int i = 0; i < 64; i++){
        data = *fifo;
        *soc_addr++ = data & 0xFF;
        *soc_addr++ = (data >> 8) & 0xFF;
        *soc_addr++ = (data >> 16) & 0xFF;
        *soc_addr++ = (data >> 24) & 0xFF;
    }

    bytes_left -= 256;

    // Transfer the rest of the data with a variable length (<= 256)
    uint32_t tmp_data = 0;
    uint32_t leftover = ((bytes_left+3)/4)*4 - 1;
    uint32_t overread = leftover + 1 - bytes_left;

#ifdef DEBUG
    printf("Started second chunk transfer\r\n");
    printf("bytes_left: %d, leftover: %d, overread: %d\r\n", bytes_left, leftover, overread);
#endif

    spi_cmd = spi_assemble_command((spi_command_t){
        .len        = leftover,
        .csaat      = true,
        .speed      = kSpiSpeedStandard,
        .direction  = kSpiDirRxOnly
    });

    spi_wait_for_ready(spi);
    spi_set_command(spi, spi_cmd);

    do {
        rxstat = spi_get_rx_flags(spi);
    } while(rxstat.empty || spi_get_rx_queue_depth(spi) < (bytes_left+3)/4);

    for(int i = 0; i < bytes_left/4; i++){
        tmp_data = *fifo;
        *soc_addr++ = tmp_data & 0xFF;
        *soc_addr++ = (tmp_data >> 8) & 0xFF;
        *soc_addr++ = (tmp_data >> 16) & 0xFF;
        *soc_addr++ = (tmp_data >> 24) & 0xFF;
    }

    bytes_left -= (bytes_left/4)*4;

    tmp_data = *fifo;
    for(int i = 0; i < bytes_left; i++){
        *soc_addr++ = (tmp_data >> 8*i) & 0xFF;
    }

#ifdef DEBUG
    printf("rx_queue_depth: %d\r\n", spi_get_rx_queue_depth(spi));
#endif

    uint16_t res_crc = 0;
    uint8_t *res_crc_ptr = (uint8_t *) &res_crc;

    // Transfer four bytes to make sure to get the 16 bit CRC
    // and provide enough dummy cycles afterwards
    spi_cmd = spi_assemble_command((spi_command_t){
        .len        = 3,
        .csaat      = false,
        .speed      = kSpiSpeedStandard,
        .direction  = kSpiDirRxOnly
    });

    spi_wait_for_ready(spi);
    spi_set_command(spi, spi_cmd);

    do {
        rxstat = spi_get_rx_flags(spi);
    } while(rxstat.empty || spi_get_rx_queue_depth(spi) < 1);

    switch(overread){
        case 0: tmp_data = *fifo;
                res_crc_ptr[1] = tmp_data & 0xFF;
                res_crc_ptr[0] = (tmp_data >> 8) & 0xFF;
                break;

        case 1: res_crc_ptr[1] = (tmp_data >> 24) & 0xFF;
                tmp_data = *fifo;
                res_crc_ptr[0] = tmp_data & 0xFF;
                break;

        case 2: res_crc_ptr[1] = (tmp_data >> 16) & 0xFF;
                res_crc_ptr[0] = (tmp_data >> 8) & 0xFF;
                (void) *fifo;
                break;

        case 3: res_crc_ptr[1] = (tmp_data >> 8) & 0xFF;
                res_crc_ptr[0] = (tmp_data >> 16) & 0xFF;
                (void) *fifo;
                break;

        default: printf_("Read more than 4 bytes too much? overread = %d\r\n", overread);
                 (void) *fifo;
                 break;
    }
    return res_crc;
}

void sd_copy_blocks(spi_handle_t *spi, uint64_t sd_addr, uint8_t *soc_addr, uint32_t num_blocks)
{
    uint64_t cmd = 0;
    uint32_t spi_cmd = 0;

    if(num_blocks == 0){
        return;
    } else if(num_blocks == 1){
        cmd = sd_cmd_shuffle((0x51L << 40) | (sd_addr << 8) | 0x01);   // CMD17 - Single 512 byte block transfer
        printf_("Single block transfer from LBA 0x%lx to 0x%lx\r\n", sd_addr, soc_addr);
    } else {
        cmd = sd_cmd_shuffle((0x52L << 40) | (sd_addr << 8) | 0x01);   // CMD18 - Multi-block transfer
        printf_("Multi block transfer of %d blocks from LBA 0x%lx to 0x%lx\r\n", num_blocks, sd_addr, soc_addr);
    }

    spi_wait_for_ready(spi);
    spi_write_word(spi, cmd & 0xFFFFFFFFL);

    // Write 4 MSB bytes of CMD
    spi_cmd = spi_assemble_command((spi_command_t){
        .len        = 3,
        .csaat      = true,
        .speed      = kSpiSpeedStandard,
        .direction  = kSpiDirTxOnly
    });

    spi_wait_for_ready(spi);
    spi_set_command(spi, spi_cmd);

    spi_wait_for_ready(spi);
    spi_write_word(spi, (cmd >> 32) & 0xFFFF);

    // Write 2 LSB bytes of CMD
    spi_cmd = spi_assemble_command((spi_command_t){
        .len        = 1,
        .csaat      = true,
        .speed      = kSpiSpeedStandard,
        .direction  = kSpiDirTxOnly
    });

    spi_wait_for_ready(spi);
    spi_set_command(spi, spi_cmd);

    for(int i = 0; i < num_blocks; i++){
        uint16_t crc = sd_read_block(spi, soc_addr + 512*i);

        #ifdef DEBUG
        printf_("Ended block read %d with CRC: 0x%x\r\n", i+1, crc);
        #else
        (void) crc;
        #endif
    }

    if(num_blocks > 1){
        uint64_t buf = 0;
        sd_cmd(spi, 0x480000000001L, (uint8_t *) &buf, 1);

        #ifdef DEBUG
        printf_("CMD12 response: 0x%x\r\n", buf);
        #endif
    }
}
