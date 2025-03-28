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
#include <stdint.h>

#define DATA_POINTS 1024

#define SECTION(name) __attribute__((__section__(name)))

static inline uint32_t rdcycle() {
    uint32_t rv;
    asm volatile ("rdcycle %0": "=r" (rv) ::);
    return rv;
}

static inline void fencet(void) { asm volatile (".word 0xfffff00b" ::: "memory"); }
static inline void sfence(void) { asm volatile("sfence.vma" ::: "memory"); }
static inline void ifence(void) { asm volatile("fence.i" ::: "memory"); }

/* set associativity */
#define LLC_MAX_NUM_WAYS 8
/* size of 1 way */
#define LLC_WAY_NUM_LINES 256
/* size of one cache line in blocks */
#define LLC_LINE_NUM_BLOCKS 8
/* size of one block in bytes */
#define LLC_BLOCK_NUM_BYTES 8

#define LLC_ACTIVE_NUM_WAYS 1

typedef struct {
    uint8_t inner[LLC_LINE_NUM_BLOCKS * LLC_BLOCK_NUM_BYTES];
} line_t;
_Static_assert(sizeof(line_t) == 64, "sizeof line is 64bytes");

_Static_assert(sizeof(line_t) * LLC_MAX_NUM_WAYS * LLC_WAY_NUM_LINES == 128 * 1024, "full sizeof cache is 128KiB");

#define SHARED_DATA_LINE_ALIGNED 0

#if SHARED_DATA_LINE_ALIGNED
#define SHARED_DATA_NUMBER_WAYS LLC_ACTIVE_NUM_WAYS
#define SHARED_DATA_NUMBER_LINES 32

_Static_assert(SHARED_DATA_NUMBER_WAYS <= LLC_MAX_NUM_WAYS, "less than number");
_Static_assert(SHARED_DATA_NUMBER_LINES <= LLC_WAY_NUM_LINES, "less than number");
/* if number lines != all lines then number ways == 1. */
_Static_assert(!(SHARED_DATA_NUMBER_LINES != LLC_MAX_NUM_WAYS) || SHARED_DATA_NUMBER_WAYS == 1,
               "number lines != all ==> number ways = 1");

volatile line_t data[SHARED_DATA_NUMBER_WAYS][SHARED_DATA_NUMBER_LINES] SECTION(".shared_data");

#else
/* these aren't really ways or lines*/
#define SHARED_DATA_NUMBER_WAYS 1
#define SHARED_DATA_NUMBER_LINES 128

typedef struct { uint64_t inner[1]; } weird_line_t;

/* asid pool is an array of pointers, BIT(7)=128 sized */
volatile weird_line_t data[SHARED_DATA_NUMBER_WAYS][SHARED_DATA_NUMBER_LINES] SECTION(".shared_data");

#endif

_Static_assert(sizeof(data) <= 16 * 1024, "sizeof the data for fitting in SPM is less than one way");

struct result {
    uint32_t cycle_count;
    uint32_t secret;
};

/* The fact this is in the LLC doesn't matter because we flush the cache before
   the spy round, and we write after.
*/
struct result results[DATA_POINTS] SECTION(".results");
uint32_t current_secret;

volatile void *llc_cfg = (void *)0x03001000;

uint32_t random(void) {
    static uint32_t state = 0xACE1ACE1;

    /* LFSR with taps are 31, 21, 1, 0*/
    uint32_t bit0 = (state >> 0) & 1;
    uint32_t bit1 = (state >> 1) & 1;
    uint32_t bit2 = (state >> 21) & 1;
    uint32_t bit3 = (state >> 31) & 1;

    uint32_t feedback = bit3 ^ bit2 ^ bit1 ^ bit0;

    state = ((state << 1) | feedback) & 0xFFFFFFFF;

    return state;
}

#define MANUAL_EVICT 1
#if MANUAL_EVICT
volatile line_t manual_evict_data[LLC_ACTIVE_NUM_WAYS][LLC_WAY_NUM_LINES] SECTION(".dram");
#endif

