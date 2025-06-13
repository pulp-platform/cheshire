#pragma once

#include <stdint.h>
#include <stddef.h>
#include <string.h>

#include "printf.h"


#define SDHC_DEBUG
#define SDMMC_DEBUG

#ifdef SDHC_DEBUG
extern int debug_funcs;
extern int sdhcdebug;
#define DFUNC(name) if (debug_funcs) { printf(#name"\n"); }
#else
#define DFUNC(name)
#endif

typedef unsigned char u_char;
typedef unsigned short u_short;
typedef unsigned int u_int;
typedef unsigned long u_long;

typedef uint8_t  u_int8_t;
typedef uint16_t u_int16_t;
typedef uint32_t u_int32_t;
typedef uint64_t u_int64_t;

#define EINVAL 1
#define ETIMEDOUT 2
#define EIO 3
#define ENOMEM 4
#define ENODEV 5

#define	UINT_MAX	0xffffffffU
#define	INT_MAX		0x7fffffff
#define	INT_MIN		(-0x7fffffff-1)

#define MAXPHYS		(64 * 1024)

#define	__packed	__attribute__((__packed__))
#define	__aligned(x)	__attribute__((__aligned__(x)))

#define DVACT_SUSPEND 1
#define DVACT_RESUME  2

#define	DETACH_FORCE 1
#define	DETACH_QUIET 2

#define KASSERT(...)

#define SET(t, f)	((t) |= (f))
#define CLR(t, f)	((t) &= ~(f))
#define ISSET(t, f)	((t) & (f))

#define nitems(_a)	(sizeof((_a)) / sizeof((_a)[0]))
// int bzero(void*, int);
// int bcopy(void*, void*, int);

// #define	MIN(a,b) (((a)<(b))?(a):(b))
// #define	MAX(a,b) (((a)>(b))?(a):(b))

static inline uint32_t be32toh(uint32_t in) {
    return ((in & 0xff) << 24) | \
            ((in & 0xff00) << 8) | \
            ((in & 0xff0000) >> 8) | \
            ((in & 0xff000000) >> 24);
}

#define ASSERT_OK(call) { int err = (call); if (err != 0) { printf(#call " errored with err=%x\n", err); return err; } }

// static inline void* _memset(void* data, uint8_t x, size_t size)
// {
//     return memset(data, x, size);
//     // for (size_t i = 0; i < size; ++i)
//     //     ((uint8_t*) data)[i] = x;
    
//     // return size;
// }

// static inline int bzero(void* data, size_t size)
// {
//     return _memset(data, 0, size);
// }


// static inline void* _memcpy(void* dst, void* src, size_t size) {
//     return memcpy(dst, src, size);
//     // for (size_t i = 0; i < size; ++i)
//     //     ((uint8_t*) dst)[i] = ((uint8_t*) src)[i];
    
//     // return size;
// }

// static inline int bcopy(void* src, void* dst, size_t size) {
//     return _memcpy(dst, src, size);
// }