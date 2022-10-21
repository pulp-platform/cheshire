#include "uart.h"
#include "printf.h"
#include "addr_specs.h"
#include "sleep.h"

char uart_initialized = 0;

void __attribute__((aligned(4))) trap_vector(void)
{
    long int mcause = 0, mepc = 0, mip = 0, mie = 0, mstatus = 0, mtval = 0;

    asm volatile(
        "csrrs t0, mcause, x0\n     \
         sd t0, %0\n                \
         csrrs t0, mepc, x0\n       \
         sd t0, %1\n                \
         csrrs t0, mip, x0\n        \
         sd t0, %2\n                \
         csrrs t0, mie, x0\n        \
         sd t0, %3\n                \
         csrrs t0, mstatus, x0\n    \
         sd t0, %4\n                \
         csrrs t0, mtval, x0\n      \
         sd t0, %5\n"
         : "=m" (mcause),
           "=m" (mepc),
           "=m" (mip),
           "=m" (mie),
           "=m" (mstatus),
           "=m" (mtval)
         :: "t0");

    // Interrupt with exception code 7 == Machine Mode Timer Interrupt
    if(mcause < 0 && (mcause << 1) == 14){
        // Handle interrupt by disabling the timer interrupt and returning
        asm volatile(
            "addi t0, x0, 128\n     \
             csrrc x0, mie, t0\n"
             ::: "t0"
        );
        return;
    } else {
        if(uart_initialized){
            printf_("Hello from the trap_vector :)\r\n");
            printf_("mcause:    0x%lx\r\n", mcause);
            printf_("mepc:      0x%lx\r\n", mepc);
            printf_("mip:       0x%lx\r\n", mip);
            printf_("mie:       0x%lx\r\n", mie);
            printf_("mstatus:   0x%lx\r\n", mstatus);
            printf_("mtval:     0x%lx\r\n", mtval);
        }
    }

    while(1){
        asm volatile("wfi\n" :::);
    }

    return;
}

void sys_entry(void){

    //printf("Hello from system mode\n");
    unsigned long int *rpt = (unsigned long int *) 0x70010000;
    unsigned long int *tst = (unsigned long int *) 0x100000000;

    // Map from 0x1_0000_0000 to 0x8000_0000
    rpt[4] = 0x00000000200000C7;

    // Direct map everything else
    rpt[0] = 0x00000000000000Cf;
    rpt[1] = 0x00000000100000Cf;
    rpt[2] = 0x00000000200000Cf;
    rpt[3] = 0x00000000300000Cf;

    asm volatile(
        "addi t0, x0, 7\n           \
        slli t0, t0, 16\n           \
        addi t1, x0, 1\n            \
        slli t1, t1, 4\n            \
        or t0, t0, t1\n             \
        addi t1, x0, 8\n            \
        slli t1, t1, 60\n           \
        or t0, t0, t1\n             \
        csrrw x0, satp, t0\n        \
        sfence.vma\n"
        ::: "t0", "t1"
    );

    printf("0x%lx\n", *tst);

}

int main(void)
{
    init_uart(200000000, 115200);

    uart_initialized = 1;
    //printf_("Testing the virtual memory system\r\n");

    // Put something into the region that will be mapped
    unsigned long int *ptr = (unsigned long int *) 0x80000000;
    *ptr = 0xDEADBEEFBEEFDEAD;

    // Drop to System Mode
    asm volatile(
        "la t0, sys_entry\n         \
         csrrw x0, mepc, t0\n       \
         addi t0, x0, 1\n           \
         slli t0, t0, 11\n          \
         csrrs x0, mstatus, t0\n    \
         mret\n"
         ::: "t0"
    );

}


