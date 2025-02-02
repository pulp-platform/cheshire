// Copyright 2023 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Raphael Roth <raroth@student.ethz.ch>
//
// Simple Linear Copy

#include <stdint.h>
#include "regs/cheshire.h"
#include "dif/clint.h"
#include "dif/uart.h"
#include "dif/dma.h"
#include "params.h"
#include "util.h"

#include "sup_virt_adr.h"
#include "random_adr.h"

/* 
This Benchmark copies 1MB in a random access (This file is a performence version to run simulation on. It doesn't check if
the data are correct and only init all the required pages.)

Initalized:
All req. pages but nothing more

Copied:
Random

Configuration:
- idma config as 1D!

Remark:
- In this Benchmark the copy is page aligned
- DMA Transfer are blocking
- The array rand_src / rand_dst contains 256 adresses between 0x281000000 & 0x281FFF000 ( See extra h - file)
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

    // Generate the Page Table for these adresses
    for(int i = 0; i < 256; i++){
        reserve_array(rand_src[i], &nxt_free_page, 4096, PAGE_TABLE_ROOT_ADRESSE);
        reserve_array(rand_dst[i], &nxt_free_page, 4096, PAGE_TABLE_ROOT_ADRESSE);
        generate_data(rand_src[i] - 0x0000000200000000, 0, 4096);
        generate_data(rand_dst[i] - 0x0000000200000000, 1, 4096);
    }

    // Setup the sMMU Config
    sys_dma_smmu_config(0,bareAdr,updateTLB,0);
    sys_dma_smmu_set_pt_root(PAGE_TABLE_ROOT_ADRESSE);

    // to flush the cache to DRAM
    fence(); 

    // DMA Copy here
    start_cycle = get_mcycle();
    for(int i = 0; i < 256;i ++){   // 256
        sys_dma_blk_memcpy((uintptr_t)(void *) rand_src[i] - 0x0000000200000000, (uintptr_t)(void *) rand_dst[i] - 0x0000000200000000, 4096);
    }
    end_cycle = get_mcycle();

    // Write the cycle count
    convert_hex_to_string((end_cycle - start_cycle), &buf[13], 16);
    uart_write_str(&__base_uart, buf, sizeof(buf));
    uart_write_flush(&__base_uart);

    return 0;
}