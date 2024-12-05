// Copyright 2023 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Raphael Roth <narrn@student.ethz.ch>
//
// Simple payload to test bootmodes

#include <stdint.h>
#include "regs/cheshire.h"
#include "dif/clint.h"
#include "dif/uart.h"
#include "dif/dma.h"
#include "params.h"
#include "util.h"

#include "sup_virt_adr.h"

// This test copies one page!

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
    int error;

    // Fixed adresses - could be generated randomly (Attention to overlap!)
    transfer_t tf;
    tf.pa_src = (void *) 0x0000000081000000;
    tf.pa_dst = (void *) 0x0000000082000A3B;
    tf.va_src = tf.pa_src + 0x200000000;
    tf.va_dst = tf.pa_dst + 0x200000000;
    tf.len = 4096;

    // Generate the Page Table for these adresses
    reserve_array(tf.va_src, &nxt_free_page, tf.len, PAGE_TABLE_ROOT_ADRESSE);
    reserve_array(tf.va_dst, &nxt_free_page, tf.len, PAGE_TABLE_ROOT_ADRESSE);

    // (Optional: Populate with data)
    generate_data(tf.pa_src, 0, tf.len);
    generate_data(tf.pa_dst, 1, tf.len);

    // Setup the sMMU Config
    sys_dma_smmu_config(0,0,0,0);
    sys_dma_smmu_set_pt_root(PAGE_TABLE_ROOT_ADRESSE);

    // to flush the cache to DRAM
    fence(); 

    // DMA Copy here
    start_cycle = get_mcycle();
    sys_dma_blk_memcpy((uintptr_t)(void *) tf.va_dst, (uintptr_t)(void *) tf.va_src, tf.len);
    end_cycle = get_mcycle();

    // Verify Data Copy
    error = verify_data(tf.pa_src, tf.pa_dst, tf.len);

    // Write the cycle count
    convert_hex_to_string((end_cycle - start_cycle), &buf[13], 16);
    uart_write_str(&__base_uart, buf, sizeof(buf));
    uart_write_flush(&__base_uart);

    return error;
}