#include "regs/cheshire.h"
#include "dif/clint.h"
#include "params.h"
#include "util.h"

#include "matmul_data.h"
int sN = 32;

const int CHKSUM = 10614161;
const int ITERATIONS = 16;


// Get cycle count since reset
static inline uint64_t get_minstret() {
    uint64_t reg;
    asm volatile("csrr %0, minstret" : "=r"(reg)::"memory");
    return reg;
}

#define ROWOP(c0, c1, c2, c3) \
    bb0 = &b[(n+0)*b_colstride + k]; \
    bb1 = &b[(n+1)*b_colstride + k]; \
    bb2 = &b[(n+2)*b_colstride + k]; \
    bb3 = &b[(n+3)*b_colstride + k]; \
    asm volatile( \
        "fld  f0,  0(%[bb0]) \n" \
        "fld  f1,  0(%[bb1]) \n" \
        "fld  f2,  0(%[bb2]) \n" \
        "fld  f3,  0(%[bb3]) \n" \
        "fld  f4,  8(%[bb0]) \n" \
        "fld  f5,  8(%[bb1]) \n" \
        "fld  f6,  8(%[bb2]) \n" \
        "fld  f7,  8(%[bb3]) \n" \
        "fmadd.d %[cx0], %[ax0], f0, %[cx0] \n" \
        "fmadd.d %[cx1], %[ax0], f1, %[cx1] \n" \
        "fmadd.d %[cx2], %[ax0], f2, %[cx2] \n" \
        "fmadd.d %[cx3], %[ax0], f3, %[cx3] \n" \
        "fmadd.d %[cx0], %[ax1], f4, %[cx0] \n" \
        "fmadd.d %[cx1], %[ax1], f5, %[cx1] \n" \
        "fmadd.d %[cx2], %[ax1], f6, %[cx2] \n" \
        "fmadd.d %[cx3], %[ax1], f7, %[cx3] \n" \
        "fld  f0, 16(%[bb0]) \n" \
        "fld  f1, 16(%[bb1]) \n" \
        "fld  f2, 16(%[bb2]) \n" \
        "fld  f3, 16(%[bb3]) \n" \
        "fld  f4, 24(%[bb0]) \n" \
        "fld  f5, 24(%[bb1]) \n" \
        "fld  f6, 24(%[bb2]) \n" \
        "fld  f7, 24(%[bb3]) \n" \
        "fmadd.d %[cx0], %[ax2], f0, %[cx0] \n" \
        "fmadd.d %[cx1], %[ax2], f1, %[cx1] \n" \
        "fmadd.d %[cx2], %[ax2], f2, %[cx2] \n" \
        "fmadd.d %[cx3], %[ax2], f3, %[cx3] \n" \
        "fmadd.d %[cx0], %[ax3], f4, %[cx0] \n" \
        "fmadd.d %[cx1], %[ax3], f5, %[cx1] \n" \
        "fmadd.d %[cx2], %[ax3], f6, %[cx2] \n" \
        "fmadd.d %[cx3], %[ax3], f7, %[cx3] \n" \
        : \
          [bb0]"+&r"(bb0), [bb1]"+&r"(bb1), [bb2]"+&r"(bb2), [bb3]"+&r"(bb3), \
            [cx0]"+&f"(c0), [cx1]"+&f"(c1), [cx2]"+&f"(c2), [cx3]"+&f"(c3), \
            [ax0]"+&f"(ax[0]), [ax1]"+&f"(ax[1]), [ax2]"+&f"(ax[2]), [ax3]"+&f"(ax[3]) \
        :: "f0", "f1", "f2", "f3", "f4", "f5", "f6", "f7" \
    ); \

