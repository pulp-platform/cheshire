// Copyright 2022 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Emanuele Parisi <emanuele.parisi@unibo.it>
// Enrico Zelioli <ezelioli@iis.ee.ethz.ch>

#pragma once

// The hart that non-SMP tests should run on
#ifndef NONSMP_HART
#define NONSMP_HART 0
#endif

#ifndef __ASSEMBLER__

#include <stdint.h>
#include <stdbool.h>

#include "util.h"
#include "params.h"

// Resume all harts by sending them an IPI via the CLINT, then waiting for each
// to acknowledge. Hart 0 is skipped (it is the caller).
void smp_resume(void);

void smp_barrier_init(void);
void smp_barrier_up(uint64_t n_processes);
void smp_barrier_down(void);

#endif // __ASSEMBLER__
