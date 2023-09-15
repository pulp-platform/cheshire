#include <stdio.h>
#include <stdlib.h>
#include <printf.h>
#include "util.h"
#include "dif/dma.h"
#include "axirt.h"
#include "regs/axi_rt.h"

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
    fence();

//    // enable and configure axi rt
//    __axirt_claim(0, 0);
//    __axirt_set_len_limit_group(0, 0);
//    __axirt_set_len_limit_group(0, 1);
//    for (int m = 0; m < AXI_RT_PARAM_NUM_MRG; m++) {
//        __axirt_set_region(0, 0xffffffff, 0, m);
//        __axirt_set_region(0x100000000, 0xffffffffffffffff, 1, m);
//        __axirt_set_budget(0x10000000, 0, m);
//        __axirt_set_budget(0x10000000, 1, m);
//        __axirt_set_period(0x10000000, 0, m);
//        __axirt_set_period(0x10000000, 1, m);
//    }
//    __axirt_enable(0xffffffff);
//    fence();
//
//    sys_dma_2d_blk_memcpy(dst, src, size_bytes, dst_stride, src_stride, num_reps);
//    fence();

    return 0;
}
