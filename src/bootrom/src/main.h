#ifndef MAIN_H_
#define MAIN_H_

//#define REF_CLK_FREQ_HZ 32768
#define REF_CLK_FREQ_HZ 1000000

#define FLL_UNLOCKED_FREQ_HZ 50000000
#define FLL_LOCKED_FREQ_HZ 200000000

#define SPI_SCLK_TARGET 400000
//#define SPI_SCLK_TARGET 50000000

// Number of bytes to copy from external NVMEM
// Must be less than 64 kB for I2C to work
// Must be less than 16 MB for SPI to work
#define BOOTLOADER_SIZE 12*1024 // TODO

#endif
