// Copyright 2023 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Raphael Roth <narrn@student.ethz.ch>
//
// Simple Test where the sMMU has to copy a small request

#include <stdint.h>
#include <stdio.h>
#include "regs/cheshire.h"
#include "dif/clint.h"
#include "dif/uart.h"
#include "dif/dma.h"
#include "params.h"
#include "util.h"

// Define the Root Acess of the Page Table
#define PAGE_TABLE_ROOT_ADRESSE 0x0000000080000000


#define RV48

// Part 1: Copy One Page from SRC to DST


// Function to set one page table entry!
void generate_page_table_entry(void * ptrTable, uint64_t offsetEntry, uint64_t ppn, uint64_t execute, uint64_t read, uint64_t write, uint64_t user);
uint64_t extract_vpn(uint64_t va, int lvl);
void convert_hex_to_string(uint64_t NumberToConvert, char * ptrData, uint32_t digits);

int main(void) {
    char start[] = "Manually Setup Page Table Example\r\n";
    char end_suc[] = "Data Copied Successfully\r\n";
    char end_fail[] = "Data Copied Failed\r\n";
    char buf[] = "Cycle Num: 0x0000000000000000\r\n";
    uint64_t start_cycle = 0;
    uint64_t end_cycle = 0;

    // Setup the USART Frequency
    uint32_t rtc_freq = *reg32(&__base_regs, CHESHIRE_RTC_FREQ_REG_OFFSET);
    uint64_t reset_freq = clint_get_core_freq(rtc_freq, 2500);
    uart_init(&__base_uart, reset_freq, __BOOT_BAUDRATE);

    // Write the start Message
    uart_write_str(&__base_uart, start, sizeof(start));
    uart_write_flush(&__base_uart);

    // Fixed Adresses - Do not change !!(OR OTHERWISE CHANGE PT TOO)!!
    void * pa_src_adr = (void *) 0x0000000081000000;
    void * pa_dst_adr = (void *) 0x0000000084FFF800;
    void * va_src_adr = pa_src_adr + 0x0000000200000000;
    void * va_dst_adr = pa_dst_adr + 0x0000000200000000;
    int length_copy = 4096; // Up to 0x2800 bytes

    // Write Pointers
    volatile uint8_t* write_ptr_src;
    volatile uint8_t* write_ptr_dst;

    // SRC - MAPPING: 0x0000000081000000 - 0x0000000081002FFF
    // DST - MAPPING: 0x0000000084FFF000 - 0x0000000085001FFF

/*
    Setup all required Page Table Entries
    By Default --> Our Virtual Adresses are PA_ADR + 0x2_0000_0000
    In this Case:
    Src Adres = 0x0000000281000000
    Dst Adres = 0x0000000284FFF800

    To be able to copy slightly more than 4KB reserve the next few Page Table Entries Too
    We are required therefor to map the following pages:
    0x000281000000 - 0x000281001000 - 0x000281002000
    0x000284FFF000 - 0x000285000000 - 0x000285001000

    We have a RV48 system, so 4 level to traverse
    Per level we need to calculate the vpn

    vpn     | 36    | 000281000 | 000284FFF | 000285000 | 000250000 | 000281002 | 000285001 |
    -----------------------------------------------------------------------------------------
    vpn[3]  | 9     | 000       | 000       | 000       | 000       | 000       | 000       |
    -----------------------------------------------------------------------------------------
    vpn[2]  | 9     | 00a       | 00a       | 00a       | 00a       | 00a       | 00a       |
    -----------------------------------------------------------------------------------------
    vpn[1]  | 9     | 008       | 027       | 008       | 028       | 008       | 028       |
    -----------------------------------------------------------------------------------------
    vpn[0]  | 9     | 000       | 1FF       | 001       | 000       | 002       | 001       |

    From the List above we see that we need to map!

    See the Table below which entries we require for the page table to function properly and on which adress they are populated
    ---------------------------------------------------------------------------------------------------------------------------
    |   PAGE_TABLE_ROOT_ADRESSE + 0x0000    | Main Root Page Table | Entries occupied: 000* | src & dst adresse | off: 0x1000 |
    ---------------------------------------------------------------------------------------------------------------------------
    |   PAGE_TABLE_ROOT_ADRESSE + 0x1000    | Level 2 - Entrie     | Entries occupied: 00a* | src adresse       | off: 0x2000 |
    ---------------------------------------------------------------------------------------------------------------------------
    |   PAGE_TABLE_ROOT_ADRESSE + 0x2000    | Level 1 - Entrie     | Entries occupied: 008* | src adresse       | off: 0x4000 |
    |   PAGE_TABLE_ROOT_ADRESSE + 0x2000    | Level 1 - Entrie     | Entries occupied: 027* | dst adresse       | off: 0x5000 |
    |   PAGE_TABLE_ROOT_ADRESSE + 0x2000    | Level 1 - Entrie     | Entries occupied: 028* | dst adresse       | off: 0x6000 |
    ---------------------------------------------------------------------------------------------------------------------------
    |   PAGE_TABLE_ROOT_ADRESSE + 0x4000    | Level 0 - Entrie     | Entries occupied: 000* | src adresse       | off: leaf   |
    |   PAGE_TABLE_ROOT_ADRESSE + 0x4000    | Level 0 - Entrie     | Entries occupied: 001* | src adresse       | off: leaf   |
    |   PAGE_TABLE_ROOT_ADRESSE + 0x4000    | Level 0 - Entrie     | Entries occupied: 002* | src adresse       | off: leaf   |
    |   PAGE_TABLE_ROOT_ADRESSE + 0x5000    | Level 0 - Entrie     | Entries occupied: 1FF* | dst adresse       | off: leaf   |
    |   PAGE_TABLE_ROOT_ADRESSE + 0x6000    | Level 0 - Entrie     | Entries occupied: 000* | dst adresse       | off: leaf   |
    |   PAGE_TABLE_ROOT_ADRESSE + 0x6000    | Level 0 - Entrie     | Entries occupied: 001* | dst adresse       | off: leaf   |
    ---------------------------------------------------------------------------------------------------------------------------

    * to get the entry adress multiply this value with size of page table entry (8 @ RV48)

    The Adress of the leaf-pages is already given as they are related to the va as describes above
*/

    // Page Table Population
    // Set 3 Level Page Entry (offset = vpn[3] * 8)
    generate_page_table_entry((void *) PAGE_TABLE_ROOT_ADRESSE + 0x0000, (extract_vpn(0x0000000281000000, 3) << 3), ((PAGE_TABLE_ROOT_ADRESSE + 0x1000) >> 12), 0, 0, 0, 0);

    // Set 2 Level Page Entry
    generate_page_table_entry((void *) PAGE_TABLE_ROOT_ADRESSE + 0x1000, (extract_vpn(0x0000000281000000, 2) << 3), ((PAGE_TABLE_ROOT_ADRESSE + 0x2000) >> 12), 0, 0, 0, 0);

    // Set 1 Level Page Entry
    generate_page_table_entry((void *) PAGE_TABLE_ROOT_ADRESSE + 0x2000, (extract_vpn(0x0000000281000000, 1) << 3), ((PAGE_TABLE_ROOT_ADRESSE + 0x4000) >> 12), 0, 0, 0, 0);
    generate_page_table_entry((void *) PAGE_TABLE_ROOT_ADRESSE + 0x2000, (extract_vpn(0x0000000284FFF000, 1) << 3), ((PAGE_TABLE_ROOT_ADRESSE + 0x5000) >> 12), 0, 0, 0, 0);
    generate_page_table_entry((void *) PAGE_TABLE_ROOT_ADRESSE + 0x2000, (extract_vpn(0x0000000285000000, 1) << 3), ((PAGE_TABLE_ROOT_ADRESSE + 0x6000) >> 12), 0, 0, 0, 0);

    // Set 0 Level Page Entry 
    generate_page_table_entry((void *) PAGE_TABLE_ROOT_ADRESSE + 0x4000, (extract_vpn(0x0000000281000000, 0) << 3), ((0x0000000081000000) >> 12), 0, 1, 0, 0);
    generate_page_table_entry((void *) PAGE_TABLE_ROOT_ADRESSE + 0x4000, (extract_vpn(0x0000000281001000, 0) << 3), ((0x0000000081001000) >> 12), 0, 1, 0, 0);
    generate_page_table_entry((void *) PAGE_TABLE_ROOT_ADRESSE + 0x4000, (extract_vpn(0x0000000281002000, 0) << 3), ((0x0000000081002000) >> 12), 0, 1, 0, 0);
    generate_page_table_entry((void *) PAGE_TABLE_ROOT_ADRESSE + 0x5000, (extract_vpn(0x0000000284FFF000, 0) << 3), ((0x0000000084FFF000) >> 12), 0, 0, 1, 0);
    generate_page_table_entry((void *) PAGE_TABLE_ROOT_ADRESSE + 0x6000, (extract_vpn(0x0000000285000000, 0) << 3), ((0x0000000085000000) >> 12), 0, 0, 1, 0);
    generate_page_table_entry((void *) PAGE_TABLE_ROOT_ADRESSE + 0x6000, (extract_vpn(0x0000000285001000, 0) << 3), ((0x0000000085001000) >> 12), 0, 0, 1, 0);


    // Initalize Data in all "Vars"
    for(int i = 0; i < length_copy;i++){
        write_ptr_src = reg8(pa_src_adr, i);
        *write_ptr_src = (uint8_t) (i & 0xFF);
        write_ptr_dst = reg8(pa_dst_adr, i);
        *write_ptr_dst = (uint8_t) ((length_copy - 1 - i) & 0xFF);
    }

    // Setup the register for the sMMU
    sys_dma_smmu_config(0,0,0,0);
    sys_dma_smmu_set_pt_root(PAGE_TABLE_ROOT_ADRESSE);

    // to flush the cache to DRAM
    fence(); 

    // Counte Execution Cycle
    start_cycle = get_mcycle();

    // Copy data
    sys_dma_blk_memcpy((uintptr_t) va_dst_adr, (uintptr_t) va_src_adr, length_copy);

    // Counte Execution Cycle
    end_cycle = get_mcycle();

    // Verify the Data
    uint64_t error = 0;

    // Loop over important data and compare
    for(int i = 0; i < length_copy;i++){
        write_ptr_src = reg8(pa_src_adr, i);
        write_ptr_dst = reg8(pa_dst_adr, i);

        if(((uint8_t) (*write_ptr_src)) != ((uint8_t) (*write_ptr_dst))){
            error = 1;
        }
    }

    // Evaluate the result
    if(error == 0){
        uart_write_str(&__base_uart, end_suc, sizeof(end_suc));
        uart_write_flush(&__base_uart);
    } else {
        uart_write_str(&__base_uart, end_fail, sizeof(end_fail));
        uart_write_flush(&__base_uart);
    }

    // Write the cycle count
    convert_hex_to_string((end_cycle - start_cycle), &buf[13], 16);
    uart_write_str(&__base_uart, buf, sizeof(buf));
    uart_write_flush(&__base_uart);

    return error;
}


