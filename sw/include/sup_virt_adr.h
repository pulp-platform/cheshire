// Copyright 2023 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Raphael Roth <narrn@student.ethz.ch>

/***********************/
/*       READ ME       */
/***********************/

/*

This H-File allows to setup a page table tree for "bare metal" virtual adresses.

The generated adress system follows the rules:
- Virtal Adresses needs to be of format 0x0000_0002_XXXX_YYYY
- The corresponding Physical Adresses are 0x0000_0000_XXXX_YYYY.
    - This allows for a human redable translation while having "invalid" virtual adresses.

The only function required by the user is the following one:

reserve_array(void * virt_adr, uint64_t * ptr_nxt_free_page, uint64_t size, uint64_t root_page_table_adr);

The main purpose of this function is to map a array into the given page table tree. 
All required pages (if the array crosses page boundaries) will be set up automatically.
By default the code will generate any page table entry it requires for a successful translation.

This function allows to map a array into the the page table given. The parameter the following

virt_adr            => Start Virtual Adress of the Array. Needs to be in Format 
size                => Size of the Array in Byte
ptr_nxt_free_page   => Pointer to an adress with the next free page where we can insert the PT data (USER is responsible that no data residue there!)
root_page_table_adr => Page Table Root Adress

return values:
0   => Sucessful initalization
2   => Sucessful initalization but at least one leaf-page-table entry existed beforhand.
4   => We have found a leaf-page-table on level > 0 --> currently error as we do not support megapages

To gain a better understanding of the generated page table tree see the "smmu_page_table_example.c" file

Limitation:
- The USER is responsible for memory management.
- The Code will require a certain Memory Region at the start to implement all page table pages
- It is possible to concurrently implement multiple page table trees but the corresponding root must be changed @ the smmu and currently no flushing is supported.

ToDo:
- Support Megapages
- Implement generate_pte / parse_pte for SV32

*/

#ifndef VIRT_ADR_SUPPORT_H_
#define VIRT_ADR_SUPPORT_H_

/***********************/
/*    Global Define    */
/***********************/

#define RV48

/***********************/
/*      Typedefs       */
/***********************/

typedef struct {
    void * va_src;
    void * va_dst;
    void * pa_src;
    void * pa_dst;
    uint64_t len;
} transfer_t;

typedef struct {
    uint64_t ppn;
    uint64_t exe;
    uint64_t read;
    uint64_t write;
    uint64_t user;
    uint64_t valid;
} pte_element_t;

/***********************/
/* Function Definition */
/***********************/

uint64_t extract_vpn(uint64_t va, int lvl);
void convert_hex_to_string(uint64_t NumberToConvert, char * ptrData, uint32_t digits);
inline void generate_data(void * phys_adr, uint8_t seed, uint64_t size);
inline int verify_data(void * phys_src, void * phys_dst, uint64_t size);
inline void generate_pte(void * position, pte_element_t pte);
inline pte_element_t parse_pte(void * position);
int generate_page_table_brunch(void * virt_adr, void *  phys_adr, uint64_t * ptr_nxt_free_page, uint64_t root_page_table_adr);
int reserve_array(void * virt_adr, uint64_t * ptr_nxt_free_page, uint64_t size, uint64_t root_page_table_adr);
inline void zeros_page_table(void * start);

/***************************/
/* Function Implementation */
/***************************/

// Generates one Page Table Entry on the given position
inline void generate_pte(void * position, pte_element_t pte){
    // Be aware how the memory elements are lying in the memory
    #if defined(RV48) || defined(RV39) || defined(RV57)
        *((uint64_t * ) (position)) = ((pte.ppn & 0x00000FFFFFFFFFFF) << 10) | ((pte.user & 1) << 4) | ((pte.exe & 1) << 3) | ((pte.write & 1) << 2) | ((pte.read & 1) << 1) | 1;   // PPN is only 44 Bit Wide
    #else
        *((uint64_t * ) (position)) = 0;
    #endif
}

// Parse a PTE element on the given position
inline pte_element_t parse_pte(void * position){
    pte_element_t pte;
    uint64_t pte_element = *((uint64_t * ) (position));

    // Extract the common fields between all RV's
    pte.valid = pte_element & 1;
    pte.read = ((pte_element >> 1) & 1);
    pte.write = ((pte_element >> 2) & 1);
    pte.exe = ((pte_element >> 3) & 1);
    pte.user = ((pte_element >> 4) & 1);

    // Parse the ppn
    #if defined(RV48) || defined(RV39) || defined(RV57)
        pte.ppn = ((pte_element >> 10) & 0x00000FFFFFFFFFFF);
    #else
        pte.ppn = 0;
    #endif
    return pte;
}

