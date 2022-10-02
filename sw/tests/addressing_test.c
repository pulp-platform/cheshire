// Copyright 2022 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Authors:
// - Nicole Narr <narrn@ethz.ch>
// - Christopher Reinwardt <creinwar@ethz.ch>
// Date:   05.12.2022

#include "uart.h"
#include "printf.h"
#include "addr_specs.h"

char uart_initialized = 0;

void __attribute__((aligned(4))) trap_vector(void)
{
    long int mcause = 0, mepc = 0, mip = 0, mie = 0, mstatus = 0, mtval = 0;

    asm volatile(
        "csrrs t0, mcause, x0\n     \
         sd t0, %0\n                \
         csrrs t0, mepc, x0\n       \
         sd t0, %1\n                \
         csrrs t0, mip, x0\n        \
         sd t0, %2\n                \
         csrrs t0, mie, x0\n        \
         sd t0, %3\n                \
         csrrs t0, mstatus, x0\n    \
         sd t0, %4\n                \
         csrrs t0, mtval, x0\n      \
         sd t0, %5\n"
         : "=m" (mcause),
           "=m" (mepc),
           "=m" (mip),
           "=m" (mie),
           "=m" (mstatus),
           "=m" (mtval)
         :: "t0");

    // Interrupt with exception code 7 == Machine Mode Timer Interrupt
    if(mcause < 0 && (mcause << 1) == 14){
        // Handle interrupt by disabling the timer interrupt and returning
        asm volatile(
            "addi t0, x0, 128\n     \
             csrrc x0, mie, t0\n"
             ::: "t0"
        );
        return;
    } else {
        if(uart_initialized){
            printf_("Hello from the trap_vector :)\r\n");
            printf_("mcause:    0x%lx\r\n", mcause);
            printf_("mepc:      0x%lx\r\n", mepc);
            printf_("mip:       0x%lx\r\n", mip);
            printf_("mie:       0x%lx\r\n", mie);
            printf_("mstatus:   0x%lx\r\n", mstatus);
            printf_("mtval:     0x%lx\r\n", mtval);
        }
    }

    while(1){
        asm volatile("wfi\n" :::);
    }

    return;
}

static unsigned long int errors = 0;
static unsigned long int total_errors = 0;

void test_64_bit_access(void *addr, int length)
{
    volatile unsigned long int *word = (unsigned long int *) addr;
    unsigned long int test_p = 0xAAAAAAAAAAAAAAAA;
    unsigned long int test_n = 0x5555555555555555;

    printf_("\tTesting 64 bit accesses\r\n");
    for(unsigned long int i = 0; i < length/8; i++){
        word[i] = test_p;
        if(word[i] != test_p){
            printf_("\t!!! Address: 0x%lx, Expected: 0x%lx, Got: 0x%lx\r\n", &word[i], test_p, word[i]);
            errors++;
        }

        word[i] = test_n;
        if(word[i] != test_n){
            printf_("\t!!! Address: 0x%lx, Expected: 0x%lx, Got: 0x%lx\r\n", &word[i], test_n, word[i]);
            errors++;
        }
    }
}

void test_32_bit_access(void *addr, int length)
{
    volatile unsigned int *word = (unsigned int *) addr;
    unsigned int test_p = 0xAAAAAAAA;
    unsigned int test_n = 0x55555555;

    printf_("\tTesting 32 bit accesses\r\n");
    for(unsigned long int i = 0; i < length/4; i++){
        word[i] = test_p;
        if(word[i] != test_p){
            printf_("\t!!! Address: 0x%lx, Expected: 0x%lx, Got: 0x%lx\r\n", &word[i], test_p, word[i]);
            errors++;
        }

        word[i] = test_n;
        if(word[i] != test_n){
            printf_("\t!!! Address: 0x%lx, Expected: 0x%lx, Got: 0x%lx\r\n", &word[i], test_n, word[i]);
            errors++;
        }
    }
}

