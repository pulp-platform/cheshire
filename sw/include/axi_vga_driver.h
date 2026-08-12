#pragma once

#include <stdint.h>
#include <stddef.h>


typedef struct {
    uint32_t width;
    uint32_t height;

    uint32_t clk_div;

    uint32_t hori_front_porch;
    uint32_t hori_sync_size;
    uint32_t hori_back_porch;

    uint32_t vert_front_porch;
    uint32_t vert_sync_size;
    uint32_t vert_back_porch;

    uint32_t burst_len;
    uint32_t burst_split_len;
} axi_vga_config_t;


// -----------------------------------------------------------------------------
// VGA configuration
// -----------------------------------------------------------------------------

axi_vga_config_t axi_vga_default_config(void);

void axi_vga_init(
    uintptr_t framebuffer_addr,
    const axi_vga_config_t *config
);

void axi_vga_enable(void);

void axi_vga_disable(void);

void axi_vga_set_framebuffer(
    uintptr_t framebuffer_addr
);


// -----------------------------------------------------------------------------
// Image / animation functions
// -----------------------------------------------------------------------------

void axi_vga_show_image(
    volatile uint16_t *framebuffer,
    const uint16_t *image,
    uint32_t width,
    uint32_t height
);

void axi_vga_play_frames(
    volatile uint16_t *framebuffer,
    const uint16_t *const images[],
    uint32_t number_of_images,
    uint32_t width,
    uint32_t height,
    uint32_t delay_cycles
);