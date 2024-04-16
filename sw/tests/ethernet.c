#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include "printf.h"
#include "util.h"
   
#define ETH_BASE 			 0x0300c000

#define MACLO_OFFSET                 0x0
#define MACHI_OFFSET                 0x4
#define IRQ_OFFSET                   0x10
#define IDMA_SRC_ADDR_OFFSET         0x14
#define IDMA_DST_ADDR_OFFSET         0x18
#define IDMA_LENGTH_OFFSET           0x1c
#define IDMA_SRC_PROTO_OFFSET        0x20
#define IDMA_DST_PROTO_OFFSET        0x24
#define IDMA_REQ_VALID_OFFSET        0x3c
#define IDMA_REQ_READY_OFFSET        0x40
#define IDMA_RSP_READY_OFFSET        0x44
#define IDMA_RSP_VALID_OFFSET        0x48

#define PLIC_BASE                    0x04000000
#define RV_PLIC_PRIO19_REG_OFFSET    0x4c
#define RV_PLIC_IE0_0_REG_OFFSET     0x2000
#define RV_PLIC_CC0_REG_OFFSET       0x200004
#define RV_PLIC_IE0_0_E_19_BIT       19
#define PLIC_ENABLE_REG_BASE         PLIC_BASE + RV_PLIC_IE0_0_REG_OFFSET
#define PLIC_CLAIM_COMPLETE_BASE     PLIC_BASE + RV_PLIC_CC0_REG_OFFSET

#define RV_PLIC_IP_0_OFFSET          0x1000

#define PRINTF_ON

int main(void) { 
  
  #ifdef PRINTF_ON
    printf ("Start test Ethernet...\n\r");
  #endif 

 *reg32(PLIC_BASE, RV_PLIC_PRIO19_REG_OFFSET) = 1;
 *reg32(PLIC_BASE, RV_PLIC_IE0_0_REG_OFFSET)  |= (1 << (RV_PLIC_IE0_0_E_19_BIT)); // Enable interrupt number ;

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
  
  *reg32(ETH_BASE, MACLO_OFFSET)          = 0x98001032;  
  *reg32(ETH_BASE, MACHI_OFFSET)          = 0x00012070;  

  *reg32(ETH_BASE, IDMA_SRC_ADDR_OFFSET)  = 0x14000000; 
  *reg32(ETH_BASE, IDMA_DST_ADDR_OFFSET)  = 0x0;
  *reg32(ETH_BASE, IDMA_LENGTH_OFFSET)    = 0x40;
  *reg32(ETH_BASE, IDMA_SRC_PROTO_OFFSET) = 0x0;
  *reg32(ETH_BASE, IDMA_DST_PROTO_OFFSET) = 0x5;
 
  *reg32(ETH_BASE, IDMA_REQ_VALID_OFFSET) = 0x1;
  *reg32(ETH_BASE, IDMA_REQ_VALID_OFFSET) = 0x0;
  *reg32(ETH_BASE, IDMA_RSP_READY_OFFSET) = 0x1;

  while (!(*reg32(PLIC_BASE, RV_PLIC_IP_0_OFFSET)) & (1 << 19) );

  printf ("Ethernet test pass...\n\r");
  return 0;
}

