// Copyright 2022 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Nicole Narr <narrn@student.ethz.ch>
// Christopher Reinwardt <creinwar@student.ethz.ch>

typedef struct {
    void *addr;    // 64 bit address
    int length;    // Length of "memory" region in bytes
    int width;     // Access width (e.g. 64, 32 bit) in bits
    int alignment; // Required access alignment in bits
    char access;   // Access rights encoded in lower two bits
                   // access[1] = r, access[0] = w
} test_addr_t;

test_addr_t test_addresses[] = {
   {(void *) 0x01000000, 16, 64, 8, 2},            // Boot Rom lower 16 bytes
   {(void *) 0x0101FFF0, 16, 64, 8, 2},            // Boot Rom upper 16 bytes
   {(void *) 0x0200001C, 1, 8, 8, 3},              // UART Scratch register
   {(void *) 0x02001000, 92, 32, 32, 2},           // I2C Master
   //{(void *) 0x02003000, 4, 32, 32, 3},            // Padring config dummy pad CFG register
   //{(void *) 0x02003004, 4, 32, 32, 2},            // Padring config dummy pad MUX SEL register
   {(void *) 0x02004000, 4, 32, 32, 2},            // Version register
   {(void *) 0x02004004, 4, 32, 32, 2},            // Scratch register 0 - Polled by TB to signal completion
   {(void *) 0x02004008, 4, 32, 32, 3},            // Scratch register 1
   {(void *) 0x0200400C, 4, 32, 32, 3},            // Scratch register 2
   {(void *) 0x02004010, 4, 32, 32, 3},            // Scratch register 3
   {(void *) 0x02004014, 4, 32, 32, 2},            // Bootmode register
   {(void *) 0x20000000, 4, 32, 32, 2},            // DDR Link config regbus (Status Register)
   {(void *) 0x20000008, 4, 32, 32, 2},            // DDR Link config regbus (Training Mask Register)
   {(void *) 0x20000010, 4, 32, 32, 2},            // DDR Link config regbus (Delay Register)
   //{(void *) 0x20001000, 32, 64, 8, 2},            // RPC DRAM regbus port
   //{(void *) 0x70000000, 16, 64, 8, 3},            // SPM lower 16 bytes
   //{(void *) 0x7001FFF0, 16, 64, 8, 3},            // SPM upper 16 bytes
   //{(void *) 0x80000000, 16, 64, 8, 3},            // RPC DRAM lower 16 bytes
   //{(void *) 0x8FFFFFF0, 16, 64, 8, 3},            // RPC DRAM upper 16 bytes (from 256 Mb model)
   {(void *) 0x80000000, 0x1000000, 64, 8, 3},      // FPGA 1 GiB DRAM
   //{(void *) 0x100000000000L, 16, 64, 8, 3}        // DDR Link (connected to memory in fixture)
};

unsigned int test_addresses_length = sizeof(test_addresses)/sizeof(test_addr_t);
