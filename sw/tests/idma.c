// Copyright 2024 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//


#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include "util.h"
#include "printf.h"

#define IDMA_BASE 	  0x01000000
#define TCDM_BASE     0x14000000
#define L2_BASE       0x18000000

#define IDMA_SRC_ADDR_OFFSET         0x000000d8
#define IDMA_DST_ADDR_OFFSET         0x000000d0
#define IDMA_LENGTH_OFFSET           0x000000e0
#define IDMA_NEXT_ID_OFFSET          0x00000044
#define IDMA_REPS_2                  0x000000f8
#define IDMA_REPS_3                  0x00000110
#define IDMA_CONF                    0x00000000

int main() {

	printf ("Start iDMA test...\n\r");

  int volatile  * ptr;
  int buff,b;
  int err = 0;

   volatile uint64_t src_data[8] = {
        0x1032207098001032, 
        0x3210E20020709800,
        0x1716151413121110, 
        0x2726252423222120,
        0x3736353433323130, 
        0x4746454443424140,
        0x5756555453525150, 
        0x6766656463626160
  };

  // load data into src address 
  for (int i = 0; i < 8; ++i) {
      volatile uint64_t *src_addr = (volatile uint64_t*)(TCDM_BASE + i * sizeof(uint64_t));
      *src_addr = src_data[i];
  }

  ptr = (int *) (IDMA_BASE + IDMA_SRC_ADDR_OFFSET);
  *ptr = TCDM_BASE;
  ptr = (int *) (IDMA_BASE + IDMA_DST_ADDR_OFFSET);
  *ptr = L2_BASE;
  ptr = (int *) (IDMA_BASE + IDMA_LENGTH_OFFSET);
  *ptr = 0x00000190;
  ptr = (int *) (IDMA_BASE + IDMA_CONF);
  *ptr = 0x3<<10;
  ptr = (int *) (IDMA_BASE + IDMA_REPS_2);
  *ptr = 0x00000001;
  ptr = (int *) (IDMA_BASE + IDMA_NEXT_ID_OFFSET);
  buff = *ptr;

  for(int j = 0; j<8; j++){
    ptr = (uint64_t *)(L2_BASE + j * sizeof(uint64_t));

    b = *ptr;
    if(b!= src_data[j])
      err++;
  }

  if(err!=0){
    printf ("mismatch...\n\r");
    return -1;
  }
  else
    return 0;

}

// #include <stdio.h>
// #include <stdlib.h>
// #include <stdint.h>
// #include "printf.h"
// #include "util.h"
// #include "dif/dma.h"
// #include "regs/idma.h"
// #include "params.h"

// #define IDMA_BASE 	   0x01000000
// #define SRC_ADDR       0x14000000
// #define DST_ADDR       0x18000000
// #define SRC_STRIDE 0
// #define DST_STRIDE 0
// #define NUM_REPS 2
// #define SIZE_BYTES 64
// #define IDMA_SRC_ADDR_OFFSET         0x00d8
// #define IDMA_DST_ADDR_OFFSET         0x00d0
// #define IDMA_LENGTH_OFFSET           0x00e0
// #define IDMA_REPS_OFFSET 0xf8

// #define IDMA_DST_STRIDE_OFFSET 0xe8
// #define IDMA_SRC_STRIDE_OFFSET 0xf0

// #define IDMA_CONFIG_OFFSET           0x0000
// #define IDMA_NEXT_ID_OFFSET          0x0044

// #define PRINTF_ON

// int main(void) { 

//   #ifdef PRINTF_ON
//     printf ("Start iDMA test...\n\r");
//   #endif 

//   volatile uint64_t src_data[8] = {
//         0x1032207098001032, 
//         0x3210E20020709800,
//         0x1716151413121110, 
//         0x2726252423222120,
//         0x3736353433323130, 
//         0x4746454443424140,
//         0x5756555453525150, 
//         0x6766656463626160
//   };

//   // load data into src address 
//   for (int i = 0; i < 8; ++i) {
//       volatile uint64_t *src_addr = (volatile uint64_t*)(SRC_ADDR + i * sizeof(uint64_t));
//       *src_addr = src_data[i];
//   }
 
  
//   sys_dma_2d_blk_memcpy(DST_ADDR, SRC_ADDR, SIZE_BYTES, DST_STRIDE, SRC_STRIDE, NUM_REPS);
//   uint64_t volatile  * ptr;
//    ptr = (uint64_t *) (IDMA_BASE + IDMA_CONFIG_OFFSET );
//   *ptr = 0x3<<10; 

//   int err_count = 0;

//   for(int j = 0;j < 8; ++j) {
//   	volatile uint64_t *dst_data = (volatile uint64_t*)(DST_ADDR + j * sizeof(uint64_t));
//     if (*dst_data != src_data[j]) {
//         printf("Data mismatch at index %d\n", j);
//         err_count++;
//     }
//   }
  

//   if (err_count == 0) {
//     printf("Data transfer successful\n");
//     } else {
//     printf("Data transfer failed with %d mismatches\n", err_count);
//   }
//     return 0;

// }