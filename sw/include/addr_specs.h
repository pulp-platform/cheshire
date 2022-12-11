// Copyright 2022 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Nicole Narr <narrn@student.ethz.ch>
// Christopher Reinwardt <creinwar@student.ethz.ch>

typedef struct {
    void *addr;    // 64 bit address
    int length;    // Length of "memory" region in bytes
    int width;     // Maximum supported access width (e.g. 64, 32 bit) in bits
    int alignment; // Required access alignment in bits
    char access;   // Access rights encoded in lower two bits
                   // access[1] = r, access[0] = w
} test_addr_t;

extern void *__base_bootrom;
extern void *__base_cheshire_regs;
extern void *__base_axi_llc;
extern void *__base_ddr_link;
extern void *__base_uart;
extern void *__base_i2c;
extern void *__base_spim;
extern void *__base_vga;
extern void *__base_clint;
extern void *__base_plic;
extern void *__base_dma_conf;
extern void *__base_spm;
extern void *__base_dram;

test_addr_t test_addresses[] = {
   {(void *) &__base_bootrom        + 0x00000000, 16, 64,  8, 2}, // Boot Rom lower 16 bytes
   {(void *) &__base_bootrom        + 0x0001FFF0, 16, 64,  8, 2}, // Boot Rom upper 16 bytes
   {(void *) &__base_cheshire_regs  + 0x00000000,  4, 32, 32, 2}, // Version register
   {(void *) &__base_cheshire_regs  + 0x00000004,  4, 32, 32, 2}, // Scratch register 0 - Polled by TB to signal completion
   {(void *) &__base_cheshire_regs  + 0x00000008,  4, 32, 32, 3}, // Scratch register 1
   {(void *) &__base_cheshire_regs  + 0x0000000C,  4, 32, 32, 3}, // Scratch register 2
   {(void *) &__base_cheshire_regs  + 0x00000010,  4, 32, 32, 3}, // Scratch register 3
   {(void *) &__base_cheshire_regs  + 0x00000014,  4, 32, 32, 2}, // Bootmode register
   {(void *) &__base_cheshire_regs  + 0x00000018,  4, 32, 32, 2}, // Status register
   {(void *) &__base_cheshire_regs  + 0x0000001C,  4, 32, 32, 2}, // VGA Red width register
   {(void *) &__base_cheshire_regs  + 0x00000020,  4, 32, 32, 2}, // VGA Green width register
   {(void *) &__base_cheshire_regs  + 0x00000024,  4, 32, 32, 2}, // VGA Blue width register
   {(void *) &__base_axi_llc        + 0x00000040,  4, 32, 32, 2}, // AXI LLC version low register
   {(void *) &__base_ddr_link       + 0x00000000,  4, 32, 32, 2}, // DDR Link control register
   {(void *) &__base_uart           + 0x0000001C,  1,  8,  8, 3}, // UART Scratch register
   {(void *) &__base_i2c            + 0x00000014,  4, 32, 32, 2}, // I2C Master status register
   {(void *) &__base_spim           + 0x00000014,  4, 32, 32, 2}, // SPI Host status register
   {(void *) &__base_vga            + 0x00000000,  4, 32, 32, 2}, // VGA control register
   {(void *) &__base_clint          + 0x0000bff8,  4, 32, 32, 2}, // CLINT MTIME register
   {(void *) &__base_plic           + 0x00001000,  4, 32, 32, 2}, // PLIC IP register
   {(void *) &__base_dma_conf       + 0x00000020,  8, 64, 64, 2}, // DMA status register
   {(void *) &__base_spm            + 0x00000000, 16, 64,  8, 3}, // SPM lower 16 bytes
   {(void *) &__base_spm            + 0x0001FFF0, 16, 64,  8, 3}, // SPM upper 16 bytes
   {(void *) &__base_dram           + 0x00000000, 0x1000000, 64, 8, 3}, // FPGA 1 GiB DRAM
};

unsigned int test_addresses_length = sizeof(test_addresses)/sizeof(test_addr_t);
