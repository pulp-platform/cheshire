// Copyright 2023 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Paul Scheffler <paulsc@iis.ee.ethz.ch>

#include "hal/uart_debug.h"
#include "dif/uart.h"
#include "util.h"
#include "params.h"

// UART debug opcodes
typedef enum {
    kUartDebugCmdRead = 0x11,
    kUartDebugCmdWrite = 0x12,
    kUartDebugCmdExec = 0x13,
    kUartDebugAck = 0x06, // Starts debug or acknowledges parsed command
    kUartDebugEot = 0x04, // Sent on end of (read/write) transmission
    kUartDebugEoc = 0x14  // Sent when code invoked with EXEC returns
} uart_debug_opcode_t;

int uart_debug_init(void *uart_base, uint64_t core_freq) {
    // Check arguments
    CHECK_ASSERT(0x11, uart_base != 0);
    CHECK_ASSERT(0x12, core_freq != 0);
    // The UART debug mode uses the sane default 115.2kBaud
    uart_init(uart_base, core_freq, 115200);
    fence();
    // Nothing went wrong
    return 0;
}

int uart_debug_check(void *uart_base) {
    return (uart_read_ready(uart_base) && *reg8(uart_base, UART_RBR_REG_OFFSET) == kUartDebugAck);
}

int uart_debug_serve(void *uart_base) {
    // Respond to debug request with ACK to initiate connection
    uart_write(uart_base, kUartDebugAck);
    // Parse commands (eventually hit EXEC command or trap)
    while (1) {
        uint8_t cmd;
        uint64_t addr, len;
        uint32_t ret;
        fence();
        cmd = uart_read(uart_base);
        switch (cmd) {
        // READ addr64 len64 -> ACK str EOT
        case kUartDebugCmdRead:
            uart_read_str(uart_base, &addr, sizeof(uint64_t));
            uart_read_str(uart_base, &len, sizeof(uint64_t));
            uart_write(uart_base, kUartDebugAck);
            uart_write_str(uart_base, (void *)(uintptr_t)addr, len);
            uart_write(uart_base, kUartDebugEot);
            break;
        // WRITE addr64 len64 (->ACK) str (->EOT)
        case kUartDebugCmdWrite:
            uart_read_str(uart_base, &addr, sizeof(uint64_t));
            uart_read_str(uart_base, &len, sizeof(uint64_t));
            uart_write(uart_base, kUartDebugAck);
            uart_read_str(uart_base, (void *)(uintptr_t)addr, len);
            uart_write(uart_base, kUartDebugEot);
            break;
        // EXEC addr64 (->ACK) execute
        case kUartDebugCmdExec:
            uart_read_str(uart_base, &addr, sizeof(uint64_t));
            uart_write(uart_base, kUartDebugAck);
            fence();
            ret = invoke((void *)(uintptr_t)addr);
            fence();
            // Report return code on UART
            uart_write(uart_base, kUartDebugEoc);
            uart_write_str(uart_base, (void *)(uintptr_t)&ret, sizeof(uint32_t));
            return ret;
        // Unknown command
        default:
            return 1;
        }
    }
}