// Generate one brunch for one virtual adress in tha page table tree
// return:
// 0 ==> successfully
// 2 ==> page already initialized with other data's
// 4 ==> page is not on level 0
int generate_page_table_brunch(void * virt_adr, void *  phys_adr, uint64_t * ptr_nxt_free_page, uint64_t root_page_table_adr){
    uint64_t nr_level = 0;
    int retValue = 0;
    void * a = (void *) root_page_table_adr;

    // Set the nr of levels according the adress schema we use
    #if defined(RV57)
        nr_level = 5;
    #elif defined(RV48)
        nr_level = 4;
    #elif defined(RV48)
        nr_level = 3;
    #elif defined(RV48)
        nr_level = 2;
    #endif

    // Iterate over all levels until we reach the one where the pages should live
    for(uint64_t lvl = nr_level; lvl > 0; lvl--){
        // Add the offset to the page table
        #if defined(RV48) || defined(RV39) || defined(RV57)
            a = a + (extract_vpn((uint64_t) virt_adr, lvl-1) << 3);
        #else
            a = a + (extract_vpn((uint64_t) virt_adr, lvl-1) << 2);
        #endif

        // Parse the pte element
        pte_element_t pte = parse_pte(a);

        // Check if entry exists, otherwise generate a new entry while reserving the next page
        if(pte.valid == 1){
            if((pte.exe | pte.write | pte.read) == 1){  // Leaf Pointer
                // Verify that the Leaf - Pointer matches
                if(pte.ppn != (((uint64_t) phys_adr) >> 12)){
                    retValue = retValue | 2;
                }
                // Verify we are on level 0
                if((lvl - 1) != 0){
                    retValue = retValue | 4;
                }
            } else {    // Non-Leaf Pointer - Enter Subpointer
                a = (void *) (pte.ppn << 12);
            }
        } else {
            if((lvl - 1) == 0){
                // Set the given physical page as destination
                pte.ppn = ((uint64_t) phys_adr) >> 12;
                // Set the read / write flag to 1
                pte.exe = 0;
                pte.read = 1;
                pte.write = 1;
                pte.user = 0;
                pte.valid = 1;
            } else {
                // Reserve the next free page destined for page table
                pte.ppn = *ptr_nxt_free_page >> 12;
                zeros_page_table((void *) (*ptr_nxt_free_page));
                *ptr_nxt_free_page = *ptr_nxt_free_page + 0x1000;

                // Set all flags to 0
                pte.exe = 0;
                pte.read = 0;
                pte.write = 0;
                pte.user = 0;
                pte.valid = 1;
            }
            generate_pte(a, pte);           // generate a page table entry
            a = (void *) (pte.ppn << 12);              // set a for the next iteration
        }
    }

    // return the status
    return retValue;
}

// Generate all required va mappings for one array
int reserve_array(void * virt_adr, uint64_t * ptr_nxt_free_page, uint64_t size, uint64_t root_page_table_adr){
    uint32_t retValue = 0;
    // Reserve for the first adress directly a new page
    // INFO:
    // We know by our adress schem that we can substract 0x2_0000_0000 from the virtual adress to get into the physical adress.
    // If this is not fixed we would need to allocate here the physical pages !!!
    retValue = generate_page_table_brunch(virt_adr, virt_adr - 0x200000000, ptr_nxt_free_page, root_page_table_adr);

    // Calculate end adress
    uint64_t offset = ((uint64_t) virt_adr) & 0xFFF;
    uint64_t end_adr = (uint64_t) virt_adr + size -1;

    // Add a new page as soon as we cross one page boundary (offset + size) gets the first adress which is not in the array anymore
    if((offset + size) > 0x1000){
        // Go to next page boundary
        for(uint64_t curr_adr = (((uint64_t) virt_adr) & 0xFFFFFFFFFFFFF000) + 0x1000; curr_adr <= end_adr; curr_adr = curr_adr + 0x1000){
            // Reserve the corresponding page table
            retValue = retValue | generate_page_table_brunch((void*) curr_adr,(void*) (curr_adr - 0x200000000), ptr_nxt_free_page, root_page_table_adr);
        }
    }
    return retValue;
}

/* Small Helper Functions */

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

// Generate pseudo random data
inline void generate_data(void * phys_adr, uint8_t seed, uint64_t size){
    for(uint64_t i = 0; i < size;i++){
        *((uint8_t *) (phys_adr + i)) = ((uint8_t) (i & 0xFF)) ^ seed;
    }
}

// Verify that the data were copied
inline int verify_data(void * phys_src, void * phys_dst, uint64_t size){
    int error = 0;
    for(uint64_t i = 0; i < size;i++){
        if(*((uint8_t *) (phys_src + i)) != *((uint8_t *) (phys_dst + i))){
            error = 1;
        }
    }
    return error;
}

// Use this function to initalize a page table with 0's to avoid reading an unitialized adress
inline void zeros_page_table(void * start){
    for(void * i = start; i < (start+4096);i = i + 8){
        *((uint64_t*) i) = 0;
    }
}


#endif /* VIRT_ADR_SUPPORT_H_ */
