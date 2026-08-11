// Copyright 2026 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

//Serge Wüest <swueest@student.ethz.ch>

//Test script for axi_vga integration into cheshire

#include <stdint.h>

#include "regs/axi_vga.h"
#include "regs/cheshire.h"
#include "dif/clint.h"
#include "dif/uart.h"
#include "params.h"
#include "util.h"

// -----------------------------------------------------------------------------
// VGA mode: 640x480
// Must match the VGA configuration used by the simulation capture.
// -----------------------------------------------------------------------------

#define VGA_WIDTH              32
#define VGA_HEIGHT             16

#define VGA_CLK_DIV            2

#define VGA_HORI_FRONT_PORCH   16
#define VGA_HORI_SYNC_SIZE     96
#define VGA_HORI_BACK_PORCH    48

#define VGA_VERT_FRONT_PORCH   10
#define VGA_VERT_SYNC_SIZE     2
#define VGA_VERT_BACK_PORCH    33

// RGB565 -> 2 bytes per pixel
#define VGA_PIXEL_BYTES        2

// Put the framebuffer 4 KiB after the beginning of DRAM.
#define VGA_FB_SPM_OFFSET 0x4000

// RGB565 colors
#define RGB565_RED             0xF800
#define RGB565_GREEN           0x07E0
#define RGB565_BLUE            0x001F
#define RGB565_BLACK           0x0000
#define RGB565_WHITE           0xFFFF


// static void fill_test_pattern(volatile uint16_t *framebuffer)
// {
//     for (uint32_t y = 0; y < VGA_HEIGHT; y++) {
//         for (uint32_t x = 0; x < VGA_WIDTH; x++) {

//             uint16_t color;

//             // Three vertical color bars:
//             //
//             //   RED | GREEN | BLUE
//             //
//             if (x < VGA_WIDTH / 3) {
//                 color = RGB565_RED;
//             } else if (x < (2 * VGA_WIDTH) / 3) {
//                 color = RGB565_GREEN;
//             } else {
//                 color = RGB565_BLUE;
//             }

//             framebuffer[y * VGA_WIDTH + x] = color;
//         }
//     }
// }
static void fill_test_pattern(volatile uint16_t *framebuffer)
{
    for (uint32_t i = 0; i < VGA_WIDTH * VGA_HEIGHT; i++) {
        framebuffer[i] = 0xF800;
    }
}


int main(void)
{
    // -------------------------------------------------------------------------
    // UART setup
    // -------------------------------------------------------------------------

    uint32_t rtc_freq = CHS_REGS->rtc_freq.f.ref_freq;
    uint64_t reset_freq = clint_get_core_freq(rtc_freq, 2500);

    uart_init(&__uart_base_addr__, reset_freq, __BOOT_BAUDRATE);

    char start_msg[] = "AXI VGA test started\r\n";
    uart_write_str(&__uart_base_addr__, start_msg, sizeof(start_msg) - 1);
    uart_write_flush(&__uart_base_addr__);


    // -------------------------------------------------------------------------
    // VGA register block
    // -------------------------------------------------------------------------

    volatile axi_vga_t *vga =
        (volatile axi_vga_t *)&__vga_base_addr__;


    // -------------------------------------------------------------------------
    // Framebuffer
    // -------------------------------------------------------------------------

    uintptr_t framebuffer_addr =
        (uintptr_t)&__spm_base_addr__ + VGA_FB_SPM_OFFSET;

    volatile uint16_t *framebuffer =
        (volatile uint16_t *)framebuffer_addr;


    // Disable VGA while configuring it.
    //
    // hsync_pol = 1
    // vsync_pol = 1
    // enable    = 0
    //
    vga->control =
        AXI_VGA__CONTROL__HSYNC_POL_bm |
        AXI_VGA__CONTROL__VSYNC_POL_bm;


    // -------------------------------------------------------------------------
    // Fill framebuffer
    // -------------------------------------------------------------------------

    fill_test_pattern(framebuffer);

    char fb_msg[] = "Framebuffer initialized\r\n";
    uart_write_str(&__uart_base_addr__, fb_msg, sizeof(fb_msg) - 1);
    uart_write_flush(&__uart_base_addr__);


    // -------------------------------------------------------------------------
    // VGA timing configuration
    // -------------------------------------------------------------------------

    vga->clk_div = VGA_CLK_DIV;

    // Horizontal timing
    vga->hori_visible_size     = VGA_WIDTH;
    vga->hori_front_porch_size = VGA_HORI_FRONT_PORCH;
    vga->hori_sync_size        = VGA_HORI_SYNC_SIZE;
    vga->hori_back_porch_size  = VGA_HORI_BACK_PORCH;

    // Vertical timing
    vga->vert_visible_size     = VGA_HEIGHT;
    vga->vert_front_porch_size = VGA_VERT_FRONT_PORCH;
    vga->vert_sync_size        = VGA_VERT_SYNC_SIZE;
    vga->vert_back_porch_size  = VGA_VERT_BACK_PORCH;


    // -------------------------------------------------------------------------
    // Framebuffer configuration
    // -------------------------------------------------------------------------

    vga->start_addr_low =
        (uint32_t)(framebuffer_addr & 0xFFFFFFFFULL);

    vga->start_addr_high =
        (uint32_t)(framebuffer_addr >> 32);

    vga->frame_size =
        VGA_WIDTH * VGA_HEIGHT * VGA_PIXEL_BYTES;

    // Same values as the existing AXI VGA testbench.
    vga->burst_len       = 0xFF;
    vga->burst_split_len = 0x07;


    // -------------------------------------------------------------------------
    // Enable VGA
    // -------------------------------------------------------------------------

    vga->control =
        AXI_VGA__CONTROL__ENABLE_bm    |
        AXI_VGA__CONTROL__HSYNC_POL_bm |
        AXI_VGA__CONTROL__VSYNC_POL_bm;


    char enabled_msg[] = "AXI VGA enabled\r\n";
    uart_write_str(&__uart_base_addr__, enabled_msg, sizeof(enabled_msg) - 1);
    uart_write_flush(&__uart_base_addr__);


    // Keep software alive while VGA continuously reads the framebuffer.
    while (1) {
        asm volatile ("nop");
    }

    return 0;
}