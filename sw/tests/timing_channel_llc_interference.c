// Copyright 2023 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Nicole Narr <narrn@student.ethz.ch>
// Christopher Reinwardt <creinwar@student.ethz.ch>
// Paul Scheffler <paulsc@iis.ee.ethz.ch>

#include "regs/cheshire.h"
#include "regs/axi_llc.h"
#include "regs/tagger.h"
#include "dif/clint.h"
#include "dif/uart.h"
#include "params.h"
#include "util.h"
#include "printf.h"
#include <stdint.h>

#define MITIGATION_NONE     0
#define MITIGATION_COLOUR   1
// TODO.
// #define MITIGATION_SPM      2
#define MITIGATION_DPLLC    3
#define MITIGATION_NO_CACHE 4

#define MITIGATION          MITIGATION_DPLLC

#define DATA_POINTS 1024

#define SPY_COLOUR      0
#define TROJAN_COLOUR   1

#define SECTION(name) __attribute__((__section__(name)))

#define ALIGN(x,a)              __ALIGN_MASK(x,(typeof(x))(a)-1)
#define __ALIGN_MASK(x,mask)    (((x)+(mask))&~(mask))
_Static_assert(ALIGN(0x3, 0x4) == 0x4);

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

#define LLC_ACTIVE_NUM_WAYS 8

typedef struct {
    uint8_t inner[LLC_LINE_NUM_BLOCKS * LLC_BLOCK_NUM_BYTES];
} line_t;
_Static_assert(sizeof(line_t) == 64, "sizeof line is 64bytes");

_Static_assert(sizeof(line_t) * LLC_MAX_NUM_WAYS * LLC_WAY_NUM_LINES == 128 * 1024, "full sizeof cache is 128KiB");

#if MITIGATION != MITIGATION_DPLLC
#define TROJAN_LINES LLC_WAY_NUM_LINES
#define SPY_LINES    LLC_WAY_NUM_LINES
#else
#define DPLLC_PARTITION_0_LINES 8   /* common code/data */
#define DPLLC_PARTITION_1_LINES 120 /* spy */
#define DPLLC_PARTITION_2_LINES 120 /* trojan */
#define DPLLC_PARTITION_3_LINES 8   /* results */

#define SPY_LINES DPLLC_PARTITION_1_LINES
#define TROJAN_LINES DPLLC_PARTITION_2_LINES

_Static_assert(DPLLC_PARTITION_0_LINES + DPLLC_PARTITION_1_LINES + DPLLC_PARTITION_2_LINES + DPLLC_PARTITION_3_LINES <= LLC_WAY_NUM_LINES);
#endif

volatile line_t data_trojan[LLC_ACTIVE_NUM_WAYS][LLC_WAY_NUM_LINES] __attribute__((aligned(0x1000))) SECTION(".bss");
volatile line_t data_spy[LLC_ACTIVE_NUM_WAYS][LLC_WAY_NUM_LINES] __attribute__((aligned(0x1000))) SECTION(".bss");

struct result {
    uint32_t cycle_count;
    uint32_t secret;
};

/* The fact this is in the LLC doesn't matter because we flush the cache before
   the spy round, and we write after.
*/
struct result results[DATA_POINTS] SECTION(".results");
extern void *__results_end;
uint32_t current_secret;

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
#if MITIGATION != MITIGATION_DPLLC
volatile line_t manual_evict_data[LLC_ACTIVE_NUM_WAYS][LLC_WAY_NUM_LINES] __attribute__((aligned(0x1000)));
#else
char manual_evict_end_marker[1];
volatile line_t manual_evict_data_pat2[LLC_ACTIVE_NUM_WAYS][DPLLC_PARTITION_2_LINES] __attribute__((aligned(0x1000)));
volatile line_t manual_evict_data_pat1[LLC_ACTIVE_NUM_WAYS][DPLLC_PARTITION_1_LINES] __attribute__((aligned(0x1000)));
#endif
#endif

static inline int page_colour(uintptr_t addr) {
    return (addr & ((1UL << 12) | (1UL << 13))) >> 12;
}