int __attribute__ ((visibility("hidden"))) __attribute__((noinline)) mmopt(
    double* __restrict a,
    double* __restrict b,
    double* __restrict c,
    int      N,
    int      M,
    int      K,
    int      a_rowstride,
    int      b_colstride,
    int      c_rowstride
) {
    for (int m = 0; m < M; m+=4)
    for (int n = 0; n < N; n+=4) {
        // One output block per n-m pair

        register double cb0  = c[c_rowstride*(m+0)+n+0];
        register double cb1  = c[c_rowstride*(m+0)+n+1];
        register double cb2  = c[c_rowstride*(m+0)+n+2];
        register double cb3  = c[c_rowstride*(m+0)+n+3];
        register double cb4  = c[c_rowstride*(m+1)+n+0];
        register double cb5  = c[c_rowstride*(m+1)+n+1];
        register double cb6  = c[c_rowstride*(m+1)+n+2];
        register double cb7  = c[c_rowstride*(m+1)+n+3];
        register double cb8  = c[c_rowstride*(m+2)+n+0];
        register double cb9  = c[c_rowstride*(m+2)+n+1];
        register double cb10 = c[c_rowstride*(m+2)+n+2];
        register double cb11 = c[c_rowstride*(m+2)+n+3];
        register double cb12 = c[c_rowstride*(m+3)+n+0];
        register double cb13 = c[c_rowstride*(m+3)+n+1];
        register double cb14 = c[c_rowstride*(m+3)+n+2];
        register double cb15 = c[c_rowstride*(m+3)+n+3];

        for (int k = 0; k < K; k+=4) {
            register double *bb0, *bb1, *bb2, *bb3;

            register double* ax = &a[m*a_rowstride + k];
            ROWOP(cb0, cb1, cb2, cb3)

            ax += a_rowstride;
            ROWOP(cb4, cb5, cb6, cb7)

            ax += a_rowstride;
            ROWOP(cb8, cb9, cb10, cb11)

            ax += a_rowstride;
            ROWOP(cb12, cb13, cb14, cb15)
        }
        // Write back output block
        c[(m+0)*c_rowstride + (n+0)] = cb0;
        c[(m+0)*c_rowstride + (n+1)] = cb1;
        c[(m+0)*c_rowstride + (n+2)] = cb2;
        c[(m+0)*c_rowstride + (n+3)] = cb3;
        c[(m+1)*c_rowstride + (n+0)] = cb4;
        c[(m+1)*c_rowstride + (n+1)] = cb5;
        c[(m+1)*c_rowstride + (n+2)] = cb6;
        c[(m+1)*c_rowstride + (n+3)] = cb7;
        c[(m+2)*c_rowstride + (n+0)] = cb8;
        c[(m+2)*c_rowstride + (n+1)] = cb9;
        c[(m+2)*c_rowstride + (n+2)] = cb10;
        c[(m+2)*c_rowstride + (n+3)] = cb11;
        c[(m+3)*c_rowstride + (n+0)] = cb12;
        c[(m+3)*c_rowstride + (n+1)] = cb13;
        c[(m+3)*c_rowstride + (n+2)] = cb14;
        c[(m+3)*c_rowstride + (n+3)] = cb15;
    }
    return 0;
}

int main(void) {

    // Get start cycle count
    uint32_t instret = get_minstret();
    uint32_t cycles = get_mcycle();

    for (int i = 0; i < ITERATIONS; ++i) {
        mmopt(
            float_data_a,
            float_data_b,
            float_data_c,
            sN, sN, sN,
            sN, sN, sN
        );
    }

    // Get end cycle count
    cycles = get_mcycle() - cycles;
    instret = get_minstret() - instret;

    // Compute checksum
    double checksum = 0.0;
    for (int y = 0; y < sN; y++) {
        double sign = (y & 1) ? -1.0 : 1.0;
        for (int x = 0; x < sN; x++) {
            checksum += sign*1000.0*1000.0*float_data_c[y*sN+x];
        }
    }

    // Scale checksum to int.
    // Take ~2 digits off (divide by 128) to account for FP rounding.
    uint64_t chkint = (uint64_t)(checksum) >> 7;

    // Check return
    return (chkint != CHKSUM);
}
