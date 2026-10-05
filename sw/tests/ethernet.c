// Copyright 2026 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Chaoqun Liang <chaoqun.liang@unibo.it>
//
// Cheshire bare-metal Ethernet loopback test.
// REQ_VALID:     write 1 per request; HW clears it on acceptance.
// RSP_VALID_CLR: write-only level field, HW clears on its rising edge,
//                so write 1 then 0.
// LENGTH:        TX length written by SW; holds the RX frame length while a
//                received frame is pending.

#include <stdint.h>
#include "util.h"

#define ETH_BASE                   0x0300c000
#define MACLO_OFFSET               0x00
#define MACHI_OFFSET               0x04
#define ETH_IDMA_TX_BUSY_OFFSET    0x0c
#define ETH_IDMA_RSR_OFFSET        0x18
#define IDMA_SRC_ADDR_OFFSET       0x1c
#define IDMA_DST_ADDR_OFFSET       0x20
#define IDMA_LENGTH_OFFSET         0x24
#define IDMA_SRC_PROTO_OFFSET      0x28
#define IDMA_DST_PROTO_OFFSET      0x2c
#define IDMA_REQ_VALID_OFFSET      0x44
#define IDMA_REQ_READY_OFFSET      0x48
#define IDMA_RSP_VALID_OFFSET      0x50
#define IDMA_RSP_VALID_CLR_OFFSET  0x58

#define RSR_RX_COMPLETE            (1u << 0)

#define PLIC_BASE                  0x04000000
#define RV_PLIC_PRIO19_OFFSET      0x4c
#define RV_PLIC_IE0_0_OFFSET       0x2000
#define RV_PLIC_IP_0_OFFSET        0x1000
#define RV_PLIC_CC0_OFFSET         0x200004
#define ETH_IRQ_ID                 19

#define PROTO_AXI                  0x0
#define PROTO_AXIS                 0x5

#define DATA_CHUNK                 8
#define FRAME_BYTES                (DATA_CHUNK * 8)

#define TX_BASE                    0x14000000
#define RX_BASE0                   0x14001000
#define RX_BASE1                   0x14002000

#define TIMEOUT                    1000000

// Error codes (returned by main)
#define ERR_TIMEOUT_REQ_READY      0x100
#define ERR_TIMEOUT_DMA            0x200
#define ERR_TIMEOUT_TX_BUSY        0x300
#define ERR_TIMEOUT_RX             0x400
#define ERR_RX_LENGTH              0x500

static const uint64_t frame[DATA_CHUNK] = {
  0x0207230100890702, 0x3210400020709800,
  0x1716151413121110, 0x2726252423222120,
  0x3736353433323130, 0x4746454443424140,
  0x5756555453525150, 0x6766656463626160
};

static inline uint32_t eth_rd(uint32_t off)             { return *reg32(ETH_BASE, off); }
static inline void     eth_wr(uint32_t off, uint32_t v) { *reg32(ETH_BASE, off) = v; }

// Wait for the DMA completion and clear it, so a later poll never sees a
// stale completion of the previous transfer.
static int dma_wait_done(void) {
  for (uint32_t t = 0; t < TIMEOUT; ++t) {
    if (eth_rd(IDMA_RSP_VALID_OFFSET)) {
      eth_wr(IDMA_RSP_VALID_CLR_OFFSET, 1);   // rising edge -> clear
      eth_wr(IDMA_RSP_VALID_CLR_OFFSET, 0);   // re-arm for the next clear
      return 0;
    }
  }
  return ERR_TIMEOUT_DMA;
}

static int dma_issue(uint32_t src, uint32_t dst, uint32_t src_proto,
                     uint32_t dst_proto, uint32_t len) {
  eth_wr(IDMA_SRC_ADDR_OFFSET,  src);
  eth_wr(IDMA_DST_ADDR_OFFSET,  dst);
  eth_wr(IDMA_SRC_PROTO_OFFSET, src_proto);
  eth_wr(IDMA_DST_PROTO_OFFSET, dst_proto);
  if (len) eth_wr(IDMA_LENGTH_OFFSET, len);    // TX only; RX length comes from HW
  uint32_t t = 0;
  while (!eth_rd(IDMA_REQ_READY_OFFSET))
    if (++t == TIMEOUT) return ERR_TIMEOUT_REQ_READY;
  eth_wr(IDMA_REQ_VALID_OFFSET, 1);           // HW clears it on acceptance
  return dma_wait_done();
}

static int eth_send(void) {
  int err = dma_issue(TX_BASE, 0x0, PROTO_AXI, PROTO_AXIS, FRAME_BYTES);
  if (err) return err;
  for (uint32_t t = 0; t < TIMEOUT; ++t)
    if (!eth_rd(ETH_IDMA_TX_BUSY_OFFSET)) return 0;
  return ERR_TIMEOUT_TX_BUSY;
}

// Wait for the RX interrupt, claim it (clears IP), check RSR.rx_complete,
// move the frame to dst, then complete the interrupt.
static int eth_receive(uint32_t dst, uint32_t *len) {
  uint32_t t = 0;
  while (!(*reg32(PLIC_BASE, RV_PLIC_IP_0_OFFSET) & (1u << ETH_IRQ_ID)))
    if (++t == TIMEOUT) return ERR_TIMEOUT_RX;
  uint32_t id = *reg32(PLIC_BASE, RV_PLIC_CC0_OFFSET);       // claim
  if (!(eth_rd(ETH_IDMA_RSR_OFFSET) & RSR_RX_COMPLETE)) return ERR_TIMEOUT_RX | 0x10;
  *len = eth_rd(IDMA_LENGTH_OFFSET) & 0xfff;   // RX length while frame pending
  int err = dma_issue(0x0, dst, PROTO_AXIS, PROTO_AXI, 0);
  *reg32(PLIC_BASE, RV_PLIC_CC0_OFFSET) = id;                // complete
  return err;
}

static uint32_t check(uint32_t base) {
  uint32_t errors = 0;
  for (int i = 0; i < DATA_CHUNK; ++i)
    if (*(volatile uint64_t *)(uintptr_t)(base + 8 * i) != frame[i]) errors++;
  return errors;
}

int main(void) {
  uint32_t len0 = 0, len1 = 0;
  int err;

  *reg32(PLIC_BASE, RV_PLIC_PRIO19_OFFSET) = 1;
  *reg32(PLIC_BASE, RV_PLIC_IE0_0_OFFSET) |= (1u << ETH_IRQ_ID);

  for (int i = 0; i < DATA_CHUNK; ++i)
    *(volatile uint64_t *)(uintptr_t)(TX_BASE + 8 * i) = frame[i];

  eth_wr(MACLO_OFFSET, 0x89000123);
  eth_wr(MACHI_OFFSET, 0x00800207);   // upper MAC 0x0207, irq_en (bit 23)

  // Frame 1
  if ((err = eth_send()))                   return err | 0x1;
  if ((err = eth_receive(RX_BASE0, &len0))) return err | 0x1;

  // Frame 2: sent immediately after the RX completion, so its tail arrives
  // within the window where the old framing_top cleared rx_complete by level
  if ((err = eth_send()))                   return err | 0x2;
  if ((err = eth_receive(RX_BASE1, &len1))) return err | 0x2;

  if (len0 < FRAME_BYTES || len1 < FRAME_BYTES) return ERR_RX_LENGTH;

  return (int)(check(RX_BASE0) + check(RX_BASE1));
}
