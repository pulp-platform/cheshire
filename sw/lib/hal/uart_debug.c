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
    kUartDebugCmdRead  = 0x10,
    kUartDebugCmdWrite = 0x11,
    kUartDebugCmdExec  = 0x12,
    kUartDebugAck      = 0x06,   // Starts debug or acknowledges parsed command
    kUartDebugEot      = 0x04    // Sent on end of (read/write) transmission
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

static inline void __uart_debug_read_str(void *uart_base, void* dst, uint64_t len) {
    for(uint64_t i = 0; i < len; ++i)
        ((uint8_t*)dst)[i] = uart_read(uart_base);
}

static inline void __uart_debug_write_str(void *uart_base, void* src, uint64_t len) {
    for(uint64_t i = 0; i < len; ++i)
        uart_write(uart_base, ((uint8_t*)src)[i]);
}

int uart_debug_serve(void *uart_base) {
    // Parse commands (eventually hit EXEC command or trap)
    while (1) {
        uint8_t cmd;
        uint64_t addr, len;
        fence();
        cmd = uart_read(uart_base);
        switch (cmd) {
            // READ addr64 len64 -> ACK str EOT
            case kUartDebugCmdRead:
                __uart_debug_read_str(uart_base, &addr, sizeof(uint64_t));
                __uart_debug_read_str(uart_base, &len, sizeof(uint64_t));
                uart_write(uart_base, kUartDebugAck);
                __uart_debug_write_str(uart_base, (void*)(uintptr_t) addr, len);
                uart_write(uart_base, kUartDebugEot);
                break;
            // WRITE addr64 len64 (->ACK) str (->EOT)
            case kUartDebugCmdWrite:
                __uart_debug_read_str(uart_base, &addr, sizeof(uint64_t));
                __uart_debug_read_str(uart_base, &len, sizeof(uint64_t));
                uart_write(uart_base, kUartDebugAck);
                __uart_debug_read_str(uart_base, (void*)(uintptr_t) addr, len);
                uart_write(uart_base, kUartDebugEot);
                break;
            // EXEC addr64 (->ACK) execute
            case kUartDebugCmdExec:
                __uart_debug_read_str(uart_base, &addr, sizeof(uint64_t));
                uart_write(uart_base, kUartDebugAck);
                fence();
                return invoke((void*)(uintptr_t) addr);
            // Unknown command
            default:
                return 1;
        }
    }
}
