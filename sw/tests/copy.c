#include "regs/cheshire.h"
#include "dif/clint.h"
#include "dif/uart.h"
#include "params.h"
#include "util.h"
#include "stdio.h"

#include "stdlib.h"
#include "printf.h"


#define BLOCK_SIZE 0x1000000 // 1.024MiB 
#define STRIDE 0x1
#define ONE 0x1
volatile uint64_t input[BLOCK_SIZE * STRIDE];
volatile uint64_t output[BLOCK_SIZE *STRIDE];

int main(void) {
    uint32_t rtc_freq = *reg32(&__base_regs, CHESHIRE_RTC_FREQ_REG_OFFSET);
    uint64_t reset_freq = clint_get_core_freq(rtc_freq, 2500);
    uart_init(&__base_uart, reset_freq, __BOOT_BAUDRATE);

    volatile uint64_t read;
    volatile uint16_t read_2;
    uint64_t t0, t1;
    const uint64_t n= 65534;
    //printf("Copying from %llx to %llx\n\r", input, output);
    printf("Input is at %llx\n\r", input);

    asm volatile ("fence");
    
    t0 = get_mcycle();
    #pragma GCC unroll n
    for(uint64_t k = 0; k < BLOCK_SIZE * STRIDE; k += STRIDE){
            output[k] = input[k];
            //read = input[k];
    }

    t1 = get_mcycle();

    printf("Done: %llx (%lu) cycles. (%f seconds)\n\r", t1-t0, t1-t0, ((float)(t1-t0))/((float)reset_freq));

    while(1) {}

}

