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

typedef struct {
    uint8_t inner[LLC_LINE_NUM_BLOCKS * LLC_BLOCK_NUM_BYTES];
} line_t;
_Static_assert(sizeof(line_t) == 64, "sizeof line is 64bytes");

_Static_assert(sizeof(line_t) * LLC_MAX_NUM_WAYS * LLC_WAY_NUM_LINES == 128 * 1024, "full sizeof cache is 128KiB");

volatile void *llc_cfg = (void *)0x03001000;

#define MANUAL_EVICT 1
#define LLC_ACTIVE_NUM_WAYS 1

#if MANUAL_EVICT
volatile line_t manual_evict_data[LLC_MAX_NUM_WAYS][LLC_WAY_NUM_LINES] SECTION(".dram");
#endif

volatile line_t shared_data[LLC_MAX_NUM_WAYS][LLC_WAY_NUM_LINES] SECTION(".shared_data");


void evict_llc(void) {
#if !MANUAL_EVICT
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

int main(void) {
    CHECK_ASSERT(-1, chs_hw_feature_present(CHESHIRE_HW_FEATURES_UART_BIT));
    CHECK_ASSERT(-2, chs_hw_feature_present(CHESHIRE_HW_FEATURES_LLC_BIT));

    char str[] = "Hello World!\r\n";
    uint32_t rtc_freq = *reg32(&__base_regs, CHESHIRE_RTC_FREQ_REG_OFFSET);
    uint64_t reset_freq = clint_get_core_freq(rtc_freq, 2500);
    uart_init(&__base_uart, reset_freq, __BOOT_BAUDRATE);
    uart_write_str(&__base_uart, str, sizeof(str) - 1);

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

    _Static_assert(LLC_ACTIVE_NUM_WAYS == 1, "num ways is 1");
    *(uint32_t *)(llc_cfg + AXI_LLC_CFG_SPM_LOW_REG_OFFSET) = 0b11111110;
    *(uint32_t *)(llc_cfg + AXI_LLC_COMMIT_CFG_REG_OFFSET) = (1U << AXI_LLC_COMMIT_CFG_COMMIT_BIT);

    evict_llc();

    uint32_t before = rdcycle();
    for (uint32_t line = 0; line < LLC_ACTIVE_NUM_WAYS; line++)  {
        for (uint32_t way = 0; way < LLC_WAY_NUM_LINES; way++) {
            volatile void *v = &shared_data[way][line];
            volatile uint32_t rv;
            asm volatile("lw %0, 0(%1)": "=r" (rv): "r" (v): "memory");
        }
    }
    uint32_t after = rdcycle();

    printf("ΔCycles: %d\r\n", after - before);

    return 0;
}
