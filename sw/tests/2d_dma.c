#include <stdio.h>
#include <stdlib.h>
#include <printf.h>
#include "util.h"
#include "dif/dma.h"

int main(void){

    // Size of transfer
    volatile uint64_t size_bytes = 8;
    // Source stride
    volatile uint64_t src_stride = 0;
    // Destination stride
    volatile uint64_t dst_stride = 0;
    // Number of repetitions
    volatile uint64_t num_reps = 128;
    volatile uint64_t *dst = 0x50000000;
    volatile uint64_t *src = 0x40000000;

    sys_dma_2d_blk_memcpy(dst, src, size_bytes, dst_stride, src_stride, num_reps);

    return 0;
}
