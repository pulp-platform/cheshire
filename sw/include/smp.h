// Copyright 2022 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Emanuele Parisi <emanuele.parisi@unibo.it>
// Enrico Zelioli <ezelioli@iis.ee.ethz.ch>

#pragma once

#include <stdint.h>
#include <stdbool.h>

#include "util.h"
#include "regs/cheshire.h"
#include "params.h"

/*
 * Resume execution in all harts.
 * Send an IPI to all harts except for hart 0.
 */
void smp_resume(void);

void smp_barrier_init();
void smp_barrier_up(uint64_t n_processes);
void smp_barrier_down();