void test_16_bit_access(void *addr, int length)
{
    volatile unsigned short *word = (unsigned short *) addr;
    unsigned short test_p = 0xAAAA;
    unsigned short test_n = 0x5555;

    printf_("\tTesting 16 bit accesses\r\n");
    for(unsigned long int i = 0; i < length/2; i++){
        word[i] = test_p;
        if(word[i] != test_p){
            printf_("\t!!! Address: 0x%lx, Expected: 0x%lx, Got: 0x%lx\r\n", &word[i], test_p, word[i]);
            errors++;
        }

        word[i] = test_n;
        if(word[i] != test_n){
            printf_("\t!!! Address: 0x%lx, Expected: 0x%lx, Got: 0x%lx\r\n", &word[i], test_n, word[i]);
            errors++;
        }
    }
}

void test_8_bit_access(void *addr, int length)
{
    volatile unsigned char *word = (unsigned char *) addr;
    unsigned char test_p = 0xAA;
    unsigned char test_n = 0x55;

    printf_("\tTesting 8 bit accesses\r\n");
    for(unsigned long int i = 0; i < length; i++){
        word[i] = test_p;
        if(word[i] != test_p){
            printf_("\t!!! Address: 0x%lx, Expected: 0x%lx, Got: 0x%lx\r\n", &word[i], test_p, word[i]);
            errors++;
        }

        word[i] = test_n;
        if(word[i] != test_n){
            printf_("\t!!! Address: 0x%lx, Expected: 0x%lx, Got: 0x%lx\r\n", &word[i], test_n, word[i]);
            errors++;
        }
    }
}

void test_64_32_subaccess(void *addr, int length)
{
    volatile unsigned long int *word = (unsigned long int *) addr;
    volatile unsigned int *subword = (unsigned int *) addr;
    unsigned long int test_p = 0xAAAAAAAAAAAAAAAA;
    unsigned long int test_n = 0x5555555555555555;
    unsigned long int merged = 0;
    int subwords = 64/32;

    printf_("\tTesting clean 32 bit sub-accesses\r\n");
    for(unsigned long int i = 0; i < length/8; i++){
        for(int j = 0; j < subwords; j++){
            word[i] = test_p;
            subword[subwords*i+j] = (unsigned int) test_n;
            merged = 0;

            for(int k = 0; k < subwords; k++){
                if(k == j){
                    merged |= test_n & (0xFFFFFFFFL << (k*32));
                } else {
                    merged |= test_p & (0xFFFFFFFFL << (k*32));
                }
            }

            if(word[i] != merged){
                printf_("\t!!! Address: 0x%lx, Expected: 0x%lx, Got: 0x%lx\r\n", &word[i], merged, word[i]);
                errors++;
            }

            word[i] = test_n;
            subword[subwords*i+j] = (unsigned int) test_p;
            merged = 0;

            for(int k = 0; k < subwords; k++){
                if(k == j){
                    merged |= test_p & (0xFFFFFFFFL << (k*32));
                } else {
                    merged |= test_n & (0xFFFFFFFFL << (k*32));
                }
            }

            if(word[i] != merged){
                printf_("\t!!! Address: 0x%lx, Expected: 0x%lx, Got: 0x%lx\r\n", &word[i], merged, word[i]);
                errors++;
            }
        }
    }
}

