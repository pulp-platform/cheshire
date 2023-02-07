// Copyright 2023 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Nicole Narr <narrn@student.ethz.ch>
// Christopher Reinwardt <creinwar@student.ethz.ch>

#ifndef CRC_C_
#define CRC_C_

#include "crc.h"

// Generator Poly: G(x) = x^7 + x^3 + 1
// dir == 1 => MSB in data[0]
// dir == 0 => MSB in data[len-1]
unsigned char crc7(unsigned char *data, int len, char dir)
{
    int pos = dir ? 0 : len-1;
    int incr = dir ? 1 : -1;
    unsigned int shift = 0;
    unsigned int processed = 0;
    unsigned short G = 0x8900;
    unsigned short buf = 0;

    if(len < 1)
        return 0;

    buf  = ((unsigned short) data[pos]) << 8;
    pos += incr;

    buf |= (len >= 2) ? ((unsigned short) data[pos]) : 0;
    pos += incr;

    // Pre align the data in the buffer
    while(!(buf >> 15) && processed < len*8){
        buf <<= 1;
        shift++;
        processed++;

        if(processed >= len*8){
            break;
        }

        if(shift == 8 && ((dir && (pos < len)) | (!dir && (pos > 0)))){
            buf |= data[pos];
            pos += incr;
            shift = 0;
        }
    }

    // Compute the actual CRC7
    while(processed < len*8){
        buf ^= G;
        
        while(!(buf >> 15) && processed < len*8){
            buf <<= 1;
            shift++;
            processed++;

            if(processed >= len*8){
                break;
            }

            if(shift == 8 && ((dir && (pos < len)) | (!dir && (pos > 0)))){
                buf |= data[pos];
                pos += incr;
                shift = 0;
            }
        }
    }

    return (unsigned char) (buf >> 9) & 0x7f;
}

// Generator Poly: G(x) = x^16 + x^12 + x^5 + 1
// dir == 1 => MSB in data[0]
// dir == 0 => MSB in data[len-1]
unsigned short crc16(unsigned char *data, int len, char dir)
{
    int pos = dir ? 0 : len-1;
    int incr = dir ? 1 : -1;
    unsigned int shift = 0;
    unsigned int processed = 0;
    unsigned int G = 0x88108000;
    unsigned int buf = 0;

    if(len < 1)
        return 0;

    buf  = ((unsigned int) data[pos]) << 24;
    pos += incr;
    
    buf |= (len >= 2) ? ((unsigned int) data[pos]) << 16 : 0;
    pos += incr;

    buf |= (len >= 3) ? ((unsigned int) data[pos]) <<  8 : 0;
    pos += incr;

    buf |= (len >= 4) ? ((unsigned int) data[pos])       : 0;
    pos += incr;

    // Pre align the data in the buffer
    while(!(buf >> 31) && processed < len*8){
        buf <<= 1;
        shift++;
        processed++;

        if(processed >= len*8){
            break;
        }

        if(shift == 8 && ((dir && (pos < len)) | (!dir && (pos > 0)))){
            buf |= data[pos];
            pos += incr;
            shift = 0;
        }
    }

    // Compute the actual CRC16
    while(processed < len*8){
        buf ^= G;
        
        while(!(buf >> 31) && processed < len*8){
            buf <<= 1;
            shift++;
            processed++;

            if(processed >= len*8){
                break;
            }

            if(shift == 8 && ((dir && (pos < len)) | (!dir && (pos > 0)))){
                buf |= data[pos];
                pos += incr;
                shift = 0;
            }
        }
    }

    return (unsigned short) (buf >> 16) & 0xFFFF;
}

#endif

