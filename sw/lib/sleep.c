#ifndef SLEEP_C_
#define SLEEP_C_

#include "sleep.h"

// Setup a timer interrupt and enter sleep mode until it expires
void sleep(unsigned long int us)
{
    unsigned long int rtc_ticks = us * RTC_CLK_PER_US;
    unsigned long int wake_me = 0;
    if (us == 0) return;
    
    wake_me = (((unsigned long int)(CLINT(0xbffc)) << 32) | CLINT(0xbff8)) + rtc_ticks;

    // Write MTIMECMP0 High first
    CLINT(0x4004) = (wake_me >> 32) & ((int) -1);
    CLINT(0x4000) = wake_me & ((int) -1);


    // First enable the timer interrupt
    // Then enable global interrupts and go to sleep
    asm volatile(
        "fence\n                   \
         addi t0, x0, 128\n        \
         csrrs x0, mie, t0\n       \
         addi t0, x0, 8\n          \
         csrrs x0, mstatus, t0\n   \
         wfi\n"
        ::: "t0"
    );

    return;
}

#endif