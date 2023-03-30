// Copyright 2022 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Nicole Narr <narrn@student.ethz.ch>
// Christopher Reinwardt <creinwar@student.ethz.ch>
// Paul Scheffler <paulsc@iis.ee.ethz.ch>

#pragma once

#include <stdint.h>

uint64_t clint_get_mtime();

void clint_spin_until(uint64_t tgt_mtime);

void clint_spin_ticks(uint64_t ticks);

// This assumes a stable clock
uint64_t clint_get_core_freq(uint64_t ref_freq, uint64_t num_ticks);

void clint_set_mtimecmpx(uint64_t timer_idx, uint64_t value);

// PRE: requires an appropriate trap handler catching the timer interrupt
void clint_sleep_until(uint64_t timer_idx, uint64_t tgt_mtime);

// PRE: requires an appropriate trap handler catching the timer interrupt
void clint_sleep_ticks(uint64_t timer_idx, uint64_t ticks);
