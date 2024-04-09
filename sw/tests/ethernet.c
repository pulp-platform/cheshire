#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include "util.h"
   
#define ETH_BASE 			 0x0300c000

#define MACLO_OFFSET                 0x0
#define MACHI_OFFSET                 0x4

#define IDMA_SRC_ADDR_OFFSET         0x10
#define IDMA_DST_ADDR_OFFSET         0x14
#define IDMA_LENGTH_OFFSET           0x18
#define IDMA_SRC_PROTO_OFFSET        0x1c
#define IDMA_DST_PROTO_OFFSET        0x20
#define IDMA_REQ_VALID_OFFSET        0x38
#define IDMA_REQ_READY_OFFSET        0x3c
#define IDMA_RSP_READY_OFFSET        0x40
#define IDMA_RSP_VALID_OFFSET        0x44

int main(void) {
    
  volatile uint64_t data_to_write[8] = {
        0x1032207098001032, 
        0x3210E20020709800,
        0x1716151413121110, 
        0x2726252423222120,
        0x3736353433323130, 
        0x4746454443424140,
        0x5756555453525150, 
        0x6766656463626160
    };

  // load data into mem
  for (int i = 0; i < 8; ++i) {
    
        volatile uint64_t *tx_addr = (volatile uint64_t*)(0x14000000 + i * sizeof(uint64_t));
        *tx_addr = data_to_write[i];
  }

  *reg32(ETH_BASE, MACLO_OFFSET)  = 0x98001032;  
  *reg32(ETH_BASE, MACHI_OFFSET) = 0x00012070;  

  *reg32(ETH_BASE, IDMA_SRC_ADDR_OFFSET)= 0x14000000; 
  *reg32(ETH_BASE, IDMA_DST_ADDR_OFFSET)= 0x0;
  *reg32(ETH_BASE, IDMA_LENGTH_OFFSET) = 0x40;
  *reg32(ETH_BASE, IDMA_SRC_PROTO_OFFSET) = 0x0;
  *reg32(ETH_BASE, IDMA_DST_PROTO_OFFSET) = 0x5;
 

  *reg32(ETH_BASE, IDMA_REQ_VALID_OFFSET) = 0x1;
  *reg32(ETH_BASE, IDMA_REQ_VALID_OFFSET) = 0x0;
  *reg32(ETH_BASE, IDMA_RSP_READY_OFFSET) = 0x1;
  
   // can leave rsp_ready high  
  return 0;

}
