#include "main.h"
#include "cheshire_regs.h"
#include "uart.h"
#include "spi.h"
#include "dif_i2c.h"
#include "i2c_regs.h"

extern void *__base_app_sym;                // Where the 2nd stage code should be loaded
extern void *__base_dtb_sym;                // Start address of the binary device tree
extern void *__base_fll_sym;                // Start address of the FLL config interface
extern void *__base_i2c_sym;                // Start address of the I2C peripheral
extern void *__base_padring_sym;            // Start address of the padring config register
extern void *__base_scratch_regs_sym;       // Start address of the cheshire scratch registers
extern void *__base_serial_link_conf_sym;   // Start address of the serial link peripheral config registers
extern void *__base_spi_sym;                // Start address of the SPI peripheral
extern void *__base_spm_sym;                // Start address of the scratchpad memory

#define htonw(x) ((((x) << 24) & (0xFF << 24)) | (((x) << 8) & (0xFF << 16)) | (((x) >> 8) & (0xFF << 8)) | (((x) >> 24) & 0xFF))

void fll_lock(uint64_t target, uint64_t reference)
{
    volatile uint32_t *fll = (volatile uint32_t *) &__base_fll_sym;
    uint64_t m = 800000000/(2*reference);
    //uint64_t d = (800000000 + target - 1)/target; //TODO

    // Set configuration register 2
    // No dithering
    // Loop closed when locked
    // Refclk as clk source
    // 0x00F lock margin
    // 0x2F stable cycles for lock assert
    // 0x10 unstable cycles for lock deassert
    // 0x8 loop gain
    //fll[2] = 0x2003FD08;
    fll[2] = 0x2200FD08;

    // Set configuration register 1
    // Normal mode
    // Gate output with lock signal
    // Divider = ceil(800000000/target)
    // TODO: currently divider fixed to 4
    // DCO in = 0x158
    // Multiplicator = 800000000/(2*reference)
    fll[1] = (0xC958 << 16) | (m & 0xFFFF);
    //fll[1] = (0xC958 << 16) | 0x2FAF;     32.768 kHz reference
    //fll[1] = (0xC958 << 16) | 0x0190;     1 MHz reference
}

void spi_boot(uint64_t core_freq)
{
    // Obtain handle to SPI instance, enable host
    spi_handle_t spi = spi_get_handle((uintptr_t) &__base_spi_sym);
    spi_set_host_enable(&spi, true);

    // Configure chip 0 (Max 25 MHz core SPI clock --> Max 12.5 MHz SCK) and select it.
    // Single data IO; keep timing as safe as possible.
    const uint32_t chip_cfg = spi_assemble_configopts((spi_configopts_t){
        .clkdiv     = (core_freq/(2*SPI_SCLK_TARGET)) - 1,
        .csnidle    = 0xF,
        .csntrail   = 0xF,
        .csnlead    = 0xF,
        .fullcyc    = false,
        .cpha       = 0,
        .cpol       = 0
    });
    spi_set_configopts(&spi, 0, chip_cfg);
    spi_set_csid(&spi, 0);

    // Set RX watermark to chunk unit of transfer (32B == 8 words)
    spi_set_rx_watermark(&spi, 8);

    // Wait for s25fl512s to power up (350 us, accounting for imprecisions)
    for(int i = 0; i < 2000; i++){
        asm volatile("add x0, x0, x0\n");
    }

    // Sequential read from s25fl512s to SPM
    uint32_t* code_dst = (uint32_t*)(&__base_spm_sym);

    for (int i = 0; i < BOOTLOADER_SIZE/256; i++) {
        // Fill TX FIFO with TX data (3 byte address read command + 3B address)
        const uint8_t cmd = 0x03;
        uint32_t addr = htonw(i * 256);

        // Feed the command to peripheral
        spi_write_word(&spi, (addr & ~((uint32_t) 0xFFU)) | cmd);

        // Wait for readiness to process commands
        spi_wait_for_ready(&spi);

        // Load command FIFO with command (1 Byte at single speed)
        const uint32_t cmd_cmd = spi_assemble_command((spi_command_t){
            .len        = 0,
            .csaat      = true,
            .speed      = kSpiSpeedStandard,
            .direction  = kSpiDirTxOnly
        });
        spi_set_command(&spi, cmd_cmd);
        spi_wait_for_ready(&spi);

        // Load command FIFO with address (3 Bytes at single speed)
        const uint32_t cmd_addr = spi_assemble_command((spi_command_t){
            .len        = 2,
            .csaat      = true,
            .speed      = kSpiSpeedStandard,
            .direction  = kSpiDirTxOnly
        });
        spi_set_command(&spi, cmd_addr);
        spi_wait_for_ready(&spi);

        // Load command FIFO with read cycles (always 256 bytes)
        const uint32_t cmd_read = spi_assemble_command((spi_command_t){
            .len        = 255,
            .csaat      = false,
            .speed      = kSpiSpeedStandard,
            .direction  = kSpiDirRxOnly
        });
        spi_set_command(&spi, cmd_read);
        spi_wait_for_ready(&spi);

        // Read in 32-byte chunks
        for (int k = 0; k < 256/32; k++) {
            spi_wait_for_rx_watermark(&spi);
            spi_read_chunk_32B(&spi, code_dst + 8*k);
        }

        // 256 bytes == 64 32 bit words
        code_dst += 64;
    }

    void (*payload)(uint64_t, uint64_t) = (void (*)(uint64_t, uint64_t)) &__base_app_sym;

    asm volatile("fence.i" ::: "memory");

    payload(0, (uint64_t) &__base_dtb_sym);

    return;
}

