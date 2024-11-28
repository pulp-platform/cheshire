// Copyright 2023 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Nicole Narr <narrn@student.ethz.ch>
// Christopher Reinwardt <creinwar@student.ethz.ch>
//
// Simple payload to test bootmodes

#include "regs/cheshire.h"
#include "dif/clint.h"
#include "dif/uart.h"
#include "dif/dma.h"
#include "params.h"
#include "util.h"

int main(void) {
    char str[] = "Start the sMMU test!\r\n";
    char end_str[] = "Finished Setting Up the sMMU\r\n";

    volatile char src_cached[] = "Simple DMA Test 1\r\n";   // Diese Adressen liegen im gecachten bereich
    volatile char dst_cached[] = "Unsucessfull Test\r\n";

    // Get pointer to uncached SPM source and destination
    volatile char *src = src_cached + 0x04000000;
    volatile char *dst = dst_cached + 0x04000000;

    // Copy from cached to uncached source to ensure it is DMA-accessible
    for (unsigned i = 0; i < sizeof(src_cached); ++i){
        src[i] = src_cached[i];
    }
    for (unsigned i = 0; i < sizeof(dst_cached); ++i){
        dst[i] = dst_cached[i];
    }
    
    // Setup the USART Frequency
    uint32_t rtc_freq = *reg32(&__base_regs, CHESHIRE_RTC_FREQ_REG_OFFSET);
    uint64_t reset_freq = clint_get_core_freq(rtc_freq, 2500);
    uart_init(&__base_uart, reset_freq, __BOOT_BAUDRATE);

    // Write the start Message
    uart_write_str(&__base_uart, str, sizeof(str));
    uart_write_flush(&__base_uart);

    // Set the sMMU Config Flags
    sys_dma_smmu_config(0,1,0,0);
    sys_dma_smmu_set_pt_root(0x123456789ABCDEF0);

    // Start den Memory Transfer
    sys_dma_memcpy((uintptr_t)(void *)dst, (uintptr_t)(void *)src, sizeof(src_cached));

    // Write Destination Adress
    uart_write_str(&__base_uart, dst, sizeof(dst));
    uart_write_flush(&__base_uart);

    // Write the end Message
    uart_write_str(&__base_uart, end_str, sizeof(end_str));
    uart_write_flush(&__base_uart);

    return 0;
}
