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
/*
#include "sw/device/lib/base/mmio.h"
#include "sw/device/lib/dif/dif_i2c.h"
*/

uint64_t boot_slave(uint64_t reset_freq) {
    //  scratch[0] provides an entry point, scratch[1] a start signal.
    volatile uint32_t *scratch = reg32(&__base_cheshire_regs, CHESHIRE_SCRATCH_0_REG_OFFSET);
    // TODO: Implement UART boot protocol in this loop and reduce poll rate.
    while (!scratch[1]) continue;
    fence();
    return invoke((void*)(uintptr_t)scratch[0]);
}

uint64_t boot_spi_sd(uint64_t reset_freq) {
    return 0;
}

uint64_t boot_spi_norflash(uint64_t reset_freq) {
    return 0;
}

uint64_t boot_i2c_eeprom(uint64_t reset_freq) {
    return 0;
}

int main() {
    // TODO: we *NEED* an established scheme to communicate from the chip
    // level to the SoC that the "final" boot clock is *ready*  and *stable*.
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
