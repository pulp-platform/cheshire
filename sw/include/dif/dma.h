// Copyright 2022 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Alessandro Ottaviano <aottaviano@iis.ee.ethz.ch>
// Thomas Benz <tbenz@iis.ee.ethz.ch>

#pragma once

#include <stdint.h>
#include <stddef.h>
#include "regs/idma.h"
#include "params.h"

#define DMA_SRC_ADDR(BASE) (void *)((uint8_t *)BASE + offsetof(idma_reg64_2d_t, src_addr))
#define DMA_DST_ADDR(BASE) (void *)((uint8_t *)BASE + offsetof(idma_reg64_2d_t, dst_addr))
#define DMA_NUMBYTES_ADDR(BASE) (void *)((uint8_t *)BASE + offsetof(idma_reg64_2d_t, length))
#define DMA_CONF_ADDR(BASE) (void *)((uint8_t *)BASE + offsetof(idma_reg64_2d_t, conf))
#define DMA_STATUS_ADDR(BASE) (void *)((uint8_t *)BASE + offsetof(idma_reg64_2d_t, status))
#define DMA_NEXTID_ADDR(BASE) (void *)((uint8_t *)BASE + offsetof(idma_reg64_2d_t, next_id))
#define DMA_DONE_ADDR(BASE) (void *)((uint8_t *)BASE + offsetof(idma_reg64_2d_t, done_id))
#define DMA_SRC_STRIDE_ADDR(BASE) \
    (void *)((uint8_t *)BASE + offsetof(idma_reg64_2d_t, dim[0].src_stride))
#define DMA_DST_STRIDE_ADDR(BASE) \
    (void *)((uint8_t *)BASE + offsetof(idma_reg64_2d_t, dim[0].dst_stride))
#define DMA_NUM_REPS_ADDR(BASE) (void *)((uint8_t *)BASE + offsetof(idma_reg64_2d_t, dim[0].reps))
#define DMA_CONF_DECOUPLE_NONE (0)
#define DMA_CONF_DECOUPLE_AW (1 << IDMA_REG64_2D__CONF__DECOUPLE_AW_bp)
#define DMA_CONF_DECOUPLE_RW (1 << IDMA_REG64_2D__CONF__DECOUPLE_RW_bp)
#define DMA_CONF_DECOUPLE_ALL (DMA_CONF_DECOUPLE_AW | DMA_CONF_DECOUPLE_RW)

#define X(NAME, BASE_ADDR) \
    static inline volatile uint64_t *NAME##_dma_src_ptr(void) { \
        return (volatile uint64_t *)DMA_SRC_ADDR(BASE_ADDR); \
    } \
    static inline volatile uint64_t *NAME##_dma_dst_ptr(void) { \
        return (volatile uint64_t *)DMA_DST_ADDR(BASE_ADDR); \
    } \
    static inline volatile uint64_t *NAME##_dma_num_bytes_ptr(void) { \
        return (volatile uint64_t *)DMA_NUMBYTES_ADDR(BASE_ADDR); \
    } \
    static inline volatile uint64_t *NAME##_dma_conf_ptr(void) { \
        return (volatile uint64_t *)DMA_CONF_ADDR(BASE_ADDR); \
    } \
    static inline volatile uint64_t *NAME##_dma_status_ptr(void) { \
        return (volatile uint64_t *)DMA_STATUS_ADDR(BASE_ADDR); \
    } \
    static inline volatile uint64_t *NAME##_dma_nextid_ptr(void) { \
        return (volatile uint64_t *)DMA_NEXTID_ADDR(BASE_ADDR); \
    } \
    static inline volatile uint64_t *NAME##_dma_done_ptr(void) { \
        return (volatile uint64_t *)DMA_DONE_ADDR(BASE_ADDR); \
    } \
    static inline volatile uint64_t *NAME##_dma_src_stride_ptr(void) { \
        return (volatile uint64_t *)DMA_SRC_STRIDE_ADDR(BASE_ADDR); \
    } \
    static inline volatile uint64_t *NAME##_dma_dst_stride_ptr(void) { \
        return (volatile uint64_t *)DMA_DST_STRIDE_ADDR(BASE_ADDR); \
    } \
    static inline volatile uint64_t *NAME##_dma_num_reps_ptr(void) { \
        return (volatile uint64_t *)DMA_NUM_REPS_ADDR(BASE_ADDR); \
    } \
\
    static inline uint64_t NAME##_dma_memcpy(uint64_t dst, uint64_t src, uint64_t size, \
                                             uint64_t conf) { \
        *(NAME##_dma_src_ptr()) = (uint64_t)src; \
        *(NAME##_dma_dst_ptr()) = (uint64_t)dst; \
        *(NAME##_dma_num_bytes_ptr()) = size; \
        *(NAME##_dma_conf_ptr()) = conf; \
        return *(NAME##_dma_nextid_ptr()); \
    } \
\
    static inline void NAME##_dma_blk_memcpy(uint64_t dst, uint64_t src, uint64_t size, \
                                             uint64_t conf) { \
        volatile uint64_t tf_id = NAME##_dma_memcpy(dst, src, size, conf); \
        while (*(NAME##_dma_done_ptr()) != tf_id) { \
            asm volatile("nop"); \
        } \
    } \
\
    static inline uint64_t NAME##_dma_2d_memcpy(uint64_t dst, uint64_t src, uint64_t size, \
                                                uint64_t dst_stride, uint64_t src_stride, \
                                                uint64_t num_reps, uint64_t conf) { \
        *(NAME##_dma_src_ptr()) = (uint64_t)src; \
        *(NAME##_dma_dst_ptr()) = (uint64_t)dst; \
        *(NAME##_dma_num_bytes_ptr()) = size; \
        *(NAME##_dma_conf_ptr()) = conf | (1 << IDMA_REG64_2D__CONF__ENABLE_ND_bp); \
        *(NAME##_dma_src_stride_ptr()) = src_stride; \
        *(NAME##_dma_dst_stride_ptr()) = dst_stride; \
        *(NAME##_dma_num_reps_ptr()) = num_reps; \
        return *(NAME##_dma_nextid_ptr()); \
    } \
\
    static inline void NAME##_dma_2d_blk_memcpy(uint64_t dst, uint64_t src, uint64_t size, \
                                                uint64_t dst_stride, uint64_t src_stride, \
                                                uint64_t num_reps, uint64_t conf) { \
        volatile uint64_t tf_id = \
            NAME##_dma_2d_memcpy(dst, src, size, dst_stride, src_stride, num_reps, conf); \
        while (*(NAME##_dma_done_ptr()) != tf_id) { \
            asm volatile("nop"); \
        } \
    } \
\
    static inline uint64_t NAME##_dma_get_status(void) { \
        return *(NAME##_dma_status_ptr()); \
    }

X(sys, &__dma_base_addr__)

#undef X
