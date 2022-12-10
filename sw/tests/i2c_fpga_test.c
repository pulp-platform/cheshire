// Copyright 2022 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Nicole Narr <narrn@student.ethz.ch>
// Christopher Reinwardt <creinwar@student.ethz.ch>

#include "uart.h"
#include "printf.h"
#include "sw/device/lib/base/mmio.h"
#include "sw/device/lib/dif/dif_i2c.h"
#include "sleep.h"
#include "util.h"
#include <stdint.h>

#define CORE_FREQ_HZ 50000000

char uart_initialized = 0;

unsigned long int timer_count = 0;

uint8_t ina219_addresses[6] = {
    0b1000101,  // VCC1V0
    0b1001100,  // VCC1V5
    0b1001000,  // VCC1V8
    0b1000001,  // VADJ
    0b1000100,  // VCC3V3
    0b1000000   // VCC5V0
};

char *ina219_rails[6] = {
    "VCC1V0",
    "VCC1V5",
    "VCC1V8",
    "VADJ",
    "VCC3V3",
    "VCC5V0"
};

extern void *__base_i2c;

void __attribute__((aligned(4))) trap_vector(void)
{
    long int mcause = 0, mepc = 0, mip = 0, mie = 0, mstatus = 0, mtval = 0;

    asm volatile(
        "csrrs t0, mcause, x0\n     \
         sd t0, %0\n                \
         csrrs t0, mepc, x0\n       \
         sd t0, %1\n                \
         csrrs t0, mip, x0\n        \
         sd t0, %2\n                \
         csrrs t0, mie, x0\n        \
         sd t0, %3\n                \
         csrrs t0, mstatus, x0\n    \
         sd t0, %4\n                \
         csrrs t0, mtval, x0\n      \
         sd t0, %5\n"
         : "=m" (mcause),
           "=m" (mepc),
           "=m" (mip),
           "=m" (mie),
           "=m" (mstatus),
           "=m" (mtval)
         :: "t0");

    // Interrupt with exception code 7 == Machine Mode Timer Interrupt
    if(mcause < 0 && (mcause << 1) == 14){
        // Handle interrupt by disabling the timer interrupt and returning
        asm volatile(
            "addi t0, x0, 128\n     \
             csrrc x0, mie, t0\n"
            ::: "t0"
        );
        return;
    } else {
        if(uart_initialized){
            printf("Hello from the trap_vector :)\r\n");
            printf("mcause:    0x%lx\r\n", mcause);
            printf("mepc:      0x%lx\r\n", mepc);
            printf("mip:       0x%lx\r\n", mip);
            printf("mie:       0x%lx\r\n", mie);
            printf("mstatus:   0x%lx\r\n", mstatus);
            printf("mtval:     0x%lx\r\n", mtval);
        }
    }

    while(1){
        asm volatile("wfi\n" :::);
    }

    return;
}

void xilinx_ina219_init(dif_i2c_t *i2c, uint8_t address){
    uint8_t tx_fifo_level = 0, rx_fifo_level = 0;

    // I2C Slave Address + Write operation
    uint8_t ctrl_byte = (address << 1) | 0;

    // Configuration register
    CHECK_ELSE_TRAP(dif_i2c_write_byte(i2c, ctrl_byte, kDifI2cFmtStart, true), kDifI2cOk)
    CHECK_ELSE_TRAP(dif_i2c_write_byte(i2c, 0, kDifI2cFmtTx, true), kDifI2cOk)
    CHECK_ELSE_TRAP(dif_i2c_write_byte(i2c, 0x08, kDifI2cFmtTx, true), kDifI2cOk)
    CHECK_ELSE_TRAP(dif_i2c_write_byte(i2c, 0x67, kDifI2cFmtTxStop, true), kDifI2cOk)

    // Wait for sending to complete
    do CHECK_ELSE_TRAP(dif_i2c_get_fifo_levels(i2c, &tx_fifo_level, &rx_fifo_level), kDifI2cOk)
    while (tx_fifo_level != 0);

    // Calibration register
    CHECK_ELSE_TRAP(dif_i2c_write_byte(i2c, ctrl_byte, kDifI2cFmtStart, true), kDifI2cOk)
    CHECK_ELSE_TRAP(dif_i2c_write_byte(i2c, 5, kDifI2cFmtTx, true), kDifI2cOk)
    CHECK_ELSE_TRAP(dif_i2c_write_byte(i2c, 0x40, kDifI2cFmtTx, true), kDifI2cOk)
    CHECK_ELSE_TRAP(dif_i2c_write_byte(i2c, 0x00, kDifI2cFmtTxStop, true), kDifI2cOk)

    // Wait for sending to complete
    do CHECK_ELSE_TRAP(dif_i2c_get_fifo_levels(i2c, &tx_fifo_level, &rx_fifo_level), kDifI2cOk)
    while (tx_fifo_level != 0);
}