void evict_llc(void) {
#if !MANUAL_EVICT
    /* This appears to be broken. */
    *(uint32_t *)(llc_cfg + AXI_LLC_CFG_FLUSH_LOW_REG_OFFSET) = 0xff;
    *(uint32_t *)(llc_cfg + AXI_LLC_COMMIT_CFG_REG_OFFSET) = (1U << AXI_LLC_COMMIT_CFG_COMMIT_BIT);
#else
for (uint32_t line = 0; line < LLC_WAY_NUM_LINES; line++)  {
    for (uint32_t way = 0; way < LLC_ACTIVE_NUM_WAYS; way++) {
        volatile void *v = &manual_evict_data[way][line];
        volatile uint32_t rv;
        asm volatile("lw %0, 0(%1)": "=r" (rv): "r" (v): "memory");
    }
}
#endif
}

void domain_switch(void) {
    fencet();

    // This should remove the channel.
    // evict_llc();
}


void trojan(void) {
    evict_llc();

    uint32_t secret = random() % SHARED_DATA_NUMBER_LINES;

    for (uint32_t line = 0; line < secret; line++)  {
        for (uint32_t way = 0; way < SHARED_DATA_NUMBER_WAYS; way++) {
            volatile void *v = &data[way][line];
            volatile uint32_t rv;
            asm volatile("lw %0, 0(%1)": "=r" (rv): "r" (v): "memory");
        }
    }

    current_secret = secret;
}

void spy(uint32_t round) {
    uint32_t before = rdcycle();
    for (uint32_t line = 0; line < SHARED_DATA_NUMBER_LINES; line++)  {
        for (uint32_t way = 0; way < SHARED_DATA_NUMBER_WAYS; way++) {
            volatile void *v = &data[way][line];
            volatile uint32_t rv;
            asm volatile("lw %0, 0(%1)": "=r" (rv): "r" (v): "memory");
        }
    }
    uint32_t after = rdcycle();

    uint32_t delta = after - before;

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

    printf("text: %p, shared data: %p\r\n", &main, &data);

    if ((uintptr_t)&data == 0x0000000010000000) {
        printf("data in SPM... leaving all as SPM\r\n");
        *(uint32_t *)(llc_cfg + AXI_LLC_CFG_SPM_LOW_REG_OFFSET) = 0b11111111;
    } else if ((uintptr_t)&data == 0x0000000080000000) {
        printf("data in DRAM... making one way cache\r\n");
        *(uint32_t *)(llc_cfg + AXI_LLC_CFG_SPM_LOW_REG_OFFSET) = 0b11111110;
        // turn the cache off entirely for testing
        // *(uint32_t *)(llc_cfg + AXI_LLC_CFG_SPM_LOW_REG_OFFSET) = 0b11111111;
    } else {
        printf("data unknown location 0x%p, 0x%p, 0x%p\r\n", &data, &__base_spm, &__base_dram);
        return 1;
    }

    *(uint32_t *)(llc_cfg + AXI_LLC_COMMIT_CFG_REG_OFFSET) = (1U << AXI_LLC_COMMIT_CFG_COMMIT_BIT);

    evict_llc();
    sfence();
    ifence();

    data[0][0].inner[0] = 0xAB;
    if (data[0][0].inner[0] != 0xAB) {
        printf("data sanity check failed\r\n");
        return 1;
    }

    {
        uint32_t set_asso = *(uint32_t *)(llc_cfg + AXI_LLC_SET_ASSO_LOW_REG_OFFSET);
        if (set_asso != LLC_MAX_NUM_WAYS) {
            printf("set associativity does not match; %d\r\n", set_asso);
            return 1;
        }
        uint32_t num_lines = *(uint32_t *)(llc_cfg + AXI_LLC_NUM_LINES_LOW_REG_OFFSET);
        if (num_lines != LLC_WAY_NUM_LINES) {
            printf("num lines does not match; %d\r\n", num_lines);
            return 1;
        }
        uint32_t num_blocks = *(uint32_t *)(llc_cfg + AXI_LLC_NUM_BLOCKS_LOW_REG_OFFSET);
        if (num_blocks != LLC_LINE_NUM_BLOCKS) {
            printf("num blocks does not match; %d\r\n", num_blocks);
            return 1;
        }
    }

    evict_llc();

    for (uint32_t round = 0; round < DATA_POINTS; round++) {
        if (round % 1000 == 0) {
            printf("1000 points done\r\n");
        }

        trojan();
        domain_switch();
        spy(round);
        domain_switch();
    }

    printf("Done... printing results\r\n");

    for (uint32_t i = 0; i < DATA_POINTS; i++) {
        printf("%u %u\r\n", results[i].secret, results[i].cycle_count);
    }

    return 0;
}
