// Copyright 2023 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Nicole Narr <narrn@student.ethz.ch>
// Christopher Reinwardt <creinwar@student.ethz.ch>
//
// Simple payload to test bootmodes

#include "regs/cheshire.h"
#include "dif/clint.h"
#include "dif/uart.h"
#include "params.h"
#include "util.h"

#define CHESHIRE_VGA_ADDR             0x03007000
#define CHESHIRE_FB_ADDR              0xA0000000
#define CHESHIRE_FB_HEIGHT            480
#define CHESHIRE_FB_WIDTH             640
#define CHESHIRE_FB_SIZE              (CHESHIRE_FB_WIDTH * CHESHIRE_FB_HEIGHT * 2)

#define VGA(offset) *((volatile unsigned int *) (CHESHIRE_VGA_ADDR + (offset)))

int main(void) {
    char str[] = "Hello World!\r\n";
    uint32_t rtc_freq = *reg32(&__base_regs, CHESHIRE_RTC_FREQ_REG_OFFSET);
    uint64_t reset_freq = clint_get_core_freq(rtc_freq, 2500);
    uart_init(&__base_uart, reset_freq, __BOOT_BAUDRATE);
    uart_write_str(&__base_uart, str, sizeof(str));
    

    char rtn[] = "\r\n";

    // Read USB Host Version (offset 11'h000)
    uint32_t* ver_reg = (uint32_t*)0x01001000;
    uint32_t ver = *ver_reg;
    for (int32_t i = 31; i >= 0; --i) {
        uart_write(&__base_uart, (uint8_t)(48 + ((ver >> i) % 2)));
    }
    uart_write_str(&__base_uart, rtn, sizeof(rtn));

    // Read USB Host Vendor ID (offset 11'h040)
    uint32_t* VID_reg = (uint32_t*)0x01001040;
    uint32_t VID = *VID_reg;
    for (int32_t i = 31; i >= 0; --i) {
        uart_write(&__base_uart, (uint8_t)(48 + ((VID >> i) % 2)));
    }
    uart_write_str(&__base_uart, rtn, sizeof(rtn));

    // Read Bus ID (offset 11'h01c)
    uint32_t* BID_reg = (uint32_t*)0x0100101c;
    uint32_t BID = *BID_reg;
    for (int32_t i = 31; i >= 0; --i) {
        uart_write(&__base_uart, (uint8_t)(48 + ((BID >> i) % 2)));
    }
    uart_write_str(&__base_uart, rtn, sizeof(rtn));


    // Test HCControl registers (set and clear) OHCI Spec 5.7

    // Set bits 31, 29, 23, 18, 17 to one
    uint32_t set = 0xA0860620; // 10100000 10000110 00000000 00000000

    uint32_t* HCCset = 0x01001050; // Set register offset 11'h050

    *HCCset = set;

    // Print HCControl
    uint32_t HCC = *HCCset;
    for (int32_t i = 31; i >= 0; --i) {
        uart_write(&__base_uart, (uint8_t)(48 + ((HCC >> i) % 2)));
    }
    uart_write_str(&__base_uart, rtn, sizeof(rtn));


    // Reset bit 29 to zero
    uint32_t clear = 0x80000000; // 10000000 00000000 00000000 00000000

    uint32_t* HCCclear = 0x01001054; // Clear register offset 11'h054

    *HCCclear = clear;

    // Print HCControl
    HCC = *HCCset;
    for (int32_t i = 31; i >= 0; --i) {
        uart_write(&__base_uart, (uint8_t)(48 + ((HCC >> i) % 2)));
    }
    uart_write_str(&__base_uart, rtn, sizeof(rtn));


    uart_write_flush(&__base_uart);


    // Initialize VGA controller and populate framebuffer
    // Clk div
    VGA(0x04) = 0x2;        // 8 for Sim, 2 for FPGA
    
    // Hori: Visible, Front porch, Sync, Back porch
    VGA(0x08) = 0x280;
    VGA(0x0C) = 0x10;
    VGA(0x10) = 0x60;
    VGA(0x14) = 0x30;

    // Vert: Visible, Front porch, Sync, Back porch
    VGA(0x18) = 0x1e0;
    VGA(0x1C) = 0xA;
    VGA(0x20) = 0x2;
    VGA(0x24) = 0x21;

    // Framebuffer start address
    VGA(0x28) = 0xA0000000;     // Low 32 bit
    VGA(0x2C) = 0x0;            // High 32 bit

    // Framebuffer size
    VGA(0x30) = 640*480*2;      // 640*480 pixel a 2 byte/pixel

    // Burst length
    VGA(0x34) = 16;           // 256*8 = 2kB Bursts

    // 0: Enable
    // 1: Hsync polarity (Active Low  = 0)
    // 2: Vsync polarity (Active Low  = 0)
    VGA(0x00) = 0x1;

    uint16_t RGB[8] = {
        0xffff, //White
        0xffe0, //Yellow
        0x07ff, //Cyan
        0x07E0, //Green
        0xf81f, //Magenta
        0xF800, //Red
        0x001F, //Blue
        0x0000, //Black
    };
    int col_width = CHESHIRE_FB_WIDTH / 8;

    volatile uint16_t *fb = (volatile uint16_t*)(void*)(uintptr_t) CHESHIRE_FB_ADDR;

    for (int k=0; k < 100; k++) {
    for (int i=0; i < CHESHIRE_FB_HEIGHT; i++) {
        for (int j=0; j < CHESHIRE_FB_WIDTH; j++) {
            fb[CHESHIRE_FB_WIDTH * i + j] = RGB[k & 7];
        }
    }

    fence();
    //for (int m=0; m < 10000; m++) {
    //    asm volatile ("nop");
    //}
    }

    return 0;
}
