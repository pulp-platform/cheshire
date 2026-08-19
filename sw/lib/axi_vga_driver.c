// Copyright 2026 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//Serge Wüest <swueest@student.ethz.ch>

#include <stdint.h>

#include "axi_vga_driver.h"
#include "regs/axi_vga.h"
#include "params.h"

// AXI VGA uses RGB565:
// 5 bit red, 6 bit green, 5 bit blue = 16 bit = 2 bytes per pixel.
#define AXI_VGA_PIXEL_BYTES 2


// -----------------------------------------------------------------------------
// AXI VGA register block
// -----------------------------------------------------------------------------

static volatile axi_vga_t *const vga =
    (volatile axi_vga_t *)&__vga_base_addr__;


// -----------------------------------------------------------------------------
// Default configuration
// -----------------------------------------------------------------------------

axi_vga_config_t axi_vga_default_config(void)
{
    axi_vga_config_t config = {
        // Visible resolution
        .width  = 32,
        .height = 16,

        // Pixel clock divider
        .clk_div = 2,

        // Horizontal timing
        .hori_front_porch = 16,
        .hori_sync_size   = 96,
        .hori_back_porch  = 48,

        // Vertical timing
        .vert_front_porch = 10,
        .vert_sync_size   = 2,
        .vert_back_porch  = 33,

        // AXI burst configuration
        .burst_len       = 0xFF,
        .burst_split_len = 0x07,
    };

    return config;
}


// -----------------------------------------------------------------------------
// Enable / disable
// -----------------------------------------------------------------------------

void axi_vga_disable(void)
{
    // Keep HSYNC and VSYNC polarity configured while disabling VGA.
    vga->control =
        AXI_VGA__CONTROL__HSYNC_POL_bm |
        AXI_VGA__CONTROL__VSYNC_POL_bm;
}


void axi_vga_enable(void)
{
    vga->control =
        AXI_VGA__CONTROL__ENABLE_bm    |
        AXI_VGA__CONTROL__HSYNC_POL_bm |
        AXI_VGA__CONTROL__VSYNC_POL_bm;
}


// -----------------------------------------------------------------------------
// Framebuffer
// -----------------------------------------------------------------------------

void axi_vga_set_framebuffer(uintptr_t framebuffer_addr)
{
    vga->start_addr_low =
        (uint32_t)(framebuffer_addr & 0xFFFFFFFFULL);

    vga->start_addr_high =
        (uint32_t)(framebuffer_addr >> 32);
}


// -----------------------------------------------------------------------------
// Initialization
// -----------------------------------------------------------------------------

void axi_vga_init(
    uintptr_t framebuffer_addr,
    const axi_vga_config_t *config)
{
    // Disable VGA while changing the configuration.
    axi_vga_disable();

    vga->clk_div = config->clk_div;

    vga->hori_visible_size     = config->width;
    vga->hori_front_porch_size = config->hori_front_porch;
    vga->hori_sync_size        = config->hori_sync_size;
    vga->hori_back_porch_size  = config->hori_back_porch;

    vga->vert_visible_size     = config->height;
    vga->vert_front_porch_size = config->vert_front_porch;
    vga->vert_sync_size        = config->vert_sync_size;
    vga->vert_back_porch_size  = config->vert_back_porch;

    axi_vga_set_framebuffer(framebuffer_addr);

    vga->frame_size =
        config->width *
        config->height *
        AXI_VGA_PIXEL_BYTES;

    vga->burst_len       = config->burst_len;
    vga->burst_split_len = config->burst_split_len;
}

// Display one RGB565 image
void axi_vga_show_image(
    volatile uint32_t *framebuffer,   // <-- war uint16_t*
    const uint16_t *image,
    uint32_t width,
    uint32_t height
)
{
    uint32_t num_pixels = width * height;

    const uint64_t *src =
        (const uint64_t *)image;

    for (uint32_t i = 0; i < num_pixels / 4; i++) {

        uint64_t data = src[i];

        // Pixel 0 (low 16 bit) + Pixel 1 (high 16 bit) -> ein 32-Bit-Write
        framebuffer[i * 2 + 0] =
            (uint32_t)(data & 0xFFFFFFFFu);

        // Pixel 2 (low 16 bit) + Pixel 3 (high 16 bit) -> ein 32-Bit-Write
        framebuffer[i * 2 + 1] =
            (uint32_t)(data >> 32);
    }
}


// Display N RGB565 images sequentially
void axi_vga_play_frames(
    volatile uint32_t *framebuffer,   // <-- war uint16_t*
    const uint16_t *const images[],
    uint32_t number_of_images,
    uint32_t width,
    uint32_t height,
    uint32_t delay_cycles)
{
    for (uint32_t frame = 0;
         frame < number_of_images;
         frame++) {

        // Copy next image into VGA framebuffer.
        axi_vga_show_image(
            framebuffer,
            images[frame],
            width,
            height
        );

        // Keep the frame visible for some time.
        for (volatile uint32_t i = 0;
             i < delay_cycles;
             i++) {
            asm volatile ("nop");
        }
    }
}

