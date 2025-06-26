// Copyright 2023 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Nicole Narr <narrn@student.ethz.ch>
// Christopher Reinwardt <creinwar@student.ethz.ch>
// Emanuele Parisi <emanuele.parisi@unibo.it>
// Enrico Zelioli <ezelioli@iis.ee.ethz.ch>
// Paul Scheffler <paulsc@iis.ee.ethz.ch>
//
// Simple SMP Hello World.

int smain(int hid, int hnum) {
    // Define a reasonable semaphore spin period to reduce contention.
    const uint64_t SP = 20;

    // Get and check SMP semaphore.
    smp_sema_t sema = smp_sema_get(0);
    CHECK_ASSERT(-1, sema != NULL)

    // Only hart 0 initializes UART and semaphore.
    // A barrier ensures that all harts wait for initialization.
    if (hid == 0) {
        uint32_t rtc_freq = *reg32(&__base_regs, CHESHIRE_RTC_FREQ_REG_OFFSET);
        uint64_t reset_freq = clint_get_core_freq(rtc_freq, 2500);
        uart_init(&__base_uart, reset_freq, __BOOT_BAUDRATE);
        *sema = 0;
    }
    smp_barrier(SP);

    // Let each hart print sequentially using a atomically incremented semaphore.
    // Finally, use the semaphore to wait until the last hart has printed.
    smp_sema_wait(sema, hid, SP);
    printf("Hi from hart %d/%d\r\n", hid, hnum);
    uart_write_flush(&__base_uart);
    __atomic_fetch_add(sema, 1, __ATOMIC_RELAXED);
    smp_sema_wait(sema, hnum, SP);

    // Double-check that our semaphore is now equal to the internal hart count.
    // Only hart 0's return code is checked.
    return (*sema == hnum);
}