void evict_llc(void) {
#if !MANUAL_EVICT
    /* This appears to be broken. */
    *reg32(&__base_llc, AXI_LLC_CFG_FLUSH_LOW_REG_OFFSET) = 0xff;
    *reg32(&__base_llc, AXI_LLC_COMMIT_CFG_REG_OFFSET) = (1U << AXI_LLC_COMMIT_CFG_COMMIT_BIT);
#else
#if MITIGATION != MITIGATION_DPLLC
for (uint32_t line = 0; line < LLC_WAY_NUM_LINES; line++)  {
    for (uint32_t way = 0; way < LLC_ACTIVE_NUM_WAYS; way++) {
        volatile void *v = &manual_evict_data[way][line];
        volatile uint32_t rv;
        asm volatile("lw %0, 0(%1)": "=r" (rv): "r" (v): "memory");
    }
}
#else /* is DPLLC */
    for (uint32_t line = 0; line < DPLLC_PARTITION_1_LINES; line++)  {
        for (uint32_t way = 0; way < LLC_ACTIVE_NUM_WAYS; way++) {
            volatile void *v = &manual_evict_data_pat1[way][line];
            volatile uint32_t rv;
            asm volatile("lw %0, 0(%1)": "=r" (rv): "r" (v): "memory");
        }
    }
    for (uint32_t line = 0; line < DPLLC_PARTITION_2_LINES; line++)  {
        for (uint32_t way = 0; way < LLC_ACTIVE_NUM_WAYS; way++) {
            volatile void *v = &manual_evict_data_pat2[way][line];
            volatile uint32_t rv;
            asm volatile("lw %0, 0(%1)": "=r" (rv): "r" (v): "memory");
        }
    }
#endif
#endif
}

void domain_switch(void) {
    fencet();

    // This should remove the channel.
    // evict_llc();
}


void trojan(void) {
    uint32_t secret = random() % TROJAN_LINES;

    for (uint32_t line = 0; line < secret; line++)  {
        for (uint32_t way = 0; way < LLC_ACTIVE_NUM_WAYS; way++) {
            volatile void *v = &data_trojan[way][line];
            volatile uint32_t rv;
#if MITIGATION == MITIGATION_COLOUR
            if (page_colour((uintptr_t)v) != TROJAN_COLOUR) continue;
#endif
            asm volatile("lw %0, 0(%1)": "=r" (rv): "r" (v): "memory");
        }
    }

    current_secret = secret;
}

void spy(uint32_t round) {
    uint32_t before = rdcycle();
    for (uint32_t line = 0; line < SPY_LINES; line++)  {
        for (uint32_t way = 0; way < LLC_ACTIVE_NUM_WAYS; way++) {
            volatile void *v = &data_spy[way][line];
            volatile uint32_t rv;
#if MITIGATION == MITIGATION_COLOUR
            if (page_colour((uintptr_t)v) != SPY_COLOUR) continue;
#endif
            asm volatile("lw %0, 0(%1)": "=r" (rv): "r" (v): "memory");
        }
    }
    uint32_t after = rdcycle();

    uint32_t delta = after - before;

    results[round].cycle_count = delta;
    results[round].secret = current_secret;
}

