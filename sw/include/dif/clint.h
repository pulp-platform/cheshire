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

void clint_set_mtimecmpx(uint64_t timer_idx, uint64_t value);

void clint_sleep_ticks(uint64_t timer_idx, uint64_t ticks);
