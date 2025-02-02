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
This Benchmark copies always 512kB Data from the Source to the Destination.
The request will be split up in stream of 256kB / 64kB / 16kB / 4kB / 1kB / 256B / 64B

We initalize two 1MB where we can data copy to / from!
Additionally the stride is choosen in such a way that it will alwys align in memory!

Initalized:
(0x281000000 - 0x2810FFFFF)
(0x282000000 - 0x2820FFFFF)

Copied:
Div.

Configuration:
- idma config as 2D!

Remark:
- In this Benchmark the copy is page aligned
- In this Benchmark we do not check if the data is copied correctly due to reducing simulation overhead. Other Benchmarks will check if the data are copied!

Note:
- Remember to update the TLB Policies / Reorder Buffer Size in the HW Wrapper
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

    // Var for Params
    uint64_t updateTLB = 0;
    uint64_t bareAdr = 1;

    // Could be generated with the random methode - be advised of overlapping spaces!
    transfer_t tf;
    tf.pa_src = (void *) 0x0000000081000000;
    tf.pa_dst = (void *) 0x0000000082000000;
    tf.va_src = tf.pa_src + 0x200000000;
    tf.va_dst = tf.pa_dst + 0x200000000;
    tf.len = 1048576;

    // Generate the Page Table for these adresses
    reserve_array(tf.va_src, &nxt_free_page, tf.len, PAGE_TABLE_ROOT_ADRESSE);
    reserve_array(tf.va_dst, &nxt_free_page, tf.len, PAGE_TABLE_ROOT_ADRESSE);

    // (Optional: Populate with data)
    generate_data(tf.pa_src, 0, tf.len);
    generate_data(tf.pa_dst, 1, tf.len);

    // Setup the sMMU Config
    sys_dma_smmu_config(0,bareAdr,updateTLB,0);
    sys_dma_smmu_set_pt_root(PAGE_TABLE_ROOT_ADRESSE);

    // to flush the cache to DRAM
    fence(); 

    // DMA Copy here
    start_cycle = get_mcycle();
    //sys_dma_2d_blk_memcpy((uintptr_t)(void *) tf.pa_src, (uintptr_t)(void *) tf.pa_dst, 262144, 262144, 262144, 2);  //    2x 256kB
    sys_dma_2d_blk_memcpy((uintptr_t)(void *) tf.pa_src, (uintptr_t)(void *) tf.pa_dst, 65536, 65536, 65536, 8);     //    8x  64kB
    //sys_dma_2d_blk_memcpy((uintptr_t)(void *) tf.pa_src, (uintptr_t)(void *) tf.pa_dst, 16384, 16384, 16384, 32);    //   32x  16kB
    //sys_dma_2d_blk_memcpy((uintptr_t)(void *) tf.pa_src, (uintptr_t)(void *) tf.pa_dst, 4096, 4096, 4096, 128);      //  128x   4kB
    //sys_dma_2d_blk_memcpy((uintptr_t)(void *) tf.pa_src, (uintptr_t)(void *) tf.pa_dst, 1024, 1024, 1024, 512);      //  512x   1kB
    //sys_dma_2d_blk_memcpy((uintptr_t)(void *) tf.pa_src, (uintptr_t)(void *) tf.pa_dst, 256, 256, 256, 2048);        // 2048x  256B
    //sys_dma_2d_blk_memcpy((uintptr_t)(void *) tf.pa_src, (uintptr_t)(void *) tf.pa_dst, 64, 64, 64, 8192);           // 8192x   64B
    end_cycle = get_mcycle();

    // Write the cycle count
    convert_hex_to_string((end_cycle - start_cycle), &buf[13], 16);
    uart_write_str(&__base_uart, buf, sizeof(buf));
    uart_write_flush(&__base_uart);

    return 0;
}