void test_64_16_subaccess(void *addr, int length)
{
    volatile unsigned long int *word = (unsigned long int *) addr;
    volatile unsigned short *subword = (unsigned short *) addr;
    unsigned long int test_p = 0xAAAAAAAAAAAAAAAA;
    unsigned long int test_n = 0x5555555555555555;
    unsigned long int merged = 0;
    int subwords = 64/16;

    printf_("\tTesting clean 16 bit sub-accesses\r\n");
    for(unsigned long int i = 0; i < length/8; i++){
        for(int j = 0; j < subwords; j++){
            word[i] = test_p;
            subword[subwords*i+j] = (unsigned short) test_n;
            merged = 0;

            for(int k = 0; k < subwords; k++){
                if(k == j){
                    merged |= test_n & (0xFFFFL << (k*16));
                } else {
                    merged |= test_p & (0xFFFFL << (k*16));
                }
            }

            if(word[i] != merged){
                printf_("\t!!! Address: 0x%lx, Expected: 0x%lx, Got: 0x%lx\r\n", &word[i], merged, word[i]);
                errors++;
            }

            word[i] = test_n;
            subword[subwords*i+j] = (unsigned short) test_p;
            merged = 0;

            for(int k = 0; k < subwords; k++){
                if(k == j){
                    merged |= test_p & (0xFFFFL << (k*16));
                } else {
                    merged |= test_n & (0xFFFFL << (k*16));
                }
            }

            if(word[i] != merged){
                printf_("\t!!! Address: 0x%lx, Expected: 0x%lx, Got: 0x%lx\r\n", &word[i], merged, word[i]);
                errors++;
            }
        }
    }
}

void test_64_8_subaccess(void *addr, int length)
{
    volatile unsigned long int *word = (unsigned long int *) addr;
    volatile unsigned char *subword = (unsigned char *) addr;
    unsigned long int test_p = 0xAAAAAAAAAAAAAAAA;
    unsigned long int test_n = 0x5555555555555555;
    unsigned long int merged = 0;
    int subwords = 64/8;

    printf_("\tTesting clean 8 bit sub-accesses\r\n");
    for(unsigned long int i = 0; i < length/8; i++){
        for(int j = 0; j < subwords; j++){
            word[i] = test_p;
            subword[subwords*i+j] = (unsigned char) test_n;
            merged = 0;

            for(int k = 0; k < subwords; k++){
                if(k == j){
                    merged |= test_n & (0xFFL << (k*8));
                } else {
                    merged |= test_p & (0xFFL << (k*8));
                }
            }

            if(word[i] != merged){
                printf_("\t!!! Address: 0x%lx, Expected: 0x%lx, Got: 0x%lx\r\n", &word[i], merged, word[i]);
                errors++;
            }

            word[i] = test_n;
            subword[subwords*i+j] = (unsigned char) test_p;
            merged = 0;

            for(int k = 0; k < subwords; k++){
                if(k == j){
                    merged |= test_p & (0xFFL << (k*8));
                } else {
                    merged |= test_n & (0xFFL << (k*8));
                }
            }

            if(word[i] != merged){
                printf_("\t!!! Address: 0x%lx, Expected: 0x%lx, Got: 0x%lx\r\n", &word[i], merged, word[i]);
                errors++;
            }
        }
    }
}

void test_32_16_subaccess(void *addr, int length)
{
    volatile unsigned int *word = (unsigned int *) addr;
    volatile unsigned short *subword = (unsigned short *) addr;
    unsigned int test_p = 0xAAAAAAAA;
    unsigned int test_n = 0x55555555;
    unsigned int merged = 0;
    int subwords = 32/16;

    printf_("\tTesting clean 16 bit sub-accesses\r\n");
    for(unsigned long int i = 0; i < length/4; i++){
        for(int j = 0; j < subwords; j++){
            word[i] = test_p;
            subword[subwords*i+j] = (unsigned short) test_n;
            merged = 0;

            for(int k = 0; k < subwords; k++){
                if(k == j){
                    merged |= test_n & (0xFFFFL << (k*16));
                } else {
                    merged |= test_p & (0xFFFFL << (k*16));
                }
            }

            if(word[i] != merged){
                printf_("\t!!! Address: 0x%lx, Expected: 0x%lx, Got: 0x%lx\r\n", &word[i], merged, word[i]);
                errors++;
            }

            word[i] = test_n;
            subword[subwords*i+j] = (unsigned short) test_p;
            merged = 0;

            for(int k = 0; k < subwords; k++){
                if(k == j){
                    merged |= test_p & (0xFFFFL << (k*16));
                } else {
                    merged |= test_n & (0xFFFFL << (k*16));
                }
            }

            if(word[i] != merged){
                printf_("\t!!! Address: 0x%lx, Expected: 0x%lx, Got: 0x%lx\r\n", &word[i], merged, word[i]);
                errors++;
            }
        }
    }
}

