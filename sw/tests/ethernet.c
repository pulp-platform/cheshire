#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include "printf.h"
#include "util.h"
   
#define ETH_BASE 			               0x0300c000

#define MACLO_OFFSET                 0x0
#define MACHI_OFFSET                 0x4
#define IRQ_OFFSET                   0x18
#define IDMA_SRC_ADDR_OFFSET         0x1c
#define IDMA_DST_ADDR_OFFSET         0x20
#define IDMA_LENGTH_OFFSET           0x24
#define IDMA_SRC_PROTO_OFFSET        0x28
#define IDMA_DST_PROTO_OFFSET        0x2c
#define IDMA_REQ_VALID_OFFSET        0x44
#define IDMA_REQ_READY_OFFSET        0x48
#define IDMA_RSP_READY_OFFSET        0x4c
#define IDMA_RSP_VALID_OFFSET        0x50
#define IDMA_RX_EN_OFFSET            0x54

#define PLIC_BASE                    0x04000000
#define RV_PLIC_PRIO19_REG_OFFSET    0x4c
#define RV_PLIC_IE0_0_REG_OFFSET     0x2000
#define RV_PLIC_CC0_REG_OFFSET       0x200004
#define RV_PLIC_IE0_0_E_19_BIT       19
#define PLIC_ENABLE_REG_BASE         PLIC_BASE + RV_PLIC_IE0_0_REG_OFFSET
#define PLIC_CLAIM_COMPLETE_BASE     PLIC_BASE + RV_PLIC_CC0_REG_OFFSET

#define RV_PLIC_IP_0_OFFSET          0x1000

#define DATA_CHUNK 8

#define BYTE_SIZE 8

#define TX_BASE 0x14000000
#define RX_BASE 0x14001000

#define PRINTF_ON

int main(void) { 
  
  #ifdef PRINTF_ON
    printf ("Start test Ethernet...\n\r");
  #endif 

 *reg32(PLIC_BASE, RV_PLIC_PRIO19_REG_OFFSET) = 1;
 *reg32(PLIC_BASE, RV_PLIC_IE0_0_REG_OFFSET)  |= (1 << (RV_PLIC_IE0_0_E_19_BIT)); // Enable interrupt number ;

  volatile uint64_t data_to_write[DATA_CHUNK] = {
        0x0207230100890702, 
        0x3210400020709800,
        0x1716151413121110, 
        0x2726252423222120,
        0x3736353433323130, 
        0x4746454443424140,
        0x5756555453525150, 
        0x6766656463626160
  };

  // load data into mem
  for (int i = 0; i < DATA_CHUNK; ++i) {
        volatile uint64_t *tx_addr = (volatile uint64_t*)(TX_BASE + i * sizeof(uint64_t));
        *tx_addr = data_to_write[i];
  }

  *reg32(ETH_BASE, MACLO_OFFSET)          = 0x00890702;
  // High 16 bit Mac Address
  *reg32(ETH_BASE, MACHI_OFFSET)          = 0x00002301;
  // DMA Source Address
  *reg32(ETH_BASE, IDMA_SRC_ADDR_OFFSET)  = TX_BASE;
  // DMA Destination Address
  *reg32(ETH_BASE, IDMA_DST_ADDR_OFFSET)  = 0x0;
  // Data length
  *reg32(ETH_BASE, IDMA_LENGTH_OFFSET)    = DATA_CHUNK*BYTE_SIZE;
  // Source Protocol
  *reg32(ETH_BASE, IDMA_DST_PROTO_OFFSET) = 0x0;
  // Destination Protocol
  *reg32(ETH_BASE, IDMA_DST_PROTO_OFFSET) = 0x5;

  // Validate Request to DMA
  *reg32(ETH_BASE, IDMA_REQ_VALID_OFFSET) = 0x1;
  
  // rx irq
  while (!(*reg32(PLIC_BASE, RV_PLIC_IP_0_OFFSET)) & (1 << 19) );
  // configure ethernet
  *reg32(ETH_BASE, MACLO_OFFSET)          = 0x00890702;  
  *reg32(ETH_BASE, MACHI_OFFSET)          = 0x00002301;  
  // dma length ready, dma can be configured now
  while (!(*reg32(ETH_BASE,IDMA_RX_EN_OFFSET)));

  *reg32(ETH_BASE, IDMA_SRC_ADDR_OFFSET)  = 0x0; 
  *reg32(ETH_BASE, IDMA_DST_ADDR_OFFSET)  = RX_BASE;
  // *reg32(ETH_BASE, IDMA_LENGTH_OFFSET)    = DATA_CHUNK*BYTE_SIZE;
  *reg32(ETH_BASE, IDMA_SRC_PROTO_OFFSET) = 0x5;
  *reg32(ETH_BASE, IDMA_DST_PROTO_OFFSET) = 0x0;
  *reg32(ETH_BASE, IDMA_REQ_VALID_OFFSET) = 0x1;

  // wait until DMA moves all data
  while (!(*reg32(ETH_BASE, IDMA_RSP_VALID_OFFSET)));

  uint32_t error = 0;

  for (int i = 0; i < DATA_CHUNK; ++i) {
    volatile uint64_t *rx_addr = (volatile uint64_t*)(RX_BASE + i * sizeof(uint64_t));
    uint64_t data_read = *rx_addr;

    if (data_read != data_to_write[i]) error ++;
  }

  return error;
}

