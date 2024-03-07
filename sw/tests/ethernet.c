#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include "util.h"
   
#define ETH_BASE 			 0x03010000

// MAC address low 32-bits
#define MACLO_OFFSET                 0x0800
// MAC address high 16-bits and MAC ctrl 
#define MACHI_OFFSET                 0x0808  
#define RFCS_OFFSET                  0x0828             
//tx packet length
#define TPLR_OFFSET                  0x0810       
// TX buffer
#define TXBUFF_OFFSET                0x1000
// RX buffer
#define RXBUFF_OFFSET                0x4000

int main() {
    
   uint64_t data_to_write[8] = {
    0x1032207098001032, 0x3210E20020709800, 0x1716151413121110, 0x2726252423222120,
    0x3736353433323130, 0x4746454443424140, 0x5756555453525150, 0x6766656463626160
    };

  // load data into mem
  for (int i = 0; i < 8; ++i) {
    
        volatile uint64_t *tx_addr = (volatile uint64_t*)(0x03011000 + i * sizeof(uint64_t));
        *tx_addr = data_to_write[i];
  }

  *reg32(ETH_BASE, TPLR_OFFSET ) = 0x00000040;
  *reg32(ETH_BASE, MACLO_OFFSET ) = 0x00890702;
  *reg32(ETH_BASE, MACHI_OFFSET ) = 0x00802301;
  *reg32(ETH_BASE, RFCS_OFFSET ) = 0x00000008;

   // *(volatile uint64_t *)0x30001020 = 0x3736353433323130;
    // *(volatile uint64_t *)0x30001028 = 0x4746454443424140;
    // *(volatile uint64_t *)0x30001030 = 0x5756555453525150;
    // *(volatile uint64_t *)0x30001038 = 0x6766656463626160;

  while(1);

  //return 0;

}


