// Copyright 2022 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Nicole Narr <narrn@student.ethz.ch>
// Christopher Reinwardt <creinwar@student.ethz.ch>

#include "printf.h"
#include "sleep.h"
#include "trap.h"
#include "uart.h"
#include <stdint.h>

extern void *__base_dram;
extern void *__base_vga;

#define DRAM_ADDR_32 0x80000000

#define VGA(offset) *((volatile unsigned int *)((unsigned long int)&__base_vga + (offset)))

char uart_initialized = 0;

void __attribute__((aligned(4))) trap_vector(void) { test_trap_vector(&uart_initialized); }

void init_vga_640_350() {
    // Clk div
    VGA(0x04) = 0x2; // 8 for Sim, 2 for FPGA

    // Hori: Visible, Front porch, Sync, Back porch
    VGA(0x08) = 0x280;
    VGA(0x0C) = 0x10;
    VGA(0x10) = 0x60;
    VGA(0x14) = 0x30;

    // Vert: Visible, Front porch, Sync, Back porch
    VGA(0x18) = 0x15e;
    VGA(0x1C) = 0x25;
    VGA(0x20) = 0x2;
    VGA(0x24) = 0x3c;

    // Framebuffer start address
    VGA(0x28) = DRAM_ADDR_32; // Low 32 bit
    VGA(0x2C) = 0x0;          // High 32 bit

    // Framebuffer size
    VGA(0x30) = 640 * 350 * 2; // 640*350 pixel a 2 byte/pixel

    // Burst length
    VGA(0x34) = 255; // 256*8 = 2kB Bursts

    // 0: Enable
    // 1: Hsync polarity (Active High = 1)
    // 2: Vsync polarity (Active Low  = 0)
    VGA(0x00) = 0x3;
}

void init_vga_640_480() {
    // Clk div
    VGA(0x04) = 0x2; // 8 for Sim, 2 for FPGA

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
    VGA(0x28) = DRAM_ADDR_32; // Low 32 bit
    VGA(0x2C) = 0x0;          // High 32 bit

    // Framebuffer size
    VGA(0x30) = 640 * 480 * 2; // 640*350 pixel a 2 byte/pixel

    // Burst length
    VGA(0x34) = 255; // 256*8 = 2kB Bursts

    // 0: Enable
    // 1: Hsync polarity (Active Low  = 0)
    // 2: Vsync polarity (Active Low  = 0)
    VGA(0x00) = 0x1;
}

void init_vga_800_600() {
    // Clk div
    VGA(0x04) = 0x1; // 4 for Sim, 1 for FPGA

    // Hori: Visible, Front porch, Sync, Back porch
    VGA(0x08) = 0x320;
    VGA(0x0C) = 0x38;
    VGA(0x10) = 0x78;
    VGA(0x14) = 0x40;

    // Vert: Visible, Front porch, Sync, Back porch
    VGA(0x18) = 0x258;
    VGA(0x1C) = 0x25;
    VGA(0x20) = 0x6;
    VGA(0x24) = 0x17;

    // Framebuffer start address
    VGA(0x28) = DRAM_ADDR_32; // Low 32 bit
    VGA(0x2C) = 0x0;          // High 32 bit

    // Framebuffer size
    VGA(0x30) = 800 * 600 * 2; // 800*600 pixel a 2 byte/pixel

    // Burst length
    VGA(0x34) = 255; // 256*8 = 2kB Bursts

    // 0: Enable
    // 1: Hsync polarity (Active High = 1)
    // 2: Vsync polarity (Active High = 1)
    VGA(0x00) = 0x7;
}