void idle_boot(void)
{
    while(true){
        asm volatile("wfi\n" :::);
    }
}


void i2c_boot(uint64_t core_freq)
{
    // Variables for FIFO polling
    uint8_t fmt_fifo_level, rx_fifo_level;

    uint8_t *dst = (uint8_t *) &__base_spm_sym;

    // Obtain handle to I2C
    mmio_region_t i2c_base = (mmio_region_t){.base = (volatile void *) &__base_i2c_sym};
    dif_i2c_params_t i2c_params = {.base_addr = i2c_base};
    dif_i2c_t i2c;
    CHECK_ELSE_TRAP(dif_i2c_init(i2c_params, &i2c), kDifI2cOk)

    // Configure I2C: worst case 24xx1025 @1.7V
    const uint32_t per_periph_ns = 1000*1000*1000/core_freq;

    const dif_i2c_timing_config_t timing_config = {
        .clock_period_nanos         = per_periph_ns,    // System-side periph clock
        .lowest_target_device_speed = kDifI2cSpeedFast, // Fast mode: max 400 kBaud
        .scl_period_nanos           = 1000000/333,      // Slower to meet t_sda_rise
        .sda_fall_nanos             = 300,              // See 24xx1025 datasheet
        .sda_rise_nanos             = 1000              // See 24xx1025 datasheet
    };

    dif_i2c_config_t config;
    CHECK_ELSE_TRAP(dif_i2c_compute_timing(timing_config, &config), kDifI2cOk)
    CHECK_ELSE_TRAP(dif_i2c_configure(&i2c, config), kDifI2cOk)

    // Enable host functionality
    // We do *not* set up any interrupts; traps of any kind should be fatal
    CHECK_ELSE_TRAP(dif_i2c_host_set_enabled(&i2c, kDifI2cToggleEnabled), kDifI2cOk)

    // Address first 24FC1025 with a write request
    CHECK_ELSE_TRAP(dif_i2c_write_byte(&i2c, 0b10100000, kDifI2cFmtStart, true), kDifI2cOk)
    
    // Write high address byte
    CHECK_ELSE_TRAP(dif_i2c_write_byte(&i2c, 0x0, kDifI2cFmtTx, true), kDifI2cOk)
    
    // Write low address byte
    CHECK_ELSE_TRAP(dif_i2c_write_byte(&i2c, 0x0, kDifI2cFmtTxStop, true), kDifI2cOk)

    // Address first 24FC1025 with a read request
    CHECK_ELSE_TRAP(dif_i2c_write_byte(&i2c, 0b10100001, kDifI2cFmtStart, true), kDifI2cOk)

    // Copy Bootloader into SPM
    for(int i = 0; i < (BOOTLOADER_SIZE-64); i += 64){

        // Request 64 bytes
        CHECK_ELSE_TRAP(dif_i2c_write_byte(&i2c, 64, kDifI2cFmtRxContinue, false), kDifI2cOk)

        // Wait for reception to complete
        do CHECK_ELSE_TRAP(dif_i2c_get_fifo_levels(&i2c, &fmt_fifo_level, &rx_fifo_level), kDifI2cOk)
        while (rx_fifo_level < 63);

        // Move 64 bytes to the destination buffer
        for(int j = 0; j < 64; j++){
            CHECK_ELSE_TRAP(dif_i2c_read_byte(&i2c, dst++), kDifI2cOk)
        }
    }

    // Request last 64 bytes and issue Stop condition
    CHECK_ELSE_TRAP(dif_i2c_write_byte(&i2c, 64, kDifI2cFmtRxStop, false), kDifI2cOk)

    // Wait for reception to complete
    do CHECK_ELSE_TRAP(dif_i2c_get_fifo_levels(&i2c, &fmt_fifo_level, &rx_fifo_level), kDifI2cOk)
    while (rx_fifo_level < 63);

    for(int j = 0; j < 64; j++){
        CHECK_ELSE_TRAP(dif_i2c_read_byte(&i2c, dst++), kDifI2cOk)
    }

    void (*payload)(uint64_t, uint64_t) = (void (*)(uint64_t, uint64_t)) &__base_app_sym;

    asm volatile("fence.i" ::: "memory");

    payload(0, (uint64_t) &__base_dtb_sym);

    return;
}

int main(void)
{
    volatile uint32_t *bootmode = (uint32_t *) (((uint64_t)&__base_scratch_regs_sym) + CHESHIRE_REGISTER_FILE_BOOT_MODE_REG_OFFSET);

    // Decide what to do
    switch(*bootmode){

        // Idle boot aka wait for JTAG with locked FLL (~200 MHz)
        case 0: fll_lock(FLL_LOCKED_FREQ_HZ, REF_CLK_FREQ_HZ);
                idle_boot();
                break;

        // SD-Card boot with unlocked FLL (~50 MHz)
        case 1: spi_boot(FLL_UNLOCKED_FREQ_HZ);
                break;

        // SD-Card boot with locked FLL (~200 MHz)
        case 2: fll_lock(FLL_LOCKED_FREQ_HZ, REF_CLK_FREQ_HZ);
                spi_boot(FLL_LOCKED_FREQ_HZ);
                break;

        // I2C flash chip boot with locked FLL (~200 MHz)
        case 3: fll_lock(FLL_LOCKED_FREQ_HZ, REF_CLK_FREQ_HZ);
                i2c_boot(FLL_LOCKED_FREQ_HZ);
                break;

        // No idea how we ended up here but let's just wait for JTAG to take over
        default:    idle_boot();
                    break;
    }

    while(1){
        asm volatile("wfi\n" :::);
    }

    return 0;
}
