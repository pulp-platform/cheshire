#pragma once

#include <stdint.h>
#include <stdbool.h>

// Base address of DMA the registers
#define DMA_BASE 0x01000000

struct descriptor {
    uint32_t length;
    uint32_t flags;
    uint64_t next;
    uint64_t src;
    uint64_t dst;
};

extern struct descriptor descriptors[10];
extern bool tx_done;

void setup_transfer(uint64_t src, uint64_t dst, uint32_t len, bool do_irq, bool decouple_rw, struct descriptor *desc);
void submit_transfer(struct descriptor *desc);
void wait_for_transfer(volatile struct descriptor *desc);

void setup_interrupts(void);