void init_vga_testmode() {
    // Clk div
    VGA(0x04) = 0x8; // 6.25 MHz - 160 ns

    // Hori: Visible, Front porch, Sync, Back porch
    // Sum: 8 => 8*160 ns = 1.28 us
    VGA(0x08) = 5; // 800 ns
    VGA(0x0C) = 1; // 160 ns
    VGA(0x10) = 2; // 320 ns
    VGA(0x14) = 3; // 480 ns

    // Vert: Visible, Front porch, Sync, Back porch
    // Sum: 8 => 8*8*160ns = 10.24 us
    VGA(0x18) = 5; // 6.4  us
    VGA(0x1C) = 1; // 1.28 us
    VGA(0x20) = 2; // 2.56 us
    VGA(0x24) = 3; // 3.84 us

    // Framebuffer start address
    VGA(0x28) = DRAM_ADDR_32; // Low 32 bit
    VGA(0x2C) = 0x0;          // High 32 bit

    // Framebuffer size
    VGA(0x30) = 5 * 5 * 2; // 800*600 pixel a 2 byte/pixel

    // Burst length
    VGA(0x34) = 255; // 256*8 = 2kB Bursts

    // 0: Enable
    // 1: Hsync polarity (Active High = 1)
    // 2: Vsync polarity (Active High = 1)
    VGA(0x00) = 0x7;
}

void checkerboard_640_350(void) {
    volatile unsigned long int *dram = (volatile unsigned long int *)&__base_dram;

    for (int v = 0; v < 35; v++) {
        for (int j = 0; j < 10; j++) {
            for (int h = 0; h < 80; h++) {
                if (v % 2 == 0) {
                    dram[v * j + h] = 0xFFFFFFFFFFFFFFFF;
                    dram[v * j + h + 1] = 0xFFFFFFFFFFFFFFFF;
                } else {
                    dram[v * j + h] = 0x0;
                    dram[v * j + h + 1] = 0x0;
                }
            }
        }
    }
}

void color_matrix_640_480(void) {
    // writes color matrix to dram
    volatile unsigned short *dram = (volatile unsigned short int *)&__base_dram;
    uint16_t color = 0x0000;

    for (int v = 0; v < 8; v++) {
        for (int h = 0; h < 16; h++) {
            for (int vi = 0; vi < 30; vi++) {
                for (int hi = 0; hi < 40; hi++) {
                    dram[(v * 30 + vi) * 640 + h * 40 + hi] = color;
                }
            }
            color += 0x0101;
        }
        color += 0x1010;
    }

    color = 0x1010;
    for (int v = 8; v < 16; v++) {
        for (int h = 0; h < 16; h++) {
            for (int vi = 0; vi < 30; vi++) {
                for (int hi = 0; hi < 40; hi++) {
                    dram[(v * 30 + vi) * 640 + h * 40 + hi] = color;
                }
            }
            color += 0x0101;
        }
        color += 0x1010;
    }
}

void checkerboard_800_600(void) {
    volatile unsigned short *dram = (volatile unsigned short *)&__base_dram;

    for (int i = 0; i < 800 * 600 * 2; i++) {
        if ((i / 3) % 2 == 0) {
            dram[i] = 0xFFFF;
        } else {
            dram[i] = 0x0;
        }
    }
}

void render_gif_640_480(unsigned long int *start) {
    unsigned long int delay = start[0];
    unsigned long int num_frames = start[1];

    unsigned long int image_base = ((unsigned long int)start) + 16;

    while (1) {
        for (unsigned long int i = 0; i < num_frames; i++) {
            sleep(delay);
            VGA(0x28) = image_base + i * (640 * 480 * 2);
        }
    }
}

void render_gif_800_600(unsigned long int *start) {
    unsigned long int delay = start[0];
    unsigned long int num_frames = start[1];

    unsigned long int image_base = ((unsigned long int)start) + 16;

    while (1) {
        for (unsigned long int i = 0; i < num_frames; i++) {
            sleep(delay);
            VGA(0x28) = image_base + i * (800 * 600 * 2);
        }
    }
}

int main(void) {
    init_uart(50000000, 115200);
    uart_initialized = 1;

    printf_("Testing VGA\r\n");

    // Disable D-Cache
    asm volatile("addi t0, x0, 1\n   \
             csrrc x0, 0x701, t0\n" ::
                     : "t0");

    printf_("Writing checkerboard to DRAM\r\n");

    // checkerboard_640_350();
    color_matrix_640_480();
    // checkerboard_800_600();

    // init_vga_640_350();
    init_vga_640_480();
    // init_vga_800_600();
    // init_vga_testmode();

    printf_("VGA initialized\r\n");

    // render_gif_640_480((unsigned long int *) &_binary_graphics_image_bin_start);
    // render_gif_800_600((unsigned long int *) &_binary_graphics_image_bin_start);

    while (1) {
    }

    return 0;
}
