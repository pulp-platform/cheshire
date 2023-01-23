// Copyright 2022 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Nicole Narr <narrn@student.ethz.ch>
// Christopher Reinwardt <creinwar@student.ethz.ch>

#pragma once

#define RTC_CLK_PER_US 1

extern void *__base_clint;

#define CLINT(offset) *((volatile unsigned long int *)(((unsigned long int)&__base_clint) + (offset)))

// Setup a timer interrupt and enter sleep mode until it expires
void sleep(unsigned long int us);
