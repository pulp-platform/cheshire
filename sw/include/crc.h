// Copyright 2023 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Nicole Narr <narrn@student.ethz.ch>
// Christopher Reinwardt <creinwar@student.ethz.ch>

#ifndef CRC_H_
#define CRC_H_

// Computes the CRC7 over the input data
// Generator Poly: G(x) = x^7 + x^3 + 1
// dir == 1 => MSB in data[0]
// dir == 0 => MSB in data[len-1]
unsigned char crc7(unsigned char *data, int len, char dir);

// Computes the CRC16 over the input data
// Generator Poly: G(x) = x^16 + x^12 + x^5 + 1
// dir == 1 => MSB in data[0]
// dir == 0 => MSB in data[len-1]
unsigned short crc16(unsigned char *data, int len, char dir);

#endif

