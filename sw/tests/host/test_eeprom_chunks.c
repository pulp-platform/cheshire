// Copyright 2026 CheshireAra contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
// Actual HAL/DIF C with scripted MMIO responses, without an EEPROM model.
#include <stdint.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "hal/i2c_24fc1025.h"
#include "util.h"
#include "i2c_regs.h"
#define base mock
#include HAL_SOURCE
#undef base

void *__i2c_base_addr__;
static unsigned char identity;
static unsigned cases, errors, calls, format_count, rx_left, rx_index;
static unsigned packet_addr, requested_addr, requested_len, bytes_written;
static uint32_t control_reg;
static bool writing;
static uint8_t format_bytes[256], source_bytes[512];
static uint8_t pattern(unsigned address) {
    return (uint8_t)(0x35 + 29 * address + 7 * (address >> 3));
}
static void check(const char *label, unsigned got, unsigned want) {
    if (got != want) {
        errors++;
        printf("EEPROM_CHUNK_MISMATCH case=%u %s got=%u want=%u\n", cases, label, got, want);
    }
}
static void budget(void) {
    if (++calls > 100000) {
        puts("EEPROM_CHUNK_CONTROL_ERROR MMIO deadline");
        exit(2);
    }
}
void clint_spin_ticks(uint64_t ticks) {
    (void)ticks;
}
mmio_region_t mmio_region_from_addr(uintptr_t addr) {
    return (mmio_region_t){.mock = (void *)addr};
}
uint32_t mmio_region_read32(mmio_region_t region, ptrdiff_t offset) {
    budget();
    if (region.mock != &identity) {
        puts("EEPROM_CHUNK_CONTROL_ERROR MMIO identity");
        exit(2);
    }
    if (offset == I2C_CTRL_REG_OFFSET) return control_reg;
    if (offset == I2C_FIFO_STATUS_REG_OFFSET) return rx_left << I2C_FIFO_STATUS_RXLVL_OFFSET;
    if (offset == I2C_RDATA_REG_OFFSET) {
        if (!rx_left) {
            puts("EEPROM_CHUNK_CONTROL_ERROR empty RX");
            exit(2);
        }
        rx_left--;
        return pattern(packet_addr + rx_index++);
    }
    puts("EEPROM_CHUNK_CONTROL_ERROR unexpected read");
    exit(2);
}
void mmio_region_write32(mmio_region_t region, ptrdiff_t offset, uint32_t value) {
    budget();
    if (region.mock != &identity) {
        puts("EEPROM_CHUNK_CONTROL_ERROR MMIO identity");
        exit(2);
    }
    if (offset == I2C_FDATA_REG_OFFSET) {
        if (format_count == sizeof(format_bytes)) {
            puts("EEPROM_CHUNK_CONTROL_ERROR format capacity");
            exit(2);
        }
        format_bytes[format_count++] = (uint8_t)value;
        return;
    }
    if (offset != I2C_CTRL_REG_OFFSET) {
        puts("EEPROM_CHUNK_CONTROL_ERROR unexpected write");
        exit(2);
    }
    control_reg = value;
    if (!(value & (1u << I2C_CTRL_ENABLEHOST_BIT))) {
        format_count = 0;
        return;
    }
    if (format_count < 3) {
        puts("EEPROM_CHUNK_CONTROL_ERROR incomplete address");
        exit(2);
    }
    packet_addr = ((unsigned)format_bytes[1] << 8) | format_bytes[2];
    if (writing) {
        unsigned count = format_count - 3;
        check("contiguous write address", packet_addr, requested_addr + bytes_written);
        check("page boundary", (packet_addr & 127) + count <= 128, 1);
        for (unsigned i = 0; i < count; i++) {
            unsigned index = bytes_written + i;
            if (index >= requested_len)
                check("extra write byte", index, requested_len);
            else
                check("write data", format_bytes[3 + i], source_bytes[64 + index]);
        }
        bytes_written += count;
    } else {
        check("read format count", format_count, 5);
        rx_left = format_bytes[4];
        rx_index = 0;
        check("RX FIFO capacity", rx_left <= I2C_PARAM_FIFO_DEPTH, 1);
    }
}
int main(void) {
    const unsigned addresses[] = {0, 1, 31, 63, 127};
    const unsigned lengths[] = {0, 1, 31, 32, 33, 63, 64, 65, 128, 129};
    dif_i2c_t i2c = {.base_addr = {.mock = &identity}};
    for (unsigned mode = 0; mode < 2; mode++)
        for (unsigned a = 0; a < sizeof(addresses) / sizeof(addresses[0]); a++)
            for (unsigned l = 0; l < sizeof(lengths) / sizeof(lengths[0]); l++) {
                uint8_t buffer[512];
                memset(buffer, 0xcc, sizeof(buffer));
                writing = mode;
                requested_addr = addresses[a];
                requested_len = lengths[l];
                cases++;
                control_reg = 1;
                rx_left = rx_index = format_count = bytes_written = calls = 0;
                if (writing)
                    for (unsigned i = 0; i < requested_len; i++)
                        buffer[64 + i] = pattern(requested_addr + i);
                memcpy(source_bytes, buffer, sizeof(buffer));
                int result =
                    writing ? i2c_24fc1025_write(&i2c, &buffer[64], requested_addr, requested_len)
                            : i2c_24fc1025_read(&i2c, &buffer[64], requested_addr, requested_len);
                check("return", result, 0);
                if (!requested_len) check("zero-length MMIO", calls, 0);
                if (writing) check("write byte count", bytes_written, requested_len);
                for (unsigned i = 0; i < sizeof(buffer); i++) {
                    uint8_t expected = (!writing && i >= 64 && i < 64 + requested_len)
                                           ? pattern(requested_addr + i - 64)
                                           : source_bytes[i];
                    check("buffer and guard", buffer[i], expected);
                }
            }
    printf("EEPROM_CHUNK_DONE cases=%u errors=%u\n", cases, errors);
    return errors ? 1 : 0;
}
