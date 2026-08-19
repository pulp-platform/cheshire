// Copyright 2026 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

// Serge Wüest <swueest@student.ethz.ch>

// Test script for AXI VGA integration into Cheshire.

#include <stdint.h>

#include "axi_vga_driver.h"
#include "ethz_frames.h"
#include "regs/cheshire.h"
#include "dif/clint.h"
#include "dif/uart.h"
#include "params.h"
#include "util.h"

// Put the framebuffer 16 KiB after the beginning of SPM.
#define VGA_FB_SPM_OFFSET 0x4000
#define VGA_FB_DRAM_OFFSET 0x400000UL
//Use uncached SPM memory
#define VGA_UNCACHED_SPM_BASE 0x14000000UL


// -----------------------------------------------------------------------------
// Main
// -----------------------------------------------------------------------------

int main(void)
{
    // UART setup
    uint32_t rtc_freq =
        CHS_REGS->rtc_freq.f.ref_freq;

    uint64_t reset_freq =
        clint_get_core_freq(rtc_freq, 2500);

    uart_init(
        &__uart_base_addr__,
        reset_freq,
        __BOOT_BAUDRATE
    );
    char start_msg[] =
        "AXI VGA animation test started\r\n";
    uart_write_str(
        &__uart_base_addr__,
        start_msg,
        sizeof(start_msg) - 1
    );
    uart_write_flush(&__uart_base_addr__);


    // VGA configuration
    axi_vga_config_t vga_config =
        axi_vga_default_config();

    /*
     * Default configuration:
     *
     *     width  = 32
     *     height = 16
     */


    // Framebuffer
    uintptr_t framebuffer_addr =
        VGA_UNCACHED_SPM_BASE +
        VGA_FB_SPM_OFFSET;

    volatile uint32_t *framebuffer =
        (volatile uint32_t *)framebuffer_addr;


    axi_vga_show_image(
        framebuffer,
        ethz_frames[1],
        vga_config.width,
        vga_config.height
    );


    // Configure VGA
    axi_vga_init(
        framebuffer_addr,
        &vga_config
    );


    // Enable VGA
    axi_vga_enable();

    // Play ETHZ animation forever
    while (1) {

        axi_vga_play_frames(
            framebuffer,
            ethz_frames,
            ETHZ_NUM_FRAMES,
            vga_config.width,
            vga_config.height,
            3000
        );
    }

    char enabled_msg[] =
        "AXI VGA enabled\r\n";
    uart_write_str(
        &__uart_base_addr__,
        enabled_msg,
        sizeof(enabled_msg) - 1
    );
    uart_write_flush(&__uart_base_addr__);
    
    return 0;
}