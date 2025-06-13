// Copyright (c) 2024 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0/
//
// Authors:
// - Philippe Sauter <phsauter@iis.ee.ethz.ch>

#include "dif/uart.h"
#include "printf.h"
#include "dif/util.h"

#include "dif/sdmmcvar.h"
#include "dif/sdhcvar.h"

#include "regs/cheshire.h"
#include "params.h"

#define SDHCI_BASE_ADDR 0x0300a000

struct sdmmc_softc sc = { 0 };
struct sdhc_host hp = { 0 };

static unsigned int s_Seed = 1;
unsigned int rand(void) {
    s_Seed = s_Seed * 1103515245 + 12345;
    return s_Seed;
}

#define SIZE     512
#define BLOCKS   5
static u_char scratch[SIZE * BLOCKS] = { 0 };
_Static_assert(sizeof(scratch) >= 512, "Scratch buffer needs to be atleast 512bytes");

int test_rw(int size, unsigned int seed) {
    printf("Running read write test with size %d and seed %x\n", size, seed);

    bzero((void*) scratch, size);

    // Reset Block
    ASSERT_OK(sdmmc_mem_write_block(&sc.sc_card, 0, scratch, size));

    memset((void*) scratch, 0xFF, size);

    ASSERT_OK(sdmmc_mem_read_block(&sc.sc_card, 0, scratch, size));

    int err = 0;
    for (size_t i = 0; i < size; ++i) {
        if (scratch[i] != 0) {
            printf("scratch[%d] not as expected, should be zeroed, got %x\n", i, scratch[i]);
            err = 1;
        }
    }
    if (err) return 1;


    s_Seed = seed;
    for (size_t i = 0; i < size; ++i) scratch[i] = rand();

    ASSERT_OK(sdmmc_mem_write_block(&sc.sc_card, 0, scratch, size));

    memset((void*) scratch, 0xFF, size);

    ASSERT_OK(sdmmc_mem_read_block(&sc.sc_card, 0, scratch, size));

    s_Seed = seed;
    for (size_t i = 0; i < size; ++i) {
        char exp = rand();
        if (scratch[i] != exp) {
            printf("scratch[%d] not as expected, should be %x, got %x\n", i, exp, scratch[i]);
            err = 1;
        }
    }
    if (err) return 1;

    printf("Succesfuly ran read write test\n");

    return 0;
}

int main() {
    uint32_t rtc_freq = *reg32(&__base_regs, CHESHIRE_RTC_FREQ_REG_OFFSET);
    uint64_t reset_freq = clint_get_core_freq(rtc_freq, 2500);
    uart_init(&__base_uart, reset_freq, 1000000);
    
    printf("Hello world!\n");


#ifdef SDHC_DEBUG
    debug_funcs = 0;
    sdhcdebug = 0;
#endif


ASSERT_OK(sdhc_init(&hp, SDHCI_BASE_ADDR, 0, 0));

#ifdef WITH_SD_MODEL
    ASSERT_OK(sdhc_bus_width(&hp, 4));
#endif

#ifdef SDHC_INITIALIZED_MODEL
    sc.sc_caps = SMC_CAPS_4BIT_MODE | SMC_CAPS_AUTO_STOP | SMC_CAPS_NONREMOVABLE;
    sc.sc_flags = SMF_SD_MODE | SMF_MEM_MODE | SMF_CARD_PRESENT | SMF_CARD_ATTACHED;
    sc.sch = &hp;

    sc.sc_card.sc = &sc;
    sc.sc_card.rca = 1;
    sc.sc_card.csd.capacity = 20000000;
    sc.sc_card.csd.sector_size = SIZE;

#else
    sdmmc_init(&sc, &hp, scratch);
    if (!ISSET(sc.sc_flags, SMF_CARD_ATTACHED)) {
        printf("Failed to initialize SD Card\n");
        return 1;
    }
#endif

    ASSERT_OK(sdhc_bus_clock(sc.sch, SDMMC_SDCLK_50MHZ, SDMMC_TIMING_LEGACY));

#ifdef WITH_SD_MODEL
    if (sc.sc_card.csd.sector_size != 512)
        ASSERT_OK(sdmmc_mem_set_blocklen(&sc, &sc.sc_card));
#endif

    // Single block RW
    ASSERT_OK(test_rw(SIZE, 0xDEADBEEF));

    // Multiple block RW
    ASSERT_OK(test_rw(BLOCKS*SIZE, 0x70EDADA1));
    // TODO half block rw?

    printf("\n");
    uart_write_flush(&__base_uart);

    return 1;
}
