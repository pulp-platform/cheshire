// Copyright 2022 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Nicole Narr <narrn@student.ethz.ch>
// Christopher Reinwardt <creinwar@student.ethz.ch>

#ifndef SLEEP_H_
#define SLEEP_H_

#define RTC_CLK_PER_US 1


#define CLINT(offset) *((volatile unsigned int *) (0x04000000 + (offset)))

// Setup a timer interrupt and enter sleep mode until it expires
void sleep(unsigned long int us);

#endif