int xilinx_ina219_read_reg(dif_i2c_t *i2c, uint8_t address, uint8_t reg){
    short buf;
    uint8_t *buf_ptr = (uint8_t *) &buf;
    uint8_t tx_fifo_level = 0, rx_fifo_level = 0;

    // I2C Slave Address + Write operation
    uint8_t ctrl_byte = (address << 1) | 0;

    // Set pointer register
    CHECK_ELSE_TRAP(dif_i2c_write_byte(i2c, ctrl_byte, kDifI2cFmtStart, true), kDifI2cOk)
    CHECK_ELSE_TRAP(dif_i2c_write_byte(i2c, reg, kDifI2cFmtTxStop, true), kDifI2cOk)

    // Wait for sending to complete
    do CHECK_ELSE_TRAP(dif_i2c_get_fifo_levels(i2c, &tx_fifo_level, &rx_fifo_level), kDifI2cOk)
    while (tx_fifo_level != 0);

    // I2C Slave Address + Read operation
    ctrl_byte = (address << 1) | 1;
    // Set pointer register
    CHECK_ELSE_TRAP(dif_i2c_write_byte(i2c, ctrl_byte, kDifI2cFmtStart, true), kDifI2cOk)
    CHECK_ELSE_TRAP(dif_i2c_write_byte(i2c, 2, kDifI2cFmtRx, false), kDifI2cOk)

    // Wait for sending to complete
    do {
        CHECK_ELSE_TRAP(dif_i2c_get_fifo_levels(i2c, &tx_fifo_level, &rx_fifo_level), kDifI2cOk)
    } while (rx_fifo_level < 2);

    CHECK_ELSE_TRAP(dif_i2c_read_byte(i2c, &buf_ptr[1]), kDifI2cOk)
    CHECK_ELSE_TRAP(dif_i2c_read_byte(i2c, &buf_ptr[0]), kDifI2cOk)

    return (int) buf;
}


int main(void)
{
    init_uart(CORE_FREQ_HZ, 115200);
    uart_initialized = 1;
    printf("Testing I2C\r\n");

    // Obtain handle to I2C
    //mmio_region_t i2c_base = mmio_region_from_addr((uintptr_t) &__base_i2c);
    mmio_region_t i2c_base = (mmio_region_t){.base = (void *) &__base_i2c};
    dif_i2c_params_t i2c_params = {.base_addr = i2c_base};
    dif_i2c_t i2c;
    CHECK_ELSE_TRAP(dif_i2c_init(i2c_params, &i2c), kDifI2cOk)

    // Configure I2C: worst case 24xx1025 @1.7V
    const uint32_t per_periph_ns = 1000*1000*1000/CORE_FREQ_HZ;
    const dif_i2c_timing_config_t timing_config = {
        .clock_period_nanos         = per_periph_ns,    // System-side periph clock
        .lowest_target_device_speed = kDifI2cSpeedFast, // Fast mode: max 400 kBaud
        .scl_period_nanos           = 1000000/333,      // Slower to meet t_sda_rise
        .sda_fall_nanos             = 300,              // See 24xx1025 datasheet
        .sda_rise_nanos             = 1000              // See 24xx1025 datasheet
    };
    dif_i2c_config_t config;
    CHECK_ELSE_TRAP(dif_i2c_compute_timing(timing_config, &config), kDifI2cOk)
    CHECK_ELSE_TRAP(dif_i2c_configure(&i2c, config), kDifI2cOk)

    // Enable host functionality
    // We do *not* set up any interrupts; traps of any kind should be fatal
    CHECK_ELSE_TRAP(dif_i2c_host_set_enabled(&i2c, kDifI2cToggleEnabled), kDifI2cOk)

    printf("Configured I2C in host mode with a SCL period of %u ns\r\n", timing_config.scl_period_nanos);

    // Init all the INA219s
    for(int i = 0; i < 6; i++){
        xilinx_ina219_init(&i2c, ina219_addresses[i]);
        printf("Initialized INA219 for %s\r\n", ina219_rails[i]);
    }

    while(true){
        unsigned int overall_power = 0;
        for(int i = 0; i < 6; i++){
            int shunt = xilinx_ina219_read_reg(&i2c, ina219_addresses[i], 1);
            int voltage = xilinx_ina219_read_reg(&i2c, ina219_addresses[i], 2);
            int power = xilinx_ina219_read_reg(&i2c, ina219_addresses[i], 3);
            int current = xilinx_ina219_read_reg(&i2c, ina219_addresses[i], 4);
            
            // Correct to uV range
            shunt = shunt*10;

            voltage = (voltage & 0xFFF8) >> 1;

            power = power*10;

            current = current >> 1;

            printf("%s:\r\n", ina219_rails[i]);
            printf("\tShunt Voltage: %d uV\r\n", shunt);
            printf("\tRail Voltage: %d mV\r\n", voltage);
            printf("\tPower: %d mW\r\n", power);
            printf("\tCurrent: %d mA\r\n\r\n", current);

            overall_power += power;
        }

        printf("System Power: %d mW\r\n", overall_power);

        sleep(1000000);
    }

    return 0; 
}

