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
#include "hal/i2c_24xx1025.h"
#include "hal/spi_s25fs512s.h"
#include "hal/uart_debug.h"
#include "gpt.h"

int boot_slave(uint64_t reset_freq) {
    // Initialize UART with debug settings
    uart_debug_init(&__base_uart, reset_freq);
    // scratch[0] provides an entry point, scratch[1] a start signal
    volatile uint32_t *scratch = reg32(&__base_cheshire_regs, CHESHIRE_SCRATCH_0_REG_OFFSET);
    // While we poll scratch[1], check for incoming UART debug requests
    while (!scratch[1])
        if (uart_debug_check(&__base_uart))
            return uart_debug_serve(&__base_uart);
    // No UART (or JTAG) requests came in, but scratch[1] was set --> run code at scratch[0]
    return invoke((void*)(uintptr_t)scratch[0]);
}

int boot_spi_sd(uint64_t reset_freq) {
    // TODO
    return 0;
}

int boot_spi_norflash(uint64_t reset_freq) {
    // Initialize SPI NOR FLASH HAL
    spi_s25fs512s_t device = {
        .spi_freq = MIN(40*1000*1000, reset_freq/4),  // Quarter of core freq, at most 40 MHz
        .csid = 1
    };
    // TODO: wait for device initialization
    CHECK_CALL(spi_s25fs512s_init(&device, reset_freq))
    // Try to detect GPT signature; otherwise, raw boot from LBA 0
    uint64_t lba_begin = 0, lba_end = __BOOT_SPM_MAX_LBAS;
    if (gpt_check_signature(spi_s25fs512s_single_read, &device))
        CHECK_CALL(gpt_find_boot_partition(spi_s25fs512s_single_read, &device, &lba_begin,
                                           &lba_end, __BOOT_SPM_MAX_LBAS))
    // Copy code to SPM
    uint64_t addr = 0x200 * lba_begin;
    uint64_t len = 0x200 * (lba_end - lba_begin);
    CHECK_CALL(spi_s25fs512s_single_read(&device, &__base_spm, addr, len));
    // Invoke code
    return invoke((void*)&__base_spm);
}

int boot_i2c_eeprom(uint64_t reset_freq) {
    // Initialize I2C EEPROM HAL
    dif_i2c_t i2c;
    CHECK_CALL(i2c_24xx1025_init(&i2c, reset_freq))
    // Try to detect GPT signature; otherwise, raw boot from LBA 0
    uint64_t lba_begin = 0, lba_end = __BOOT_SPM_MAX_LBAS;
    if (gpt_check_signature(i2c_24xx1025_read, &i2c))
        CHECK_CALL(gpt_find_boot_partition(i2c_24xx1025_read, &i2c, &lba_begin,
                                           &lba_end, __BOOT_SPM_MAX_LBAS))
    // Copy code to SPM
    uint64_t addr = 0x200 * lba_begin;
    uint64_t len = 0x200 * (lba_end - lba_begin);
    CHECK_CALL(i2c_24xx1025_read(&i2c, &__base_spm, addr, len));
    // Invoke code
    return invoke((void*)&__base_spm);
}

int main() {
    // TODO: we *NEED* an established scheme to communicate from the chip
    // level to the SoC that the "final" boot clock is *ready* and *stable*.
    // We should wait for this here, right at the beginning.

    uint32_t bootmode = *reg32(&__base_cheshire_regs, CHESHIRE_BOOT_MODE_REG_OFFSET);
    uint32_t reset_freq = *reg32(&__base_cheshire_regs, CHESHIRE_RESET_FREQ_REG_OFFSET);

    // In case of reentry, store return in scratch0 as is convention.
    switch (bootmode) {
    case 0:
        return boot_slave(reset_freq);
    case 1:
        return boot_spi_sd(reset_freq);
    case 2:
        return boot_spi_norflash(reset_freq);
    case 3:
        return boot_i2c_eeprom(reset_freq);
    default:
        return boot_slave(reset_freq);
    }
}