// Generates one Page Table Entry on the given position
void generate_page_table_entry(void * ptrTable, uint64_t offsetEntry, uint64_t ppn, uint64_t execute, uint64_t read, uint64_t write, uint64_t user){
    // Be aware how the memory elements are lying in the memory
    #if defined(RV48) || defined(RV39) || defined(RV57)
        *((uint64_t * ) (ptrTable + offsetEntry)) = ((ppn & 0x00000FFFFFFFFFFF) << 10) | ((user & 1) << 4) | ((execute & 1) << 3) | ((write & 1) << 2) | ((read & 1) << 1) | 1;   // PPN is only 44 Bit Wide
    #else
        *((uint64_t * ) (ptrTable + offsetEntry)) = 0;
    #endif
}

// extract the vpn from a virtual adress (for loop to avoid multiplication)
uint64_t extract_vpn(uint64_t va, int lvl){
    #if defined(RV48) || defined(RV39) || defined(RV57)     // 9 Bits per level
        uint64_t shift = 12;
        for(int i = 0;i < lvl;i++){
            shift = shift + 9;
        }
        return ((va >> shift) & 0x1FF); // 9 bit mask
    #else                                                   // 10 Bits per level
        uint64_t shift = 12;
        for(int i = 0;i < lvl;i++){
            shift = shift + 10;
        }
        return ((va >> shift) & 0x3FF); // 10 bit mask
    #endif
}

// Convert Hex to String
void convert_hex_to_string(uint64_t NumberToConvert, char * ptrData, uint32_t digits){
	uint64_t filter = 0x000000000000000F;
	char numberInsert[] = {'0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F'};
	for(int i = digits;i>0;i--){
		*(ptrData+i-1) = numberInsert[(NumberToConvert&filter)];
		NumberToConvert = NumberToConvert >> 4;
	}
}