#if MITIGATION == MITIGATION_DPLLC
int setup_dpllc() {
    /* the transaction tagger registers are (somewhat) similar to that of the
       RISC-V PMP registers.

       "tagger_patid" module says "Take a page from testbench of axi-io-pmp pmp_entry.sv"

       see tagger/README.md for the registers.

       we setup two regions covering the spy & trojan registers.

       XXX: ??? how to do rest?


       if none match then partId = 0. see patid_r in tagger.sv


        // how HW generates the table.
        if (tagger_reg2hw.pat_commit[0].q) begin
            for (int unsigned k = 0; k < MAXPARTITION; k++) begin
                // shift the corresponding patid and conf to the LSB position
                patid_temp = (patid_table >> (PATID_LEN * k));
                conf_temp = (conf_table >> (2 * k));
                // 4-byte default size
                tag_tab_d[k].addr[33:2] = tagger_reg2hw.pat_addr[k].q[31:0];
                // read the LSB position patid and conf out
                tag_tab_d[k].patid = patid_temp[PATID_LEN-1:0];
                tag_tab_d[k].conf = conf_temp[1:0];
            end



        See axi_llc_config_pat.sv
            for CfgFlushPartition CommitPartitionCfg FlushedSet

    */

    /* Sanity check that it is connected */
    uint32_t commit_val = *reg32(&__base_tagger, TAGGER_REG_PAT_COMMIT_REG_OFFSET);
    if (commit_val != 0) {
        printf("commit val was zero (maybe 0xdeadc0de disconnected?) 0x%x\r\n", commit_val);
        return 1;
    }

#define LLC_MAXPARTITION 16
    /* 16 regions. (=MAXPARTITION) */
#define TAGGER_NUM_REGIONS LLC_MAXPARTITION
/* I think this is right? */
// ySE: xilinx/build/cheshire.genesys2.log:1718:        Parameter PATID_LEN bound to: 32'b00000000000000000000000000000101
// Nils: This *should* be log2(LLC_MAXPARTITION)
#define TAGGER_PATID_LEN 4
    // static const uint32_t TAGGER_NUM_REGIONS = 16;

#define TAGGER_REG_PAT_ADDR_N_REG_OFFSET(n)                                    \
    (TAGGER_REG_PAT_ADDR_0_REG_OFFSET +                                        \
     (TAGGER_REG_PAT_ADDR_1_REG_OFFSET - TAGGER_REG_PAT_ADDR_0_REG_OFFSET) * (n))

#define TAGGER_REG_PATID_N_REG_OFFSET(n)                                    \
    (TAGGER_REG_PATID_0_REG_OFFSET +                                        \
     (TAGGER_REG_PATID_1_REG_OFFSET - TAGGER_REG_PATID_0_REG_OFFSET) * (n))

    _Static_assert(TAGGER_REG_PAT_ADDR_N_REG_OFFSET(0) == TAGGER_REG_PAT_ADDR_0_REG_OFFSET);
    _Static_assert(TAGGER_REG_PAT_ADDR_N_REG_OFFSET(7) == TAGGER_REG_PAT_ADDR_7_REG_OFFSET);
    _Static_assert(TAGGER_REG_PAT_ADDR_N_REG_OFFSET(15) == TAGGER_REG_PAT_ADDR_15_REG_OFFSET);

    _Static_assert(TAGGER_REG_PATID_N_REG_OFFSET(0) == TAGGER_REG_PATID_0_REG_OFFSET);
    _Static_assert(TAGGER_REG_PATID_N_REG_OFFSET(2) == TAGGER_REG_PATID_2_REG_OFFSET);


#define TAGGER_DEBUG 1
// #define TAGGER_DEBUG 0

#if TAGGER_DEBUG
    for (uint32_t n = 0; n < TAGGER_REG_PAT_ADDR_MULTIREG_COUNT; n++) {
        printf("TAGGER_REG_PAT_ADDR_%u_REG: 0x%x\r\n", n,
               *reg32(&__base_tagger, TAGGER_REG_PAT_ADDR_N_REG_OFFSET(n)));
    }
    printf("\r\n");
    for (uint32_t n = 0; n < TAGGER_REG_PATID_MULTIREG_COUNT; n++) {
        printf("TAGGER_REG_PATID_%u_REG: 0x%x\r\n", n,
               *reg32(&__base_tagger, TAGGER_REG_PATID_N_REG_OFFSET(n)));
    }
    printf("\r\n");
    printf("TAGGER_REG_ADDR_CONF_REG: 0x%x\r\n",
           *reg32(&__base_tagger, TAGGER_REG_ADDR_CONF_REG_OFFSET));
#endif

    enum TaggerAddrConf {
        /* OFF (no tagging) */
        // XX: Is this basically 0?
        TaggerAddrConf_Off = 0b00,
        /* TOR (top of range) */
        TaggerAddrConf_TOR = 0b01,
        /* NA4 (naturally aligned four-byte region) */
        TaggerAddrConf_NA4 = 0b10,
        /* NAPOT (naturally aligned power-of-two-region >= 8 bytes) */
        TaggerAddrConf_NAPOT = 0b11,
    };

    struct tagger_region {
        /* actually should be >32 bits?? IDK??? where does the size come in. */
        union {
            uint32_t addr;
            // struct {
                // uint32_t paddr;
                // uint32_t size;
            // };
        };
        enum TaggerAddrConf conf;
         /* actually 4 bits */
        uint8_t patid;
    };

    /* for some reason can't be static. */
    const struct tagger_region region_configs[TAGGER_NUM_REGIONS] = {
        /* (unused): TOR prev implicitly starts @ 0 */

        // this table talks in terms of the *end* of the range whereas we get the *start*.

        /* start of dram is 0x8000'0000. this is purely a marker. */
        [ 0] = { .addr = 0x80000000, .conf = TaggerAddrConf_Off },
        /* .text segment starts at 0x8000'0000 and any other data here too.
            belongs to partition 0.

            it ends (conceptually) at the spy data region.
        */
        [ 1] = { .addr = (uintptr_t)&data_spy, .conf = TaggerAddrConf_TOR, .patid = 0 },
        /* the spy region ends when the trojan region starts.
           belongs to partition 1.
        */
        [ 2] = { .addr = (uintptr_t)&data_trojan, .conf = TaggerAddrConf_TOR, .patid = 1 },
        /* the trojan region ends when the manual evict data starts
            belongs to partition 2.
        */
        [ 3] = { .addr = (uintptr_t)&manual_evict_data_pat1, .conf = TaggerAddrConf_TOR, .patid = 2 },
        /* the manual evict data (partition 1) ends when the data for partition 2 starts.
            it obviously belongs to partition 1.
        */
        [ 4] = { .addr = (uintptr_t)&manual_evict_data_pat2, .conf = TaggerAddrConf_TOR, .patid = 1 },
        /* the manual evict data (partition 2) ends at the marker
            belongs to partition 2. */
        [ 5] = { .addr = (uintptr_t)&manual_evict_end_marker, .conf = TaggerAddrConf_TOR, .patid = 2 },
        /* then everything else in .bss is partition 0 (common)
           up to the start of results.
        */
        [ 6] = { .addr = (uintptr_t)&results, .conf = TaggerAddrConf_TOR, .patid = 0 },
        /* then results lives in partition 3. */
        [ 7] = { .addr = (uintptr_t)&__results_end, .conf = TaggerAddrConf_TOR, .patid = 3 },
        /* then the rest of memory (assumed: 8MiB) is left in partition 0 */
        [ 8] = { .addr = 0x80800000, .conf = TaggerAddrConf_TOR, .patid = 0 },
        /* then the rest of the physical address range is left unspecified. */
        [ 9] = { .conf = TaggerAddrConf_Off },
        [10] = { .conf = TaggerAddrConf_Off },
        [11] = { .conf = TaggerAddrConf_Off },
        [12] = { .conf = TaggerAddrConf_Off },
        [13] = { .conf = TaggerAddrConf_Off },
        [14] = { .conf = TaggerAddrConf_Off },
        [15] = { .conf = TaggerAddrConf_Off },
    };

    /* make sure that the data_ and the eviction data is contiguous as we rely on it */
    CHECK_ASSERT(-7, (ALIGN(((uintptr_t)&data_trojan) + sizeof(data_trojan), 0x1000) == ((uintptr_t)&manual_evict_data_pat1)));

    for (uint32_t k = 0; k < TAGGER_NUM_REGIONS; k++) {
        uint32_t addr = region_configs[k].addr;
        uint32_t prev_addr = (k == 0) ? 0 : region_configs[k - 1].addr;

        if (region_configs[k].conf == TaggerAddrConf_Off) continue;
        if (prev_addr >= addr) {
            printf("memory layout ordering in the region_configs is wrong: "
                   "partition %d has addr 0x%x whereas previous was 0x%x\r\n",
                   k, addr, prev_addr);
            return -21;
        }
    }

    printf("configuring regions...\r\n");
    for (uint32_t region = 0; region < TAGGER_NUM_REGIONS; region++) {
        const struct tagger_region *config = &region_configs[region];

        printf("configuring region %d with addr reg 0x%x, config: %d, patid: %d\r\n",
               region, config->addr, config->conf, config->patid);

        // Store address right-shifted by 2 (4-byte granularity)
        *reg32(&__base_tagger, TAGGER_REG_PAT_ADDR_N_REG_OFFSET(region)) = config->addr >> 2;

        /* This is essentially a 32-bit integer interpreted as an array of 2-bit values.
           region 0 maps to bits {0, 1}, region k to bits {2k, 2k+1}, region 15 to {30, 31}.
        */
        uint32_t addr_conf = *reg32(&__base_tagger, TAGGER_REG_ADDR_CONF_REG_OFFSET);
        /* assert it fits within 32 bits. */
        _Static_assert(TAGGER_REG_PARAM_REG_WIDTH == 32);
        CHECK_ASSERT(-1, (2 * region + 1) <= TAGGER_REG_PARAM_REG_WIDTH);
        addr_conf &= ~(BIT(2 * region) | BIT(2 * region + 1));
        CHECK_ASSERT(-2, (0b00 <= config->conf) && (config->conf <= 0b11));
        addr_conf |= (config->conf << (2 * region));
        *reg32(&__base_tagger, TAGGER_REG_ADDR_CONF_REG_OFFSET) = addr_conf;

        /* PATID is mapped across several registers:
            so region 0 is bits [0, 3]
            and region k is bits [4 * k, 4 * (k + 1) - 1]

            each register is 32 bit words, so if both of them fall in the same 32 bits it's easy
        */
        _Static_assert(TAGGER_REG_PARAM_REG_WIDTH == 32);
        /* fits in 4 bits */
        CHECK_ASSERT(-3, (0b00 <= config->patid) && (config->patid <= 0b1111));
        uint32_t lower_bit = TAGGER_PATID_LEN * region;
        uint32_t upper_bit = TAGGER_PATID_LEN * (region + 1) - 1;
        if ((lower_bit / 32) == (upper_bit / 32)) {
            uint32_t mask = BIT_MASK(TAGGER_PATID_LEN) << (lower_bit % 32);
            uint32_t v = *reg32(&__base_tagger, TAGGER_REG_PATID_N_REG_OFFSET(lower_bit / 32));
            v &= ~mask;
            v |= (config->patid) << (lower_bit % 32);
            *reg32(&__base_tagger, TAGGER_REG_PATID_N_REG_OFFSET(lower_bit / 32)) = v;
        } else {
            /* In this case it looks like     [32 bit word 1]   [32 bit word 2]
                                                          ^^     ^^^
            */
            uint32_t lower_bit_count = 32 - (lower_bit % 32);
            CHECK_ASSERT(-12, lower_bit_count < 5);
            uint32_t lower_mask = BIT_MASK(lower_bit_count) << (lower_bit % 32);
            uint32_t lower_v = *reg32(&__base_tagger, TAGGER_REG_PATID_N_REG_OFFSET(lower_bit / 32));
            lower_v &= ~lower_mask;
            lower_v |= (config->patid & BIT_MASK(lower_bit_count)) << (lower_bit % 32);
            *reg32(&__base_tagger, TAGGER_REG_PATID_N_REG_OFFSET(lower_bit / 32)) = lower_v;


            uint32_t upper_bit_count = (upper_bit % 32) + 1;
            printf("lower bit count: %d, upper bit count: %d\r\n", lower_bit_count, upper_bit_count);
            printf("lower bit: %d, upper bit: %d\r\n", lower_bit, upper_bit);
            CHECK_ASSERT(-13, upper_bit_count < 5);
            CHECK_ASSERT(-14, upper_bit_count + lower_bit_count == 5);
            uint32_t upper_mask = BIT_MASK(upper_bit_count); /* no shift, starts from 0 */
            uint32_t upper_v = *reg32(&__base_tagger, TAGGER_REG_PATID_N_REG_OFFSET(upper_bit / 32));
            upper_v &= ~upper_mask;
            upper_v |= ((config->patid >> lower_bit_count) & BIT_MASK(upper_bit_count)); /* no shift, starts from 0 */
            *reg32(&__base_tagger, TAGGER_REG_PATID_N_REG_OFFSET(upper_bit / 32)) = upper_v;
        }
    }

    // XXX: Is only the COMMIT_0 bit for all? => I think so.
    /* Commit.*/
    *reg32(&__base_tagger, TAGGER_REG_PAT_COMMIT_REG_OFFSET) = BIT(TAGGER_REG_PAT_COMMIT_COMMIT_0_BIT);

#if TAGGER_DEBUG
    for (uint32_t n = 0; n < TAGGER_REG_PAT_ADDR_MULTIREG_COUNT; n++) {
        printf("TAGGER_REG_PAT_ADDR_%u_REG: 0x%x\r\n", n,
               *reg32(&__base_tagger, TAGGER_REG_PAT_ADDR_N_REG_OFFSET(n)));
    }
    printf("\r\n");
    for (uint32_t n = 0; n < TAGGER_REG_PATID_MULTIREG_COUNT; n++) {
        printf("TAGGER_REG_PATID_%u_REG: 0x%x\r\n", n,
               *reg32(&__base_tagger, TAGGER_REG_PATID_N_REG_OFFSET(n)));
    }
    printf("\r\n");
    printf("TAGGER_REG_ADDR_CONF_REG: 0x%x\r\n",
           *reg32(&__base_tagger, TAGGER_REG_ADDR_CONF_REG_OFFSET));
#endif

    /* Whoever designed these registers. Why
        Laid out in memory like

        [Low1][Low2][Low3][Hi1][Hi2][Hi3]

        rather than [Low1][Hi1][Low2][Hi2]

        Just. why.


        See axi_llc_config_pat.sv


    */

    /// For example, if Cfg.NumLines=256, FlushedSet[0] is responsible for set #0-63, FlushedSet[1] is responsible
    /// for set 64-127, FlushedSet[2] is responsible for set 128-191, FlushedSet[3] is responsible for set 192-255.
    /* This shows whether the sets have been flushed. */
    printf("AXI_LLC_FLUSHED_SET_LOW_0_REG: %x\r\n",
           *reg32(&__base_llc, AXI_LLC_FLUSHED_SET_LOW_0_REG_OFFSET));
    printf("AXI_LLC_FLUSHED_SET_HIGH_0_REG: %x\r\n",
           *reg32(&__base_llc, AXI_LLC_FLUSHED_SET_HIGH_0_REG_OFFSET));
    printf("AXI_LLC_FLUSHED_SET_LOW_1_REG: %x\r\n",
           *reg32(&__base_llc, AXI_LLC_FLUSHED_SET_LOW_1_REG_OFFSET));
    printf("AXI_LLC_FLUSHED_SET_HIGH_1_REG: %x\r\n",
           *reg32(&__base_llc, AXI_LLC_FLUSHED_SET_HIGH_1_REG_OFFSET));
    printf("AXI_LLC_FLUSHED_SET_LOW_2_REG: %x\r\n",
           *reg32(&__base_llc, AXI_LLC_FLUSHED_SET_LOW_2_REG_OFFSET));
    printf("AXI_LLC_FLUSHED_SET_HIGH_2_REG: %x\r\n",
           *reg32(&__base_llc, AXI_LLC_FLUSHED_SET_HIGH_2_REG_OFFSET));
    printf("AXI_LLC_FLUSHED_SET_LOW_3_REG: %x\r\n",
           *reg32(&__base_llc, AXI_LLC_FLUSHED_SET_LOW_3_REG_OFFSET));
    printf("AXI_LLC_FLUSHED_SET_HIGH_3_REG: %x\r\n",
           *reg32(&__base_llc, AXI_LLC_FLUSHED_SET_HIGH_3_REG_OFFSET));

    /// For example, if MaxPartition=12 and Cfg.NumLines=512, CfgSetPartition[0][8:0] defines pat0 size,
    /// CfgSetPartition[0][17:9] defines pat1 size, ...,  CfgSetPartition[0][62:54] defines pat6 size,
    /// CfgSetPartition[0][63] is reserved. CfgSetPartition[1][8:0] defines pat7 size, ..., CfgSetPartition[1][44:36]
    /// defines pat11 size, CfgSetPartition[1][63:37] is reserved.

#define AXI_LLC_CFG_SET_PARTITION_LOW_N_REG_OFFSET(n)                          \
    (AXI_LLC_CFG_SET_PARTITION_LOW_0_REG_OFFSET +                              \
     (AXI_LLC_CFG_SET_PARTITION_LOW_1_REG_OFFSET -                             \
      AXI_LLC_CFG_SET_PARTITION_LOW_0_REG_OFFSET) *                            \
         (n))

    _Static_assert(AXI_LLC_CFG_SET_PARTITION_LOW_N_REG_OFFSET(0) == AXI_LLC_CFG_SET_PARTITION_LOW_0_REG_OFFSET);
    _Static_assert(AXI_LLC_CFG_SET_PARTITION_LOW_N_REG_OFFSET(1) == AXI_LLC_CFG_SET_PARTITION_LOW_1_REG_OFFSET);

#define AXI_LLC_CFG_SET_PARTITION_HIGH_N_REG_OFFSET(n)                          \
    (AXI_LLC_CFG_SET_PARTITION_HIGH_0_REG_OFFSET +                              \
     (AXI_LLC_CFG_SET_PARTITION_HIGH_1_REG_OFFSET -                             \
      AXI_LLC_CFG_SET_PARTITION_HIGH_0_REG_OFFSET) *                            \
         (n))

    _Static_assert(AXI_LLC_CFG_SET_PARTITION_HIGH_N_REG_OFFSET(0) == AXI_LLC_CFG_SET_PARTITION_HIGH_0_REG_OFFSET);
    _Static_assert(AXI_LLC_CFG_SET_PARTITION_HIGH_N_REG_OFFSET(1) == AXI_LLC_CFG_SET_PARTITION_HIGH_1_REG_OFFSET);


    /* $clog(NumLines) = $clog(256) = 8. */
#define PARTITION_SET_SIZE_BITS 8
    _Static_assert(BIT(PARTITION_SET_SIZE_BITS) == LLC_WAY_NUM_LINES);
    /* Since MaxPartition=16 then CfgSetPartition[0][7:0] (low32) defines pat0
                                  CfgSetPartition[0][31:24] (low32) defines pat3
                                  CfgSetPartition[0][39:32] (hi32) defines pat4
                                  CfgSetPartition[0][63:56] (hi32) defines pat7
                                  CfgSetPartition[1][7:0] (low32) defines pat8
                                  etc
    */

    // XXX: How is this handled by default? all partitions are 0 sized? => YES.
    /*
            "If a partition's size is 0, the entry will be put into the shared region"
            "If the patid is larger than the table supported, assign it to the shared region"

        axi_llc stores a partition_table of [MaxPartition:0] i.e. MaxPartition + 1 entiries
        the top entry is the "shared region"; which is share_index and share_size.

                assign share_size  =  partition_table_i[MaxPartition].NumIndex;
                assign share_index =  partition_table_i[MaxPartition].StartIndex;
                assign pat_size    =  (curr_chan_i.user <= MaxPartition) ? partition_table_i[curr_chan_i.user].NumIndex : share_size;
                assign start_index =  (curr_chan_i.user <= MaxPartition) ? partition_table_i[curr_chan_i.user].StartIndex : share_index;


            /// Partition table which tells the range of indice assigned to each partition:
            /// The number of entry in partition_table is one more than MaxPartition because it needs to hold
            /// the remaining part as shared region for any other partition that has not been allocated.
            /// If the entry is 0, then it means that the partition uses the shared region of cache.
            /// When we process data access of such partition, we should look up partition_table_o[MaxPartition]
            /// for hit/miss information.

        partition_table_o[MaxPartition].StartIndex = partition_table_o[MaxPartition-1].StartIndex + partition_table_o[MaxPartition-1].NumIndex;
        partition_table_o[MaxPartition].NumIndex = Cfg.NumLines - partition_table_o[MaxPartition].StartIndex;


        Seems like the "shared region" is defined as the remaining lines of the cache not allocated to other partitions.

        If there's no remaining, i.e. NumIndex = 0, then:

            assign aw_bypass = (slv_aw_partition_id_i == flush_set_partition_q) ||
                              ((!partition_table_o[slv_aw_partition_id_i].NumIndex) && (flush_set_partition_q == MaxPartition)) ||
                              (flush_set_partition_q == (MaxPartition + 1));
            assign ar_bypass = (slv_ar_partition_id_i == flush_set_partition_q) ||
                              ((!partition_table_o[slv_ar_partition_id_i].NumIndex) && (flush_set_partition_q == MaxPartition)) ||
                              (flush_set_partition_q == (MaxPartition + 1));

        I think this means it bypasses the cache entirely.

        EDIT: NO, that seems wrong....
            see reworked3 test and then reworked-pat0=32,pat1=96,pat2=96.

     */

    /* Since we have 256 lines, having pat1 and pat2 use 128 lines means that
       anything in partition 0 (or any others) should bypass the cache and
       just go directly to memory.
       This is good for our purposes.
    */
    static const uint32_t partition_set_sizes[LLC_MAXPARTITION] = {
        [ 0] = DPLLC_PARTITION_0_LINES,
        [ 1] = DPLLC_PARTITION_1_LINES,
        [ 2] = DPLLC_PARTITION_2_LINES,
        [ 3] = DPLLC_PARTITION_3_LINES,
        [ 4] = 0,
        [ 5] = 0,
        [ 6] = 0,
        [ 7] = 0,
        [ 8] = 0,
        [ 9] = 0,
        [10] = 0,
        [11] = 0,
        [12] = 0,
        [13] = 0,
        [14] = 0,
        [15] = 0,
    };

    uint32_t lo_bit = 0;
    uint32_t reg_no = 0;
    for (uint32_t partition = 0; partition < LLC_MAXPARTITION; partition++) {
        uint32_t hi_bit = lo_bit + 7; // inclusive upper end.
        CHECK_ASSERT(-5, hi_bit <= 63);
        CHECK_ASSERT(-6, reg_no <= AXI_LLC_CFG_SET_PARTITION_HIGH_MULTIREG_COUNT);

        uint32_t reg_lo = *reg32(&__base_llc, AXI_LLC_CFG_SET_PARTITION_LOW_N_REG_OFFSET(reg_no));
        uint32_t reg_hi = *reg32(&__base_llc, AXI_LLC_CFG_SET_PARTITION_HIGH_N_REG_OFFSET(reg_no));
        uint64_t reg = reg_lo | ((uint64_t)reg_hi << 32);
        uint64_t old_reg = reg;

        uint32_t size = partition_set_sizes[partition];
        printf("partition %d is reg %d bits %d..%d (size: %x, orig value: %016lx)\r\n", partition, reg_no, lo_bit, hi_bit, size, reg);

        uint64_t mask = ((uint64_t)BIT_MASK(PARTITION_SET_SIZE_BITS)) << (lo_bit);
        reg &= ~mask;
        CHECK_ASSERT(-6, size < BIT(PARTITION_SET_SIZE_BITS));
        reg |= ((uint64_t)size) << lo_bit;

        reg_lo = reg & BIT_MASK(32);
        reg_hi = (reg >> 32) & BIT_MASK(32);

        *reg32(&__base_llc, AXI_LLC_CFG_SET_PARTITION_LOW_N_REG_OFFSET(reg_no)) = reg_lo;
        *reg32(&__base_llc, AXI_LLC_CFG_SET_PARTITION_HIGH_N_REG_OFFSET(reg_no)) = reg_hi;

        if (reg != old_reg) {
            printf("-> new value: %016lx\r\n", reg);
        }

        lo_bit += 8;
        if (lo_bit >= 64) {
            lo_bit = 0;
            reg_no += 1;
        }
    }

    printf("committing changes\r\n");

    /* Commit changes to CfgSetPartition */
    *reg32(&__base_llc, AXI_LLC_COMMIT_PARTITION_CFG_REG_OFFSET) = BIT(AXI_LLC_COMMIT_PARTITION_CFG_COMMIT_BIT);

    return 0;
}
#endif

