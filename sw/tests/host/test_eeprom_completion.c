// Copyright 2026 CheshireAra contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
// Actual HAL/DIF C. FIFO and host-idle responses are explicit host test inputs.
#include <stdint.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "hal/i2c_24fc1025.h"
#include "util.h"
#include "i2c_regs.h"
static volatile cheshire__regs_t host_registers;
#undef CHS_REGS
#define CHS_REGS (&host_registers)
#define base mock
#include HAL_SOURCE
#undef base

void *__i2c_base_addr__;
static unsigned char identity;
static unsigned cases, errors, calls, format_count, rx_left, busy_polls;
static unsigned wait_count, post_stop_waits;
static uint64_t post_stop_ticks;
static bool writing, final_stop;
static uint32_t control_reg;
static void check(const char *label, uint64_t got, uint64_t want) {
    if (got != want) {
        errors++;
        printf("EEPROM_COMPLETION_MISMATCH case=%u %s got=%llu want=%llu\n", cases, label,
               (unsigned long long)got, (unsigned long long)want);
    }
}
static void budget(void) {
    if (++calls > 10000) {
        puts("EEPROM_COMPLETION_CONTROL_ERROR polling deadline");
        exit(2);
    }
}
void clint_spin_ticks(uint64_t ticks) {
    wait_count++;
    if (wait_count > 1) {
        post_stop_waits++;
        post_stop_ticks = ticks;
        check("wait after final STOP", final_stop, 1);
        check("wait after host idle", busy_polls, 0);
    }
}
mmio_region_t mmio_region_from_addr(uintptr_t addr) {
    return (mmio_region_t){.mock = (void *)addr};
}
uint32_t mmio_region_read32(mmio_region_t region, ptrdiff_t offset) {
    budget();
    if (region.mock != &identity) {
        puts("EEPROM_COMPLETION_CONTROL_ERROR MMIO identity");
        exit(2);
    }
    if (offset == I2C_CTRL_REG_OFFSET) return control_reg;
    if (offset == I2C_STATUS_REG_OFFSET) {
        // FIFO is empty before the final ACK/STOP/host-idle indication.
        if (final_stop && busy_polls) busy_polls--;
        return (1u << I2C_STATUS_FMTEMPTY_BIT) | (busy_polls ? 0 : 1u << I2C_STATUS_HOSTIDLE_BIT);
    }
    if (offset == I2C_FIFO_STATUS_REG_OFFSET) return rx_left << I2C_FIFO_STATUS_RXLVL_OFFSET;
    if (offset == I2C_RDATA_REG_OFFSET) {
        if (!rx_left) {
            puts("EEPROM_COMPLETION_CONTROL_ERROR empty RX");
            exit(2);
        }
        rx_left--;
        return 0x5a;
    }
    puts("EEPROM_COMPLETION_CONTROL_ERROR unexpected read");
    exit(2);
}
void mmio_region_write32(mmio_region_t region, ptrdiff_t offset, uint32_t value) {
    budget();
    if (region.mock != &identity) {
        puts("EEPROM_COMPLETION_CONTROL_ERROR MMIO identity");
        exit(2);
    }
    if (offset == I2C_FDATA_REG_OFFSET) {
        format_count++;
        final_stop = ((value >> I2C_FDATA_STOP_BIT) & 1) != 0;
        return;
    }
    if (offset != I2C_CTRL_REG_OFFSET) {
        puts("EEPROM_COMPLETION_CONTROL_ERROR unexpected write");
        exit(2);
    }
    control_reg = value;
    if (value & (1u << I2C_CTRL_ENABLEHOST_BIT)) {
        busy_polls = 4;
        rx_left = writing ? 0 : 1;
    } else {
        format_count = 0;
        final_stop = false;
    }
}
int main(void) {
    const uint32_t frequencies[] = {0, 1, 200, 32768, UINT32_MAX};
    const uint64_t ticks[] = {0, 2, 2, 165, 21474838};
    dif_i2c_t i2c = {.base_addr = {.mock = &identity}};
    // One read with no RTC requirement, then writes including zero-RTC rejection.
    for (unsigned test = 0; test < 6; test++) {
        uint8_t buffer[8];
        memset(buffer, 0xcc, sizeof(buffer));
        buffer[3] = 0x31;
        writing = test != 0;
        unsigned f = writing ? test - 1 : 0;
        host_registers.rtc_freq.f.ref_freq = frequencies[f];
        cases++;
        control_reg = 1;
        calls = format_count = rx_left = busy_polls = wait_count = post_stop_waits = 0;
        post_stop_ticks = 0;
        final_stop = false;
        int result = writing ? i2c_24fc1025_write(&i2c, &buffer[3], 0, 1)
                             : i2c_24fc1025_read(&i2c, &buffer[3], 0, 1);
        if (writing && frequencies[f] == 0) {
            check("zero RTC result", result, 0x14);
            check("zero RTC no MMIO", calls, 0);
            check("zero RTC no waits", wait_count, 0);
        } else {
            check("return", result, 0);
            check("final STOP format flag", final_stop, 1);
            check("return after host idle", busy_polls, 0);
            check("format count", format_count, writing ? 4 : 5);
            check("wait count", wait_count, writing ? 2 : 1);
            check("post-STOP waits", post_stop_waits, writing ? 1 : 0);
            check("post-STOP ticks", post_stop_ticks, writing ? ticks[f] : 0);
        }
        for (unsigned i = 0; i < sizeof(buffer); i++)
            check("data and guard", buffer[i], i == 3 ? (!writing ? 0x5a : 0x31) : 0xcc);
    }
    printf("EEPROM_COMPLETION_DONE cases=%u errors=%u\n", cases, errors);
    return errors ? 1 : 0;
}
