// Copyright 2023 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Alessandro Ottaviano <aottaviano@iis.ee.ethz.ch>
//

#include "io.h"
#include "dif/clint.h"
#include "dif/uart.h"
#include "params.h"
#include "regs/cheshire.h"
#include "regs/system_timer.h"
#include "util.h"

// TODO: This test is really brittle. Its only purpose is to test timer accesses when the timer is
// configured in freerunning mode and check if the value is within a sensible range. A better test
// uses a periodic timer and checks if the periodic interrupts are taken. It will replace the
// current test when interrupts are tested in the SoC.

#define DUMMY_TIMER_CNT_GOLDEN_MIN 8050
#define DUMMY_TIMER_CNT_GOLDEN_MAX 8280

int main(void) {

    // Reset timer
    chs_playgnd_reset_timer();

    // Start system timer
    chs_playgnd_start_timer();

    for (volatile int i = 0; i < 500; i++)
	;

    // Stop system timer
    chs_playgnd_stop_timer();

    // Get system timer count
    volatile uint32_t time = chs_playgnd_get_timer_count();

    // Note: the result is checked against a golden value that is probed from
    // the waveforms, to check if the value is correctly read from sw.
    CHECK_ASSERT(1, (DUMMY_TIMER_CNT_GOLDEN_MIN <= time <= DUMMY_TIMER_CNT_GOLDEN_MAX));

}
