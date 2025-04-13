// Copyright 2022 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Emanuele Parisi <emanuele.parisi@unibo.it>
// Enrico Zelioli <ezelioli@iis.ee.ethz.ch>

#pragma once

#include <stdint.h>

// Abstract type for shared atomic semaphore backed by an uncached platform register.
typedef volatile uint32_t* smp_sema_t;

// Initialize an uncached atomic semaphore to 0 and return. Check for NULL.
smp_sema_t smp_sema_init(int sid);

// Wait for uncached atomic semaphore to reach a given value.
void smp_sema_wait(smp_sema_t sema, int value, uint64_t spin_period);

// Shared barrier for all SMP cores. Uses a special reserved semaphore.
void smp_barrier(uint64_t spin_period);
