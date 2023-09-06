// Copyright 2022 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Alessandro Ottaviano <aottaviano@iis.ee.ethz.ch>
// Thomas Benz <tbenz@iis.ee.ethz.ch>

#include <stdint.h>
#include "regs/idma.h"
#include "params.h"

#define DMA_SRC_ADDR(BASE) ((void *)BASE + IDMA_REG64_2D_FRONTEND_SRC_ADDR_REG_OFFSET)
#define DMA_DST_ADDR(BASE) ((void *)BASE + IDMA_REG64_2D_FRONTEND_DST_ADDR_REG_OFFSET)
#define DMA_NUMBYTES_ADDR(BASE) ((void *)BASE + IDMA_REG64_2D_FRONTEND_NUM_BYTES_REG_OFFSET)
#define DMA_CONF_ADDR(BASE) ((void *)BASE + IDMA_REG64_2D_FRONTEND_CONF_REG_OFFSET)
#define DMA_STATUS_ADDR(BASE) ((void *)BASE + IDMA_REG64_2D_FRONTEND_STATUS_REG_OFFSET)
#define DMA_NEXTID_ADDR(BASE) ((void *)BASE + IDMA_REG64_2D_FRONTEND_NEXT_ID_REG_OFFSET)
#define DMA_DONE_ADDR(BASE) ((void *)BASE + IDMA_REG64_2D_FRONTEND_DONE_REG_OFFSET)
#define DMA_SRC_STRIDE_ADDR(BASE) ((void *)BASE + IDMA_REG64_2D_FRONTEND_STRIDE_SRC_REG_OFFSET)
#define DMA_DST_STRIDE_ADDR(BASE) ((void *)BASE + IDMA_REG64_2D_FRONTEND_STRIDE_DST_REG_OFFSET)
#define DMA_NUM_REPS_ADDR(BASE) ((void *)BASE + IDMA_REG64_2D_FRONTEND_NUM_REPETITIONS_REG_OFFSET)

#define DMA_CONF_DECOUPLE 0
#define DMA_CONF_DEBURST 0
#define DMA_CONF_SERIALIZE 0

#define X(NAME, BASE_ADDR) \
    extern volatile uint64_t *NAME##_dma_src_ptr(void); \
    extern volatile uint64_t *NAME##_dma_dst_ptr(void); \
    extern volatile uint64_t *NAME##_dma_num_bytes_ptr(void); \
    extern volatile uint64_t *NAME##_dma_conf_ptr(void); \
    extern volatile uint64_t *NAME##_dma_status_ptr(void); \
    extern volatile uint64_t *NAME##_dma_nextid_ptr(void); \
    extern volatile uint64_t *NAME##_dma_done_ptr(void); \
    extern volatile uint64_t *NAME##_dma_src_stride_ptr(void); \
    extern volatile uint64_t *NAME##_dma_dst_stride_ptr(void); \
    extern volatile uint64_t *NAME##_dma_num_reps_ptr(void); \
\
    extern uint64_t NAME##_dma_memcpy(uint64_t dst, uint64_t src, uint64_t size); \
    extern void NAME##_dma_blk_memcpy(uint64_t dst, uint64_t src, uint64_t size); \
    extern uint64_t NAME##_dma_2d_memcpy(uint64_t dst, uint64_t src, uint64_t size, \
                                         uint64_t dst_stride, uint64_t src_stride, \
                                         uint64_t num_reps); \
    extern void NAME##_dma_2d_blk_memcpy(uint64_t dst, uint64_t src, uint64_t size, \
                                         uint64_t dst_stride, uint64_t src_stride, \
                                         uint64_t num_reps); \
