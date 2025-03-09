// Copyright 2023 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Nicole Narr <narrn@student.ethz.ch>
// Christopher Reinwardt <creinwar@student.ethz.ch>
//
// Simple payload to test iDMA with desc64 frontend

#include "regs/cheshire.h"
#include "dif/clint.h"
#include "dif/uart.h"
#include "params.h"
#include "util.h"
#include "regs/idma_desc64.h"
#include "dif/idma_desc64.h"

#define DEBUG
#include "debug.h"

struct descriptor descriptors[10] __attribute__((section(".descriptors")));
bool tx_done;


void setup_transfer(uint64_t src, uint64_t dst, uint32_t len, bool do_irq, bool decouple_rw, struct descriptor *desc) {
    // make sure that bools are only one bit
    do_irq       = do_irq ? 1 : 0;
    decouple_rw  = decouple_rw ? 1 : 0;

    desc->length = len;
    desc->next   = ~0;
    desc->src    = src;
    desc->dst    = dst;

    // flags: id: 0xff, cache: 0, deburst: 0, serialize: 1, decouple_rw: 1bit, incr (src/dst): 0101, irq: 1bit
    desc->flags  = 0xff << 16 | (1 << 6) | (decouple_rw << 5) | (0x5 << 1) | do_irq;
}

void submit_transfer(struct descriptor *desc) {
    tx_done = false;
    debugf("Just before fence\n");
    asm volatile ("fence");
    struct descriptor * volatile* desc_reg = (struct descriptor**)DMA_BASE;
    debugf("Writing...\n");
    *desc_reg = desc;
//    *reg32((void *)DMA_BASE, 0x0) = (uint32_t)desc;
    debugf("After writing\n");
}

void wait_for_transfer(volatile struct descriptor *desc) {
    volatile bool* p_tx_done = &tx_done;
    asm volatile ("fence");
    if (!*p_tx_done) {
        do {
            asm volatile ("nop\n"
                    "nop\n"
                    "nop\n"
                    "nop\n");
            asm volatile ("fence");
        } while (!*p_tx_done &&
                desc->length != 0xFFFFFFFF);
    }
}
void setup_interrupts(void) {
    // set source 8 priority to 3
    ((volatile uint32_t*)0x0c000000)[8] = 3;
    // enable m-mode interrupt 8
    *(volatile uint32_t*)0x0c002000 |= (1 << 8);
    // set interrupt threshold to 0
    *(volatile uint32_t*)0x0c200000 = 0;
}

void trap_handler(uint64_t interrupt_cause) {
    debugf("Got interrupt %ld\n", interrupt_cause);
    uint32_t plic_interrupt = *(volatile uint32_t*)0x0c200004;
    if (plic_interrupt == 8) {
        debugf("Claiming interrupt\n");
        // claim interrupt
        *(volatile uint32_t*)0x0c200004 = 8;
        tx_done = true;
    } else {
        debugf("PLIC interrupt %d\n", plic_interrupt);
    }
}

int main(void) {
    char str[] = "Hello DMA!\r\n";
    uint32_t rtc_freq = *reg32(&__base_regs, CHESHIRE_RTC_FREQ_REG_OFFSET);
    uint64_t reset_freq = clint_get_core_freq(rtc_freq, 2500);
    uart_init(&__base_uart, reset_freq, __BOOT_BAUDRATE);
    uart_write_str(&__base_uart, str, sizeof(str));
    uart_write_flush(&__base_uart);



    uint64_t src = 0xC0FFEEC0DEABBADE;
    uint64_t dst = 0;

    struct descriptor desc;
  
    setup_transfer((uint64_t)&src, (uint64_t)&dst, (uint32_t)sizeof(src), 1, 1, &desc);
    submit_transfer(&desc);
    wait_for_transfer(&desc);

    char str2[] = "Done.\r\n";
    uart_write_str(&__base_uart, str2, sizeof(str2));
    uart_write_flush(&__base_uart);
    return 0;
}
