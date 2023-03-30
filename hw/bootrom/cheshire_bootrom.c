// Copyright 2022 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Nicole Narr <narrn@student.ethz.ch>
// Christopher Reinwardt <creinwar@student.ethz.ch>
// Paul Scheffler <paulsc@student.ethz.ch>

#include <stdint.h>
#include "util.h"
#include "params.h"
#include "regs/cheshire.h"
#include "regs/serial_link.h"
#include "spi_host_regs.h"
#include "dif/clint.h"
#include "hal/i2c_24fc1025.h"
#include "hal/spi_s25fs512s.h"
#include "hal/spi_sdcard.h"
#include "hal/uart_debug.h"
#include "gpt.h"

int boot_passive(uint64_t core_freq) {
    // Initialize UART with debug settings
    uart_debug_init(&__base_uart, core_freq);
    // scratch[0] provides an entry point, scratch[1] a start signal
    volatile uint32_t *scratch = reg32(&__base_regs, CHESHIRE_SCRATCH_0_REG_OFFSET);
    // While we poll bit 2 of scratch[2], check for incoming UART debug requests
    while (!(scratch[2] & 2))
        if (uart_debug_check(&__base_uart))
            return uart_debug_serve(&__base_uart);
    // No UART (or JTAG) requests came in, but scratch[2][2] was set --> run code at scratch[1:0]
    scratch[2] = 0;
    return invoke((void*)(uintptr_t)(((uint64_t)scratch[1] << 32) | scratch[0]));
}

int boot_spi_sdcard(uint64_t core_freq, uint64_t rtc_freq) {
    // Initialize device handle
    spi_sdcard_t device = {
        .spi_freq = 24*1000*1000,  // 24MHz (maximum is 25MHz)
        .csid = 0,
        .csid_dummy = SPI_HOST_PARAM_NUM_C_S - 1  // Last physical CS is designated dummy
    };
    CHECK_CALL(spi_sdcard_init(&device, core_freq))
    // Wait for device to be initialized (1ms, round up extra tick to be sure)
    clint_spin_until((1000*rtc_freq)/(1000*1000)+1);
    return gpt_boot_part_else_raw(spi_sdcard_read_checkcrc, &device,
                                  &__base_spm, __BOOT_SPM_MAX_LBAS);
}

int boot_spi_s25fs512s(uint64_t core_freq, uint64_t rtc_freq) {
    // Initialize device handle
    spi_s25fs512s_t device = {
        .spi_freq = MIN(40*1000*1000, core_freq/4),  // Up to quarter core freq or 40MHz
        .csid = 1
    };
    CHECK_CALL(spi_s25fs512s_init(&device, core_freq))
    // Wait for device to be initialized (t_PU = 300us, round up extra tick to be sure)
    clint_spin_until((350*rtc_freq)/(1000*1000)+1);
    return gpt_boot_part_else_raw(spi_s25fs512s_single_read, &device,
                                  &__base_spm, __BOOT_SPM_MAX_LBAS);
}

int boot_i2c_24fc1025(uint64_t core_freq) {
    // Initialize device handle
    dif_i2c_t i2c;
    CHECK_CALL(i2c_24fc1025_init(&i2c, core_freq))
    return gpt_boot_part_else_raw(i2c_24fc1025_read, &i2c,
                                  &__base_spm, __BOOT_SPM_MAX_LBAS);
}

int main() {
    // Read boot mode and reference frequency
    uint32_t bootmode = *reg32(&__base_regs, CHESHIRE_BOOT_MODE_REG_OFFSET);
    uint32_t rtc_freq = *reg32(&__base_regs, CHESHIRE_RTC_FREQ_REG_OFFSET);
    // Compute the boot core frequency using the reference clock
    uint64_t core_freq = clint_get_core_freq(rtc_freq, 10);
    // In case of reentry, store return in scratch0 as is convention
    switch (bootmode) {
    case 0:
        return boot_passive(core_freq);
    case 1:
        return boot_spi_sdcard(core_freq, rtc_freq);
    case 2:
        return boot_spi_s25fs512s(core_freq, rtc_freq);
    case 3:
        return boot_i2c_24fc1025(core_freq);
    default:
        return boot_passive(core_freq);
    }
}