\
    inline volatile uint64_t *NAME##_dma_src_ptr(void) { \
        return (volatile uint64_t *)DMA_SRC_ADDR(BASE_ADDR); \
    } \
    inline volatile uint64_t *NAME##_dma_dst_ptr(void) { \
        return (volatile uint64_t *)DMA_DST_ADDR(BASE_ADDR); \
    } \
    inline volatile uint64_t *NAME##_dma_num_bytes_ptr(void) { \
        return (volatile uint64_t *)DMA_NUMBYTES_ADDR(BASE_ADDR); \
    } \
    inline volatile uint64_t *NAME##_dma_conf_ptr(void) { \
        return (volatile uint64_t *)DMA_CONF_ADDR(BASE_ADDR); \
    } \
    inline volatile uint64_t *NAME##_dma_status_ptr(void) { \
        return (volatile uint64_t *)DMA_STATUS_ADDR(BASE_ADDR); \
    } \
    inline volatile uint64_t *NAME##_dma_nextid_ptr(void) { \
        return (volatile uint64_t *)DMA_NEXTID_ADDR(BASE_ADDR); \
    } \
    inline volatile uint64_t *NAME##_dma_done_ptr(void) { \
        return (volatile uint64_t *)DMA_DONE_ADDR(BASE_ADDR); \
    } \
    inline volatile uint64_t *NAME##_dma_src_stride_ptr(void) { \
        return (volatile uint64_t *)DMA_SRC_STRIDE_ADDR(BASE_ADDR); \
    } \
    inline volatile uint64_t *NAME##_dma_dst_stride_ptr(void) { \
        return (volatile uint64_t *)DMA_DST_STRIDE_ADDR(BASE_ADDR); \
    } \
    inline volatile uint64_t *NAME##_dma_num_reps_ptr(void) { \
        return (volatile uint64_t *)DMA_NUM_REPS_ADDR(BASE_ADDR); \
    } \
\
    inline uint64_t NAME##_dma_memcpy(uint64_t dst, uint64_t src, uint64_t size) { \
        *(NAME##_dma_src_ptr()) = (uint64_t)src; \
        *(NAME##_dma_dst_ptr()) = (uint64_t)dst; \
        *(NAME##_dma_num_bytes_ptr()) = size; \
        *(NAME##_dma_num_reps_ptr()) = 0; \
        *(NAME##_dma_conf_ptr()) = \
            (DMA_CONF_DECOUPLE << IDMA_REG64_2D_FRONTEND_CONF_DECOUPLE_BIT) | \
            (DMA_CONF_DEBURST << IDMA_REG64_2D_FRONTEND_CONF_DEBURST_BIT) | \
            (DMA_CONF_SERIALIZE << IDMA_REG64_2D_FRONTEND_CONF_SERIALIZE_BIT); \
        return *(NAME##_dma_nextid_ptr()); \
    } \
\
    inline void NAME##_dma_blk_memcpy(uint64_t dst, uint64_t src, uint64_t size) { \
        volatile uint64_t tf_id = NAME##_dma_memcpy(dst, src, size); \
        while (*(NAME##_dma_done_ptr()) != tf_id) { \
            asm volatile("nop"); \
        } \
    } \
\
    inline uint64_t NAME##_dma_2d_memcpy(uint64_t dst, uint64_t src, uint64_t size, \
                                         uint64_t dst_stride, uint64_t src_stride, \
                                         uint64_t num_reps) { \
        *(NAME##_dma_src_ptr()) = (uint64_t)src; \
        *(NAME##_dma_dst_ptr()) = (uint64_t)dst; \
        *(NAME##_dma_num_bytes_ptr()) = size; \
        *(NAME##_dma_conf_ptr()) = \
            (DMA_CONF_DECOUPLE << IDMA_REG64_2D_FRONTEND_CONF_DECOUPLE_BIT) | \
            (DMA_CONF_DEBURST << IDMA_REG64_2D_FRONTEND_CONF_DEBURST_BIT) | \
            (DMA_CONF_SERIALIZE << IDMA_REG64_2D_FRONTEND_CONF_SERIALIZE_BIT); \
        *(NAME##_dma_src_stride_ptr()) = src_stride; \
        *(NAME##_dma_dst_stride_ptr()) = dst_stride; \
        *(NAME##_dma_num_reps_ptr()) = num_reps; \
        return *(NAME##_dma_nextid_ptr()); \
    } \
\
    inline void NAME##_dma_2d_blk_memcpy(uint64_t dst, uint64_t src, uint64_t size, \
                                         uint64_t dst_stride, uint64_t src_stride, \
                                         uint64_t num_reps) { \
        volatile uint64_t tf_id = \
            NAME##_dma_2d_memcpy(dst, src, size, dst_stride, src_stride, num_reps); \
        while (*(NAME##_dma_done_ptr()) != tf_id) { \
            asm volatile("nop"); \
        } \
    } \
\
    inline uint64_t NAME##_dma_get_status(void) { \
        return *(NAME##_dma_status_ptr()); \
    }

X(sys, &__base_dma);

#undef X