void test_32_8_subaccess(void *addr, int length)
{
    volatile unsigned int *word = (unsigned int *) addr;
    volatile unsigned char *subword = (unsigned char *) addr;
    unsigned int test_p = 0xAAAAAAAA;
    unsigned int test_n = 0x55555555;
    unsigned int merged = 0;
    int subwords = 32/8;

    printf_("\tTesting clean 8 bit sub-accesses\r\n");
    for(unsigned long int i = 0; i < length/4; i++){
        for(int j = 0; j < subwords; j++){
            word[i] = test_p;
            subword[subwords*i+j] = (unsigned char) test_n;
            merged = 0;

            for(int k = 0; k < subwords; k++){
                if(k == j){
                    merged |= test_n & (0xFFL << (k*8));
                } else {
                    merged |= test_p & (0xFFL << (k*8));
                }
            }

            if(word[i] != merged){
                printf_("\t!!! Address: 0x%lx, Expected: 0x%lx, Got: 0x%lx\r\n", &word[i], merged, word[i]);
                errors++;
            }

            word[i] = test_n;
            subword[subwords*i+j] = (unsigned char) test_p;
            merged = 0;

            for(int k = 0; k < subwords; k++){
                if(k == j){
                    merged |= test_p & (0xFFL << (k*8));
                } else {
                    merged |= test_n & (0xFFL << (k*8));
                }
            }

            if(word[i] != merged){
                printf_("\t!!! Address: 0x%lx, Expected: 0x%lx, Got: 0x%lx\r\n", &word[i], merged, word[i]);
                errors++;
            }
        }
    }
}

void test_16_8_subaccess(void *addr, int length)
{
    volatile unsigned short *word = (unsigned short *) addr;
    volatile unsigned char *subword = (unsigned char *) addr;
    unsigned short test_p = 0xAAAA;
    unsigned short test_n = 0x5555;
    unsigned short merged = 0;
    int subwords = 16/8;

    printf_("\tTesting clean 8 bit sub-accesses\r\n");
    for(unsigned long int i = 0; i < length/2; i++){
        for(int j = 0; j < subwords; j++){
            word[i] = test_p;
            subword[subwords*i+j] = (unsigned char) test_n;
            merged = 0;

            for(int k = 0; k < subwords; k++){
                if(k == j){
                    merged |= test_n & (0xFFL << (k*8));
                } else {
                    merged |= test_p & (0xFFL << (k*8));
                }
            }

            if(word[i] != merged){
                printf_("\t!!! Address: 0x%lx, Expected: 0x%lx, Got: 0x%lx\r\n", &word[i], merged, word[i]);
                errors++;
            }

            word[i] = test_n;
            subword[subwords*i+j] = (unsigned char) test_p;
            merged = 0;

            for(int k = 0; k < subwords; k++){
                if(k == j){
                    merged |= test_p & (0xFFL << (k*8));
                } else {
                    merged |= test_n & (0xFFL << (k*8));
                }
            }

            if(word[i] != merged){
                printf_("\t!!! Address: 0x%lx, Expected: 0x%lx, Got: 0x%lx\r\n", &word[i], merged, word[i]);
                errors++;
            }
        }
    }
}

void read_64_bit_access(void *addr, int length)
{
    volatile unsigned long int *word = (unsigned long int *) addr;
    printf_("Dumping data in 64 bit words\r\n");
    for(unsigned long int i = 0; i < length/8; i++){
        printf_("\tAddress: 0x%lx, Data: 0x%lx\r\n", &word[i], word[i]);
    }
}

