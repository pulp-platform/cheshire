// Copyright 2023 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Nicole Narr <narrn@student.ethz.ch>
// Christopher Reinwardt <creinwar@student.ethz.ch>
// Paul Scheffler <paulsc@iis.ee.ethz.ch>

#include "regs/cheshire.h"
#include "regs/axi_llc.h"
#include "dif/clint.h"
#include "dif/uart.h"
#include "params.h"
#include "util.h"
#include "printf.h"

#define USE_SPM 0
#define DATA_POINTS 2048

#if USE_SPM
#define SHARED_SECTION __attribute__((section(".spm")))
#else
#define SHARED_SECTION __attribute__((section(".data")))
#endif

typedef unsigned char u8_t;
typedef unsigned int u32_t;
typedef unsigned long u64_t;

_Static_assert(sizeof(u8_t) == 1, "8-bit");
_Static_assert(sizeof(u32_t) == 4, "32-bit");
_Static_assert(sizeof(u64_t) == 8, "64-bit");

static inline unsigned int rdcycle() {
    unsigned int rv;
    asm volatile ("rdcycle %0": "=r" (rv) ::);
    return rv;
}

static inline void fencet(void) { asm volatile (".word 0xfffff00b" ::: "memory"); }
static inline void sfence(void) { asm volatile("sfence.vma" ::: "memory"); }
static inline void ifence(void) { asm volatile("fence.i" ::: "memory"); }

/* set associativity */
#if USE_SPM
#define LLC_NUM_WAYS 7
#else
#define LLC_NUM_WAYS 8
#endif
/* size of 1 way */
#define LLC_WAY_NUM_LINES 256
/* size of one cache line in blocks */
#define LLC_LINE_NUM_BLOCKS 8
/* size of one block in bytes */
#define LLC_BLOCK_NUM_BYTES 8

typedef struct {
    u8_t inner[LLC_LINE_NUM_BLOCKS * LLC_BLOCK_NUM_BYTES];
} line_t;
_Static_assert(sizeof(line_t) == 64, "sizeof line is 64bytes");

line_t data[LLC_NUM_WAYS][LLC_WAY_NUM_LINES]; /* SHARED_SECTION; */
_Static_assert(sizeof(data) == 128 * 1024, "sizeof cache is 128KiB");

struct result {
    u32_t cycle_count;
    u32_t secret;
};

/* The fact this is in the LLC doesn't matter because we flush the cache before
   the spy round, and we write after. */
struct result results[DATA_POINTS];
u32_t current_secret;

volatile void *llc_cfg = (void *)0x03001000;

u32_t random(void) {
    static u32_t state = 0xACE1ACE1;

    /* LFSR with taps are 31, 21, 1, 0*/
    u32_t bit0 = (state >> 0) & 1;
    u32_t bit1 = (state >> 1) & 1;
    u32_t bit2 = (state >> 21) & 1;
    u32_t bit3 = (state >> 31) & 1;

    u32_t feedback = bit3 ^ bit2 ^ bit1 ^ bit0;

    state = ((state << 1) | feedback) & 0xFFFFFFFF;

    return state;
}

void evict_llc(void) {
    *(unsigned int *)(llc_cfg + AXI_LLC_CFG_FLUSH_LOW_REG_OFFSET) = 0xff;
    *(unsigned int *)(llc_cfg + AXI_LLC_COMMIT_CFG_REG_OFFSET) = (1U << AXI_LLC_COMMIT_CFG_COMMIT_BIT);
}

void domain_switch(void) {
    fencet();

    // This should remove the channel.
    // evict_llc();
}


void trojan(void) {
    evict_llc();

    u32_t secret = random() % LLC_WAY_NUM_LINES;

    for (u32_t line = 0; line < secret; line++)  {
        for (u32_t way = 0; way < LLC_NUM_WAYS; way++) {
            line_t *v = &data[way][line];
            volatile u32_t rv;
            asm volatile("lw %0, 0(%1)": "=r" (rv): "r" (v):);
        }
    }

    current_secret = secret;
}

void spy(u32_t round) {
    u32_t before = rdcycle();
    for (u32_t line = 0; line < LLC_WAY_NUM_LINES; line++)  {
        for (u32_t way = 0; way < LLC_NUM_WAYS; way++) {
            line_t *v = &data[way][line];
            volatile u32_t rv;
            asm volatile("lw %0, 0(%1)": "=r" (rv): "r" (v):);
        }
    }
    u32_t after = rdcycle();

    u32_t delta = after - before;

    results[round].cycle_count = delta;
    results[round].secret = current_secret;
}

int main(void) {
    CHECK_ASSERT(-1, chs_hw_feature_present(CHESHIRE_HW_FEATURES_UART_BIT));
    CHECK_ASSERT(-2, chs_hw_feature_present(CHESHIRE_HW_FEATURES_LLC_BIT));

    char str[] = "Hello World!\r\n";
    uint32_t rtc_freq = *reg32(&__base_regs, CHESHIRE_RTC_FREQ_REG_OFFSET);
    uint64_t reset_freq = clint_get_core_freq(rtc_freq, 2500);
    uart_init(&__base_uart, reset_freq, __BOOT_BAUDRATE);
    uart_write_str(&__base_uart, str, sizeof(str) - 1);
    uart_write_flush(&__base_uart);

    printf("text: %p, shared data: %p\r\n", &main, &data);


    /* Turn on the LLC. Leave one way (16KiB) as SPM. */
#if USE_SPM
    *(u32_t *)(llc_cfg + AXI_LLC_CFG_SPM_LOW_REG_OFFSET) = 0x1;
#else
    *(u32_t *)(llc_cfg + AXI_LLC_CFG_SPM_LOW_REG_OFFSET) = 0x0;
#endif
    *(u32_t *)(llc_cfg + AXI_LLC_COMMIT_CFG_REG_OFFSET) = (1U << AXI_LLC_COMMIT_CFG_COMMIT_BIT);

    evict_llc();
    sfence();
    ifence();

    data[0][0].inner[0] = 0xAB;
    if (data[0][0].inner[0] != 0xAB) {
        printf("data sanity check failed\r\n");
        return 1;
    }

    {
        u32_t set_asso = *(u32_t *)(llc_cfg + AXI_LLC_SET_ASSO_LOW_REG_OFFSET);
        if (set_asso != LLC_NUM_WAYS) {
            printf("set associativity does not match; %d\r\n", set_asso);
            return 1;
        }
        u32_t num_lines = *(u32_t *)(llc_cfg + AXI_LLC_NUM_LINES_LOW_REG_OFFSET);
        if (num_lines != LLC_WAY_NUM_LINES) {
            printf("num lines does not match; %d\r\n", num_lines);
            return 1;
        }
        u32_t num_blocks = *(u32_t *)(llc_cfg + AXI_LLC_NUM_BLOCKS_LOW_REG_OFFSET);
        if (num_blocks != LLC_LINE_NUM_BLOCKS) {
            printf("num blocks does not match; %d\r\n", num_blocks);
            return 1;
        }
    }

    evict_llc();

    for (u32_t round = 0; round < DATA_POINTS; round++) {
        if (round % 1000 == 0) {
            printf("1000 points done\r\n");
        }

        trojan();
        domain_switch();
        spy(round);
        domain_switch();
    }

    printf("Done... printing results\r\n");

    for (u32_t i = 0; i < DATA_POINTS; i++) {
        printf("%u %u\r\n", results[i].secret, results[i].cycle_count);
    }

    return 0;
}