int main(void) {
    CHECK_ASSERT(-1, chs_hw_feature_present(CHESHIRE_HW_FEATURES_UART_BIT));
    CHECK_ASSERT(-2, chs_hw_feature_present(CHESHIRE_HW_FEATURES_LLC_BIT));

    char str[] = "Hello World!\r\n";
    uint32_t rtc_freq = *reg32(&__base_regs, CHESHIRE_RTC_FREQ_REG_OFFSET);
    uint64_t reset_freq = clint_get_core_freq(rtc_freq, 2500);
    uart_init(&__base_uart, reset_freq, __BOOT_BAUDRATE);
    uart_write_str(&__base_uart, str, sizeof(str) - 1);

    printf("text: %p, trojan data: %p, spy data %p\r\n", &main, &data_trojan, &data_spy);

    // IMPORTANT: cheshire starts with it all disabled.
#if MITIGATION != MITIGATION_NO_CACHE
    /* no ways SPM */
    *reg32(&__base_llc, AXI_LLC_CFG_SPM_LOW_REG_OFFSET) = 0b00000000;
#else /* is no cache */
    *reg32(&__base_llc, AXI_LLC_CFG_SPM_LOW_REG_OFFSET) = 0b11111111;
#endif
    /* leave 1 way for SPM for code. */
    // *reg32(&__base_llc, AXI_LLC_CFG_SPM_LOW_REG_OFFSET) = 0b00000001;
    // turn the cache off entirely for testing
    // *reg32(&__base_llc, AXI_LLC_CFG_SPM_LOW_REG_OFFSET) = 0b11111111;
    *reg32(&__base_llc, AXI_LLC_COMMIT_CFG_REG_OFFSET) = BIT(AXI_LLC_COMMIT_CFG_COMMIT_BIT);

#if MITIGATION == MITIGATION_DPLLC
    int ret = setup_dpllc();
    if (ret) {
        printf("dpllc setup failed (code: %d)\r\n", ret);
        return ret;
    };
#endif

    printf("evicting\r\n");
    evict_llc();
    printf("fencing\r\n");
    sfence();
    ifence();

    data_trojan[0][0].inner[0] = 0xAB;
    if (data_trojan[0][0].inner[0] != 0xAB) {
        printf("data sanity check failed\r\n");
        return 1;
    }

    data_spy[0][0].inner[0] = 0xAB;
    if (data_spy[0][0].inner[0] != 0xAB) {
        printf("data sanity check failed\r\n");
        return 1;
    }


    {
        uint32_t set_asso = *reg32(&__base_llc, AXI_LLC_SET_ASSO_LOW_REG_OFFSET);
        if (set_asso != LLC_MAX_NUM_WAYS) {
            printf("set associativity does not match; %d\r\n", set_asso);
            return 1;
        }
        uint32_t num_lines = *reg32(&__base_llc, AXI_LLC_NUM_LINES_LOW_REG_OFFSET);
        if (num_lines != LLC_WAY_NUM_LINES) {
            printf("num lines does not match; %d\r\n", num_lines);
            return 1;
        }
        uint32_t num_blocks = *reg32(&__base_llc, AXI_LLC_NUM_BLOCKS_LOW_REG_OFFSET);
        if (num_blocks != LLC_LINE_NUM_BLOCKS) {
            printf("num blocks does not match; %d\r\n", num_blocks);
            return 1;
        }
    }

    // Initial prime
    spy(0);

    for (uint32_t round = 0; round < DATA_POINTS; round++) {
        if (round % 1000 == 0) {
            printf("%d points done\r\n", round);
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

    printf("QED\r\n");

    while (1);

    return 0;
}