void read_32_bit_access(void *addr, int length)
{
    volatile unsigned int *word = (unsigned int *) addr;
    printf_("Dumping data in 32 bit words\r\n");
    for(unsigned long int i = 0; i < length/4; i++){
        printf_("\tAddress: 0x%lx, Data: 0x%x\r\n", &word[i], word[i]);
    } 
}

void read_16_bit_access(void *addr, int length)
{
    volatile unsigned short *word = (unsigned short *) addr;
    printf_("Dumping data in 16 bit words\r\n");
    for(unsigned long int i = 0; i < length/2; i++){
        printf_("\tAddress: 0x%lx, Data: 0x%x\r\n", &word[i], word[i]);
    }
}

void read_8_bit_access(void *addr, int length)
{
    volatile unsigned char *word = (unsigned char *) addr;
    printf_("Dumping data in 8 bit words\r\n");
    for(unsigned long int i = 0; i < length; i++){
        printf_("\tAddress: 0x%lx, Data: 0x%x\r\n", &word[i], word[i]);
    } 
}

int main(void)
{
    //init_uart(200000000, 115200);
    init_uart(50000000, 115200);
    uart_initialized = 1;
    printf_("Testing addressing throughout the system\r\n");

    // Disable D-Cache
    asm volatile(
            "addi t0, x0, 1\n   \
             csrrc x0, 0x701, t0\n"
             ::: "t0"
    );

    test_addr_t *ta = test_addresses;

    // Start the tedious testing
    for(unsigned int i = 0; i < test_addresses_length; i++){
        printf_("\r\nTesting 0x%lx(%d)\r\n", ta[i].addr, ta[i].length);

        // Read-Write access => We can actually perform tests
        if(ta[i].access == 3){
            if(ta[i].width >= 64 && ta[i].alignment <= 64){
                test_64_bit_access(ta[i].addr, ta[i].length);

                if(ta[i].alignment <= 32){
                    test_64_32_subaccess(ta[i].addr, ta[i].length);
                }
                if(ta[i].alignment <= 16){
                    test_64_16_subaccess(ta[i].addr, ta[i].length);
                }
                if(ta[i].alignment <= 8){
                    test_64_8_subaccess(ta[i].addr, ta[i].length);
                }
            }

            if(ta[i].width >= 32 && ta[i].alignment <= 32){
                test_32_bit_access(ta[i].addr, ta[i].length);

                if(ta[i].alignment <= 16){
                    test_32_16_subaccess(ta[i].addr, ta[i].length);
                }
                if(ta[i].alignment <= 8){
                    test_32_8_subaccess(ta[i].addr, ta[i].length);
                }
            }

            if(ta[i].width >= 16 && ta[i].alignment <= 16){
                test_16_bit_access(ta[i].addr, ta[i].length);

                if(ta[i].alignment <= 8){
                    test_16_8_subaccess(ta[i].addr, ta[i].length);
                }
            }

            if(ta[i].width >= 8 && ta[i].alignment <= 8){
                test_8_bit_access(ta[i].addr, ta[i].length);
            }
        } else if(ta[i].access == 2){
            if(ta[i].width >= 64 && ta[i].alignment <= 64){
                read_64_bit_access(ta[i].addr, ta[i].length);
            }

            if(ta[i].width >= 32 && ta[i].alignment <= 32){
                read_32_bit_access(ta[i].addr, ta[i].length);
            }

            if(ta[i].width >= 16 && ta[i].alignment <= 16){
                read_16_bit_access(ta[i].addr, ta[i].length);
            }

            if(ta[i].width >= 8 && ta[i].alignment <= 8){
                read_8_bit_access(ta[i].addr, ta[i].length);
            }
        } else {
            printf_("\tCannot test with access rights %d\r\n", ta[i].access);
        }
        printf("---- %u Errors ----\r\n\r\n", errors);
        total_errors += errors;
        errors = 0;
    }

    printf_("Finished test with %u errors.\r\n", total_errors);

    return total_errors; 
}


