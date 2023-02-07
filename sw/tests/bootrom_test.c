// Copyright 2022 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Nicole Narr <narrn@student.ethz.ch>
// Christopher Reinwardt <creinwar@student.ethz.ch>

#include "printf.h"
#include "trap.h"

char uart_initialized = 0;

extern void *__base_bootrom;

void __attribute__((aligned(4))) trap_vector(void) { test_trap_vector(&uart_initialized); }

int main(void) {

    // We just re-enter the bootrom from here
    void (*bootrom)(void) = (void (*)(void)) & __base_bootrom;
    bootrom();
}
