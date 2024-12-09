// Copyright 2023 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Raphael Roth <raroth@student.ethz.ch>
//
// Simple Strided Copy

#include <stdint.h>
#include "regs/cheshire.h"
#include "dif/clint.h"
#include "dif/uart.h"
#include "dif/dma.h"
#include "params.h"
#include "util.h"

#include "sup_virt_adr.h"

/* 
This Benchmark copies 1MB in a strided access.

We initalize two 8MB Array (src & dst) - Copy 4x 256kB with a stride of 1MB. This results in a array structer of
array [32][256kB];

Initalized:
(0x281800000 - 0x281FFFFFF)
(0x282000000 - 0x2827FFFFF)

Copied:
(0x281800000 - 0x28183FFFF) to (0x282000000 - 0x28203FFFF)
(0x281900000 - 0x28193FFFF) to (0x282100000 - 0x28213FFFF)
(0x281A00000 - 0x281A3FFFF) to (0x282200000 - 0x28223FFFF)
(0x281B00000 - 0x281B3FFFF) to (0x282300000 - 0x28233FFFF)

Configuration:
- idma config as 2D!

Remark:
- In this Benchmark the copy is page aligned
*/


// Define the Root Acess of the Page Table
#define PAGE_TABLE_ROOT_ADRESSE 0x0000000080000000

// Main Function
int main(void) {

    // Setup the USART Frequency
    uint32_t rtc_freq = *reg32(&__base_regs, CHESHIRE_RTC_FREQ_REG_OFFSET);
    uint64_t reset_freq = clint_get_core_freq(rtc_freq, 2500);
    uart_init(&__base_uart, reset_freq, __BOOT_BAUDRATE);

    // All Vars to control the status of the page table
    uint64_t nxt_free_page = (PAGE_TABLE_ROOT_ADRESSE + 0x1000);
    zeros_page_table((void *) PAGE_TABLE_ROOT_ADRESSE);

    // Var to benchmark the system
    char buf[] = "Cycle Num: 0x0000000000000000\r\n";
    uint64_t start_cycle = 0;
    uint64_t end_cycle = 0;

    // Initialize an error
    int error = 0;

    // Could be generated with the random methode - be advised of overlapping spaces!
    transfer_t tf;
    tf.pa_src = (void *) 0x0000000081800000;
    tf.pa_dst = (void *) 0x0000000082000000;
    tf.va_src = tf.pa_src + 0x200000000;
    tf.va_dst = tf.pa_dst + 0x200000000;
    tf.len = 8388608;

    // Generate the Page Table for these adresses
    reserve_array(tf.va_src, &nxt_free_page, tf.len, PAGE_TABLE_ROOT_ADRESSE);
    reserve_array(tf.va_dst, &nxt_free_page, tf.len, PAGE_TABLE_ROOT_ADRESSE);

    // (Optional: Populate with data)
    // generate_data(tf.pa_src, 0, tf.len);
    // generate_data(tf.pa_dst, 1, tf.len);
    generate_data((void*) 0x081800000, 0, 262144);
    generate_data((void*) 0x081900000, 1, 262144);
    generate_data((void*) 0x081A00000, 2, 262144);
    generate_data((void*) 0x081B00000, 3, 262144);

    generate_data((void*) 0x082000000, 4, 262144);
    generate_data((void*) 0x082100000, 5, 262144);
    generate_data((void*) 0x082200000, 6, 262144);
    generate_data((void*) 0x082300000, 7, 262144);

    // Setup the sMMU Config
    sys_dma_smmu_config(0,0,1,0);
    sys_dma_smmu_set_pt_root(PAGE_TABLE_ROOT_ADRESSE);

    // to flush the cache to DRAM
    fence(); 

    // DMA Copy here
    start_cycle = get_mcycle();
    sys_dma_2d_blk_memcpy((uintptr_t)(void *) 0x0000000281800000, (uintptr_t)(void *) 0x0000000282000000, 262144, 1048576, 1048576, 3);
    end_cycle = get_mcycle();

    // Verify Data Copy -- Split up into 4x 256kB
    error = error | verify_data((void *) 0x0000000081800000, (void *) 0x00000000282000000, 262144);
    error = error | verify_data((void *) 0x0000000081900000, (void *) 0x00000000282100000, 262144);
    error = error | verify_data((void *) 0x0000000081A00000, (void *) 0x00000000282200000, 262144);
    error = error | verify_data((void *) 0x0000000081B00000, (void *) 0x00000000282300000, 262144);

    // Write the cycle count
    convert_hex_to_string((end_cycle - start_cycle), &buf[13], 16);
    uart_write_str(&__base_uart, buf, sizeof(buf));
    uart_write_flush(&__base_uart);

    return error;
}