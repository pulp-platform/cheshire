// Copyright 2022 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

// Generated register defines for idma_reg64_frontend

#ifndef _SYS_DMA_REG64_FRONTEND_REG_DEFS_
#define _SYS_DMA_REG64_FRONTEND_REG_DEFS_

#ifdef __cplusplus
extern "C" {
#endif
// Register width
#define DMA_REG64_FRONTEND_PARAM_REG_WIDTH 64

// Source Address
#define DMA_REG64_FRONTEND_SRC_ADDR_REG_OFFSET 0x0

// Destination Address
#define DMA_REG64_FRONTEND_DST_ADDR_REG_OFFSET 0x8

// Number of bytes
#define DMA_REG64_FRONTEND_NUM_BYTES_REG_OFFSET 0x10

// Configuration Register for DMA settings
#define DMA_REG64_FRONTEND_CONF_REG_OFFSET 0x18
#define DMA_REG64_FRONTEND_CONF_DECOUPLE_BIT 0
#define DMA_REG64_FRONTEND_CONF_DEBURST_BIT 1
#define DMA_REG64_FRONTEND_CONF_SERIALIZE_BIT 2

// DMA Status
#define DMA_REG64_FRONTEND_STATUS_REG_OFFSET 0x20
#define DMA_REG64_FRONTEND_STATUS_BUSY_BIT 0

// Next ID, launches transfer, returns 0 if transfer not set up properly.
#define DMA_REG64_FRONTEND_NEXT_ID_REG_OFFSET 0x28

// Get ID of finished transactions.
#define DMA_REG64_FRONTEND_DONE_REG_OFFSET 0x30

#ifdef __cplusplus
}  // extern "C"
#endif
#endif  // _SYS_DMA_REG64_FRONTEND_REG_DEFS_
// End generated register defines for idma_reg64_frontend

#include <stdint.h>

#include "params.h"

#define CHS_DMA_BASE_ADDR 0x01000000
#define DSA0_DMA_BASE_ADDR 0x30001000

#define DMA_SRC_ADDR(BASE)	\
    (BASE + DMA_REG64_FRONTEND_SRC_ADDR_REG_OFFSET)
#define DMA_DST_ADDR(BASE)	\
    (BASE + DMA_REG64_FRONTEND_DST_ADDR_REG_OFFSET)
#define DMA_NUMBYTES_ADDR(BASE)	\
    (BASE + DMA_REG64_FRONTEND_NUM_BYTES_REG_OFFSET)
#define DMA_CONF_ADDR(BASE)	\
    (BASE + DMA_REG64_FRONTEND_CONF_REG_OFFSET)
#define DMA_STATUS_ADDR(BASE)	\
    (BASE + DMA_REG64_FRONTEND_STATUS_REG_OFFSET)
#define DMA_NEXTID_ADDR(BASE)   \
    (BASE + DMA_REG64_FRONTEND_NEXT_ID_REG_OFFSET)
#define DMA_DONE_ADDR(BASE)     \
    (BASE + DMA_REG64_FRONTEND_DONE_REG_OFFSET)

#define DMA_CONF_DECOUPLE 0
#define DMA_CONF_DEBURST 0
#define DMA_CONF_SERIALIZE 0

#define X(NAME, BASE_ADDR)                                                           \
    extern volatile uint64_t *NAME##_dma_src_ptr(void);                              \
    extern volatile uint64_t *NAME##_dma_dst_ptr(void);				     \
    extern volatile uint64_t *NAME##_dma_num_bytes_ptr(void);			     \
    extern volatile uint64_t *NAME##_dma_conf_ptr(void);			     \
    extern volatile uint64_t *NAME##_dma_status_ptr(void);			     \
    extern volatile uint64_t *NAME##_dma_nextid_ptr(void);			     \
    extern volatile uint64_t *NAME##_dma_done_ptr(void);			     \
										     \
    extern uint64_t NAME##_dma_memcpy(uint64_t dst, uint64_t src, uint64_t size);    \
    extern void NAME##_dma_blk_memcpy(uint64_t dst, uint64_t src, uint64_t size);    \
										     \
    inline volatile uint64_t *NAME##_dma_src_ptr(void) {			     \
	return (volatile uint64_t *)DMA_SRC_ADDR(BASE_ADDR);                         \
    }										     \
    inline volatile uint64_t *NAME##_dma_dst_ptr(void) {			     \
	return (volatile uint64_t *)DMA_DST_ADDR(BASE_ADDR);                         \
    }										     \
    inline volatile uint64_t *NAME##_dma_num_bytes_ptr(void) {                       \
	return (volatile uint64_t *)DMA_NUMBYTES_ADDR(BASE_ADDR);                    \
    }										     \
    inline volatile uint64_t *NAME##_dma_conf_ptr(void) {			     \
	return (volatile uint64_t *)DMA_CONF_ADDR(BASE_ADDR);                        \
    }										     \
    inline volatile uint64_t *NAME##_dma_status_ptr(void) {			     \
	return (volatile uint64_t *)DMA_STATUS_ADDR(BASE_ADDR);                      \
    }										     \
    inline volatile uint64_t *NAME##_dma_nextid_ptr(void) {			     \
	return (volatile uint64_t *)DMA_NEXTID_ADDR(BASE_ADDR);                      \
    }										     \
    inline volatile uint64_t *NAME##_dma_done_ptr(void) {			     \
	return (volatile uint64_t *)DMA_DONE_ADDR(BASE_ADDR);                        \
    }                                                                                \
										     \
    inline uint64_t NAME##_dma_memcpy(uint64_t dst, uint64_t src, uint64_t size) {   \
	*(NAME##_dma_src_ptr()) = (uint64_t)src;				     \
	*(NAME##_dma_dst_ptr()) = (uint64_t)dst;				     \
	*(NAME##_dma_num_bytes_ptr()) = size;					     \
	*(NAME##_dma_conf_ptr()) =						     \
	(DMA_CONF_DECOUPLE << DMA_REG64_FRONTEND_CONF_DECOUPLE_BIT) |	             \
	(DMA_CONF_DEBURST << DMA_REG64_FRONTEND_CONF_DEBURST_BIT) |		     \
	(DMA_CONF_SERIALIZE << DMA_REG64_FRONTEND_CONF_SERIALIZE_BIT);	             \
	return *(NAME##_dma_nextid_ptr());					     \
    }										     \
										     \
    inline void NAME##_dma_blk_memcpy(uint64_t dst, uint64_t src, uint64_t size) {	     \
	volatile uint64_t tf_id = NAME##_dma_memcpy(dst, src, size);		     \
										     \
	while (*(NAME##_dma_done_ptr()) != tf_id) {				     \
	asm volatile("nop");							     \
	}									     \
    }

X(sys, CHS_DMA_BASE_ADDR);
X(dsa0, DSA0_DMA_BASE_ADDR);
#undef X
