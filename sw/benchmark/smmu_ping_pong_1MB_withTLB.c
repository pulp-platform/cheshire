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
This Benchmark copies 1MB in a ping pong buffer.

We initalize four different Array (src buffer (2MB) - ping (256k) - pong (256k) - dst buffer (2MB))
Use random Access to trash buffers?

Initalized:
(0x281000000 - 0x2811FFFFF) - SRC (2MB)
(0x281800000 - 0x28183FFFF) - pong (256k)
(0x281880000 - 0x2818BFFFF) - pong (256k)
(0x282000000 - 0x2821FFFFF) - DST (2MB)

Copied:
We start by copying 256kB data from the src in the first ping buffer. Then we start tracking the cycle number
Overall we copy 3.5MB Data in the section where we track the cycle number

Configuration:
- idma config as 1D!

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
    char buf_succ[] = "Copy Succ\r\n";
    char buf_fail[] = "Copy Fail\r\n";
    uint64_t start_cycle = 0;
    uint64_t end_cycle = 0;

    // Var for Params
    uint64_t updateTLB = 1;
    uint64_t bareAdr = 0;

    // Initialize an error
    int error = 0;

    // Could be generated with the random methode - be advised of overlapping spaces!
    transfer_t tf;
    tf.pa_src = (void *) 0x0000000081000000;
    tf.pa_dst = (void *) 0x0000000082000000;
    tf.va_src = tf.pa_src + 0x200000000;
    tf.va_dst = tf.pa_dst + 0x200000000;
    tf.len = 2097152;

    transfer_t tf_pp;
    tf_pp.pa_src = (void *) 0x0000000081800000;
    tf_pp.pa_dst = (void *) 0x0000000081880000;
    tf_pp.va_src = tf_pp.pa_src + 0x200000000;
    tf_pp.va_dst = tf_pp.pa_dst + 0x200000000;
    tf_pp.len = 262144;

    // Generate the Page Table for these adresses
    reserve_array(tf.va_src, &nxt_free_page, tf.len, PAGE_TABLE_ROOT_ADRESSE);
    reserve_array(tf.va_dst, &nxt_free_page, tf.len, PAGE_TABLE_ROOT_ADRESSE);
    reserve_array(tf_pp.va_src, &nxt_free_page, tf_pp.len, PAGE_TABLE_ROOT_ADRESSE);
    reserve_array(tf_pp.va_dst, &nxt_free_page, tf_pp.len, PAGE_TABLE_ROOT_ADRESSE);

    // (Optional: Populate with data)
    generate_data(tf.pa_src, 0, tf.len);
    generate_data(tf.pa_dst, 1, tf.len);
    generate_data(tf_pp.pa_src, 2, tf_pp.len);
    generate_data(tf_pp.pa_dst, 3, tf_pp.len);

    // Setup the sMMU Config
    sys_dma_smmu_config(0,bareAdr,updateTLB,0);
    sys_dma_smmu_set_pt_root(PAGE_TABLE_ROOT_ADRESSE);

    // to flush the cache to DRAM
    fence(); 

    // Fill the Ping buffer initaly with data
    // SRC 0x281000000 to 0x28103FFFF
    sys_dma_blk_memcpy((uintptr_t)(void *) tf_pp.va_src, (uintptr_t)(void *) tf.va_src, 262144);

    // Start tracking how much we copied
    void * buffer_src_ptr = tf.va_src + 262144;
    void * buffer_dst_ptr = tf.va_dst;

    // Start Tracking the Time here
    start_cycle = get_mcycle();

    // SRC 0x281040000 to 0x28107FFFF
    // DST 0x282000000 to 0x28203FFFF
    sys_dma_memcpy((uintptr_t)(void *) buffer_dst_ptr, (uintptr_t)(void *) tf_pp.va_src, 262144);
    sys_dma_blk_memcpy((uintptr_t)(void *) tf_pp.va_dst, (uintptr_t)(void *) (buffer_src_ptr), 262144);
    buffer_src_ptr = buffer_src_ptr + 262144;
    buffer_dst_ptr = buffer_dst_ptr + 262144;

    // SRC 0x281080000 to 0x2810BFFFF
    // DST 0x282040000 to 0x28207FFFF
    sys_dma_memcpy((uintptr_t)(void *) buffer_dst_ptr, (uintptr_t)(void *) tf_pp.va_dst, 262144);
    sys_dma_blk_memcpy((uintptr_t)(void *) tf_pp.va_src, (uintptr_t)(void *) (buffer_src_ptr), 262144);
    buffer_src_ptr = buffer_src_ptr + 262144;
    buffer_dst_ptr = buffer_dst_ptr + 262144;

    // SRC 0x2810C0000 to 0x2810FFFFF
    // DST 0x282080000 to 0x2820BFFFF
    sys_dma_memcpy((uintptr_t)(void *) buffer_dst_ptr, (uintptr_t)(void *) tf_pp.va_src, 262144);
    sys_dma_blk_memcpy((uintptr_t)(void *) tf_pp.va_dst, (uintptr_t)(void *) (buffer_src_ptr), 262144);
    buffer_src_ptr = buffer_src_ptr + 262144;
    buffer_dst_ptr = buffer_dst_ptr + 262144;

    // SRC 0x281100000 to 0x28113FFFF
    // DST 0x2820C0000 to 0x2820FFFFF
    sys_dma_memcpy((uintptr_t)(void *) buffer_dst_ptr, (uintptr_t)(void *) tf_pp.va_dst, 262144);
    sys_dma_blk_memcpy((uintptr_t)(void *) tf_pp.va_src, (uintptr_t)(void *) (buffer_src_ptr), 262144);
    buffer_src_ptr = buffer_src_ptr + 262144;
    buffer_dst_ptr = buffer_dst_ptr + 262144;

    // SRC 0x281140000 to 0x28117FFFF
    // DST 0x282100000 to 0x28213FFFF
    sys_dma_memcpy((uintptr_t)(void *) buffer_dst_ptr, (uintptr_t)(void *) tf_pp.va_src, 262144);
    sys_dma_blk_memcpy((uintptr_t)(void *) tf_pp.va_dst, (uintptr_t)(void *) (buffer_src_ptr), 262144);
    buffer_src_ptr = buffer_src_ptr + 262144;
    buffer_dst_ptr = buffer_dst_ptr + 262144;

    // SRC 0x281180000 to 0x2811BFFFF
    // DST 0x282140000 to 0x28217FFFF
    sys_dma_memcpy((uintptr_t)(void *) buffer_dst_ptr, (uintptr_t)(void *) tf_pp.va_dst, 262144);
    sys_dma_blk_memcpy((uintptr_t)(void *) tf_pp.va_src, (uintptr_t)(void *) (buffer_src_ptr), 262144);
    buffer_src_ptr = buffer_src_ptr + 262144;
    buffer_dst_ptr = buffer_dst_ptr + 262144;

    // SRC 0x2811C0000 to 0x2811FFFFF
    // DST 0x282180000 to 0x2821BFFFF
    sys_dma_memcpy((uintptr_t)(void *) buffer_dst_ptr, (uintptr_t)(void *) tf_pp.va_dst, 262144);
    sys_dma_blk_memcpy((uintptr_t)(void *) tf_pp.va_src, (uintptr_t)(void *) (buffer_src_ptr), 262144);
    buffer_src_ptr = buffer_src_ptr + 262144;
    buffer_dst_ptr = buffer_dst_ptr + 262144;

    // Get the End Time here
    end_cycle = get_mcycle();

    // Copy the last data from the pong buffer
    // DST 0x2821C0000 to 0x2821FFFFF
    sys_dma_memcpy((uintptr_t)(void *) buffer_dst_ptr, (uintptr_t)(void *) tf_pp.va_src, 262144);

    // Verify Data Copy
    error = verify_data(tf.pa_src, tf.pa_dst, tf.len);

    // Write the cycle count
    convert_hex_to_string((end_cycle - start_cycle), &buf[13], 16);
    uart_write_str(&__base_uart, buf, sizeof(buf));
    uart_write_flush(&__base_uart);

    if(error == 0){
        uart_write_str(&__base_uart, buf_succ, sizeof(buf_succ));
        uart_write_flush(&__base_uart);
    } else {
        uart_write_str(&__base_uart, buf_fail, sizeof(buf_fail));
        uart_write_flush(&__base_uart);
    }

    // Print Debug Data
    char buf_data[] = "Reg: 0x0000000000000000, Ptr High: 0x0000000000000000, Ptr Low: 0x0000000000000000\r\n";
    convert_hex_to_string((uint64_t) (*(sys_dma_smmu_conf_ptr())), &buf_data[7], 16);
    convert_hex_to_string((uint64_t) (*(sys_dma_smmu_pt_root_high_ptr())), &buf_data[37], 16);
    convert_hex_to_string((uint64_t) (*(sys_dma_smmu_pt_root_low_ptr())), &buf_data[66], 16);
    uart_write_str(&__base_uart, buf_data, sizeof(buf_data));
    uart_write_flush(&__base_uart);

    return error;
}