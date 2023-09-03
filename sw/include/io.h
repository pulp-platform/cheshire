// Copyright 2023 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Robert Balas <balasr@iis.ee.ethz.ch>
//

/* Description: Memory mapped register I/O access
 */

#ifndef __IO_H
#define __IO_H

#include <stdint.h>


/* generic I/O write */
static inline void writeb(uint8_t val, uintptr_t addr)
{
	asm volatile("sb %0, 0(%1)"
		     :
		     : "r"(val), "r"((volatile uint8_t *)addr)
		     : "memory");
}

static inline void writeh(uint16_t val, uintptr_t addr)
{
	asm volatile("sh %0, 0(%1)"
		     :
		     : "r"(val), "r"((volatile uint16_t *)addr)
		     : "memory");
}

static inline void writew(uint32_t val, uintptr_t addr)
{
	asm volatile("sw %0, 0(%1)"
		     :
		     : "r"(val), "r"((volatile uint32_t *)addr)
		     : "memory");
}

static inline void writed(uint64_t val, uintptr_t addr)
{
	asm volatile("sd %0, 0(%1)"
		     :
		     : "r"(val), "r"((volatile uint64_t *)addr)
		     : "memory");
}

/* generic I/O read */
static inline uint8_t readb(const uintptr_t addr)
{
	uint8_t val;

	asm volatile("lb %0, 0(%1)"
		     : "=r"(val)
		     : "r"((const volatile uint8_t *)addr)
		     : "memory");
	return val;
}

static inline uint16_t readh(const uintptr_t addr)
{
	uint16_t val;

	asm volatile("lh %0, 0(%1)"
		     : "=r"(val)
		     : "r"((const volatile uint16_t *)addr)
		     : "memory");
	return val;
}

static inline uint32_t readw(const uintptr_t addr)
{
	uint32_t val;

	asm volatile("lw %0, 0(%1)"
		     : "=r"(val)
		     : "r"((const volatile uint32_t *)addr)
		     : "memory");
	return val;
}

static inline uint64_t readd(const uintptr_t addr)
{
	uint64_t val;

	asm volatile("ld %0, 0(%1)"
		     : "=r"(val)
		     : "r"((const volatile uint64_t *)addr)
		     : "memory");
	return val;
}
#endif
