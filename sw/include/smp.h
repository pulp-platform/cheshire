// Copyright 2022 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Emanuele Parisi <emanuele.parisi@unibo.it>

#pragma once

#include <stdint.h>
#include <stdbool.h>

#include "util.h"
#include "regs/cheshire.h"
#include "params.h"

/*
 * Pause all harts except for hart 0 until a IPI is received. On wake-up every
 * core resumes execution from the address stored in SCRATCH[4:5] registers.
 */
void smp_pause(void);

/*
 * Resume execution in all harts. This function sets SCRATCH[4:5] registers and
 * sends an IPI to all harts except for hart 0. The execution resumes from the
 * last instruction of this function.
 */
void smp_resume(void);
