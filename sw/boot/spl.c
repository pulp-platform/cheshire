// Copyright 2023 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Nicole Narr <narrn@student.ethz.ch>
// Christopher Reinwardt <creinwar@student.ethz.ch>

#include <stdint.h>
#include "util.h"
#include "params.h"
#include "regs/cheshire.h"
#include "dif/clint.h"
#include "gpt.h"
#include "dif/uart.h"
#include "printf.h"

// TODO: delete me!

#include "spi_host_regs.h"
#include "hal/spi_sdcard.h"

// ENDTODO

int main(void) {
    // Get system parameters and init UART
    uint32_t read = *reg32(&__base_regs, CHESHIRE_SCRATCH_0_REG_OFFSET);
    void* priv = (void*)(uintptr_t)*reg32(&__base_regs, CHESHIRE_SCRATCH_1_REG_OFFSET);
    uint32_t bootmode = *reg32(&__base_regs, CHESHIRE_BOOT_MODE_REG_OFFSET);
    uint32_t rtc_freq = *reg32(&__base_regs, CHESHIRE_RTC_FREQ_REG_OFFSET);
    uint64_t core_freq = clint_get_core_freq(rtc_freq, 2500);
    uart_init(&__base_uart, core_freq, 115200);

    // TODO: delete me!
    spi_sdcard_t device = {
        .spi_freq = 24 * 1000 * 1000, // 24MHz (maximum is 25MHz)
        .csid = 0,
        .csid_dummy = SPI_HOST_PARAM_NUM_C_S - 1 // Last physical CS is designated dummy
    };
    CHECK_CALL(spi_sdcard_init(&device, core_freq))
    // Wait for device to be initialized (1ms, round up extra tick to be sure)
    clint_spin_until((1000 * rtc_freq) / (1000 * 1000) + 1);
    read = (uintptr_t)((void*) spi_sdcard_read_checkcrc) | 1;
    priv = (void*) &device;
    // ENDTODO

    // Print boot-critical cat, and also parameters
    printf(
        " /\\___/\\       === Cheshire RISC-V SoC ===\r\n"
        "( o   o )      Boot mode:       %d\r\n"
        "(  =^=  )      Real-time clock: %d Hz\r\n"
        "(        )     System clock:    %d Hz\r\n"
        "(    P    )    Read pointer     0x%lx\r\n"
        "(  U * L   )   Read argument:   0x%lx\r\n"
        "(    P      )\r\n"
        "(           )))))))))))\r\n\r\n",
        bootmode, rtc_freq, core_freq, read, priv);

    // TODO: place preload device tree at start of read pointer
    typedef int (*payload_t)(uint64_t, uint64_t, uint64_t);
    void *read_ptr = (void*)(uintptr_t)(read & ~1);
    payload_t payload = (void*)(0x80000000);
    void* device_tree = ((uint8_t*) payload + 0x800000);

    // If this is a GPT disk boot, load remaining payload
    if (read & 1) {
        gpt_read_t read_ext = (gpt_read_t) read_ptr;
        // TODO: implement GPT partition scanning
        const uint64_t sec = 512;
        printf("[SPL] Copy device tree to 0x%lx...", device_tree);
        read_ext(priv, device_tree, 128*sec, 16*sec);
        printf(" OK\r\n");
        printf("[SPL] Copy payload to 0x%lx...", payload);
        read_ext(priv, payload, 2048*sec, (8192-2048)*sec);
        printf(" OK\r\n");
    }

    // Launch payload
    // TODO: handle multi-hart boot
    printf("[SPL] Launch payload at %lx with DT at %lx\r\n", payload, device_tree);
    fence(); fencei();
    return payload(0, (uintptr_t)&device_tree, 0);
}
