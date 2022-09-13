// Copyright 2022 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Nicole Narr <narrn@student.ethz.ch>
// Christopher Reinwardt <creinwar@student.ethz.ch>

#include "cheshire_soc_regs.h"
#include "uart.h"
#include "sd.h"

#define CORE_FREQ_HZ 50000000

#define SPI_SCLK_TARGET 400000

extern uint32_t __base_cheshire_regs;

void sd_boot(void)
{
    printf_("Loading 64 kB from SD Card\r\n");

    // Obtain handle to SPI instance
    spi_handle_t spi = spi_get_handle((uintptr_t) &__base_spi_sym);
    
    // Configure chip 0 (Max 50 MHz core SPI clock --> Max 25 MHz SCK) and select it.
    // Single data IO; keep timing as safe as possible.
    const uint32_t chip_cfg = spi_assemble_configopts((spi_configopts_t){
        .clkdiv     = CORE_FREQ_HZ/(2*SPI_SCLK_TARGET),
        .csnidle    = 0xF,
        .csntrail   = 0xF,
        .csnlead    = 0xF,
        .fullcyc    = false,
        .cpha       = 0,
        .cpol       = 0
    });
    
    spi_set_configopts(&spi, 0, chip_cfg);
    spi_set_configopts(&spi, 1, chip_cfg);

    spi_set_host_enable(&spi, true);

    spi_set_csid(&spi, 1); // First deselect the sd card to provide the 74 init cycles
    
    // Dumping fifo
    volatile uint32_t* fifo = spi.mmio.base + SPI_HOST_DATA_REG_OFFSET;
    while(spi_get_rx_queue_depth(&spi) > 0){
        printf_("Dumping fifo: 0x%x\r\n", *fifo);
    }

    //--------------
    // 74 Dummy Clk Cycles (let's make that 80)
    //--------------

    uint32_t cmd = spi_assemble_command((spi_command_t){
        .len        = 79,
        .csaat      = false,
        .speed      = kSpiSpeedStandard,
        .direction  = kSpiDirDummy
    });

    spi_wait_for_ready(&spi);
    spi_set_command(&spi, cmd);
    spi_wait_for_ready(&spi);

    spi_set_csid(&spi, 0);

#ifdef DEBUG
    printf_("Issued 80 dummy cycles\r\n");
#endif

    // Wait for the SD Card to get initialized
    while(sd_init(&spi)){}

    // Copy the first 64kB to SPM in the fancy way
    sd_copy_blocks(&spi, 0, (uint8_t *) 0x70000000L, 128);

    void (*payload)(uint64_t, uint64_t) = (void (*)(uint64_t, uint64_t)) 0x70000000;

    // TODO: Set a0 to hartid and a1 to address of dtb
    payload(0, 0);

    return; 
}

int main(void)
{
    volatile uint32_t *bootmode = (uint32_t *) (((uint64_t)&__base_neo_regs) + NEO_REGISTER_FILE_BOOT_MODE_REG_OFFSET);

    // Initiate our window to the world around us
    init_uart(CORE_FREQ_HZ, 115200);

    // Decide what to do
    switch(*bootmode){
        // Normal boot over SD Card
        case 0: printf_("Booting from SD Card\r\n");
                sd_boot();
                break; // We will never reach this

        case 1: printf_("Bootmode 1: Doing nothing :)\r\n");
                break;

        case 2: printf_("Bootmode 2: Doing nothing :)\r\n");
                break;

        case 3: printf_("Bootmode 3: Doing nothing :)\r\n");
                break;

        default:    printf_("Bootmode %d: Doing nothing :)\r\n", *bootmode);
                    break;
    }

    while(1){
        asm volatile("wfi\n" :::);
    }

}
