// Copyright 2023 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Paul Scheffler <paulsc@iis.ee.ethz.ch>

#pragma once

#include <stdint.h>

// UART debug opcodes
typedef enum {
    kUartDebugCmdRead  = 0x10,
    kUartDebugCmdWrite = 0x11,
    kUartDebugCmdExec  = 0x12,
    kUartDebugAck      = 0x06,   // Starts debug or acknowledges parsed command
    kUartDebugEot      = 0x04    // Sent on end of (read/write) transmission
} uart_debug_opcode_t;

int uart_debug_init(void *uart_base, uint64_t core_freq);

// Check if we received a debug request (ACK byte on RX)
int uart_debug_check(void *uart_base);

int uart_debug_serve(void *uart_base);
