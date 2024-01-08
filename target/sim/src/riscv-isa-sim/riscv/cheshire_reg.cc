#include "devices.h"
#include "processor.h"

cheshire_reg_t::cheshire_reg_t()
{
  reset();
}

#define CHESHIRE_SCRATCH_0_OFFSET     0x0
#define CHESHIRE_SCRATCH_1_OFFSET     0x4
#define CHESHIRE_SCRATCH_2_OFFSET     0x8
#define CHESHIRE_SCRATCH_3_OFFSET     0xc
#define CHESHIRE_SCRATCH_4_OFFSET     0x10
#define CHESHIRE_SCRATCH_5_OFFSET     0x14
#define CHESHIRE_SCRATCH_6_OFFSET     0x18
#define CHESHIRE_SCRATCH_7_OFFSET     0x1c
#define CHESHIRE_SCRATCH_8_OFFSET     0x20
#define CHESHIRE_SCRATCH_9_OFFSET     0x24
#define CHESHIRE_SCRATCH_10_OFFSET    0x28
#define CHESHIRE_SCRATCH_11_OFFSET    0x2c
#define CHESHIRE_SCRATCH_12_OFFSET    0x30
#define CHESHIRE_SCRATCH_13_OFFSET    0x34
#define CHESHIRE_SCRATCH_14_OFFSET    0x38
#define CHESHIRE_SCRATCH_15_OFFSET    0x3c
#define CHESHIRE_BOOT_MODE_OFFSET     0x40
#define CHESHIRE_RTC_FREQ_OFFSET      0x44
#define CHESHIRE_PLATFORM_ROM_OFFSET  0x48
#define CHESHIRE_NUM_INT_HARTS_OFFSET 0x4c
#define CHESHIRE_HW_FEATURES_OFFSET   0x50
#define CHESHIRE_LLC_SIZE_OFFSET      0x54
#define CHESHIRE_VGA_PARAMS_OFFSET    0x58

#define CHESHIRE_LLC_REG_OFFSET       0x1000
#define CHESHIRE_LLC_REG_SIZE         0x1000

void cheshire_reg_t::reset() {
  for(int i = 0; i < 16; i++) {
    scratch[i] = 0;
  }
  // scratch[1:0] is the preload binary entry
  scratch[0] = 0x80000000;
  scratch[1] = 0x00000000;
  // scratch[2] indicate the finish of preload
  scratch[2] = 2;

  boot_mode               = 0;
  rtc_freq                = 32768;
  platform_rom            = 0;
  num_int_harts           = 1;
  hw_features.bootrom     = 1;
  hw_features.llc         = 1;
  hw_features.uart        = 1;
  hw_features.spi_host    = 1;
  hw_features.i2c         = 1;
  hw_features.gpio        = 1;
  hw_features.dma         = 1;
  hw_features.serial_link = 1;
  hw_features.vga         = 1;
  hw_features.axirt       = 0;
  hw_features.clic        = 0;
  hw_features.irq_router  = 0;
  hw_features.bus_err     = 1;
  llc_size                = 0x20000;
  vga_params.red_width    = 3;
  vga_params.green_width  = 3;
  vga_params.blue_width   = 2;
}

bool cheshire_reg_t::load(reg_t addr, size_t len, uint8_t* bytes)
{
  if (addr >= CHESHIRE_SCRATCH_0_OFFSET && 
      addr + len < CHESHIRE_BOOT_MODE_OFFSET &&
      addr % 4 == 0) {
    memcpy(bytes, (uint8_t*)&scratch[0] + addr - CHESHIRE_SCRATCH_0_OFFSET, len);
  } else if (addr == CHESHIRE_BOOT_MODE_OFFSET && len <= 4) {
    memcpy(bytes, (uint8_t*)&boot_mode, len);
  } else if (addr == CHESHIRE_RTC_FREQ_OFFSET && len <= 4) {
    memcpy(bytes, (uint8_t*)&rtc_freq, len);
  } else if (addr == CHESHIRE_PLATFORM_ROM_OFFSET && len <= 4) {
    memcpy(bytes, (uint8_t*)&platform_rom, len);
  } else if (addr == CHESHIRE_NUM_INT_HARTS_OFFSET && len <= 4) {
    memcpy(bytes, (uint8_t*)&num_int_harts, len);
  } else if (addr == CHESHIRE_HW_FEATURES_OFFSET && len <= 4) {
    uint32_t mask_1bit = 0x00000001;
    hw_features_reg   = ((hw_features.bootrom     & mask_1bit) << 0)   |
                        ((hw_features.llc         & mask_1bit) << 1)   |
                        ((hw_features.uart        & mask_1bit) << 2)   |
                        ((hw_features.spi_host    & mask_1bit) << 3)   |
                        ((hw_features.i2c         & mask_1bit) << 4)   |
                        ((hw_features.gpio        & mask_1bit) << 5)   |
                        ((hw_features.dma         & mask_1bit) << 6)   |
                        ((hw_features.serial_link & mask_1bit) << 7)   |
                        ((hw_features.vga         & mask_1bit) << 8)   |
                        ((hw_features.axirt       & mask_1bit) << 9)   |
                        ((hw_features.clic        & mask_1bit) << 10)  |
                        ((hw_features.irq_router  & mask_1bit) << 11)  |
                        ((hw_features.bus_err     & mask_1bit) << 12)  ;
    memcpy(bytes, (uint8_t*)&hw_features_reg, len);
  } else if (addr == CHESHIRE_LLC_SIZE_OFFSET && len <= 4) {
    memcpy(bytes, (uint8_t*)&llc_size, len);
  } else if (addr == CHESHIRE_VGA_PARAMS_OFFSET && len <= 4) {
    uint32_t mask_8bit = 0x000000ff;
    vga_params_reg    = ((vga_params.red_width    & mask_8bit) << 0)   |
                        ((vga_params.green_width  & mask_8bit) << 8)   |
                        ((vga_params.blue_width   & mask_8bit) << 16)  ;
    memcpy(bytes, (uint8_t*)&vga_params_reg, len);
  } else if (addr >= CHESHIRE_LLC_REG_OFFSET && addr + len < CHESHIRE_LLC_REG_OFFSET + CHESHIRE_LLC_REG_SIZE) {
    uint32_t ret = 0xffffffff;
    memcpy(bytes, (uint8_t*)&ret, len);
  } else {
    return false;
  }
  return true;
}

bool cheshire_reg_t::store(reg_t addr, size_t len, const uint8_t* bytes)
{
  if (addr >= CHESHIRE_SCRATCH_0_OFFSET && 
      addr + len < CHESHIRE_BOOT_MODE_OFFSET &&
      addr % 4 == 0) {
    memcpy((uint8_t*)&scratch[0] + addr - CHESHIRE_SCRATCH_0_OFFSET, bytes, len);
  
  // following registers are read-only
  // } else if (addr == CHESHIRE_BOOT_MODE_OFFSET && len <= 4) {
  //   memcpy((uint8_t*)&boot_mode, bytes, len);
  // } else if (addr == CHESHIRE_RTC_FREQ_OFFSET && len <= 4) {
  //   memcpy((uint8_t*)&rtc_freq, bytes, len);
  // } else if (addr == CHESHIRE_PLATFORM_ROM_OFFSET && len <= 4) {
  //   memcpy((uint8_t*)&platform_rom, bytes, len);
  // } else if (addr == CHESHIRE_NUM_INT_HARTS_OFFSET && len <= 4) {
  //   memcpy((uint8_t*)&num_int_harts, bytes, len);
  // } else if (addr == CHESHIRE_HW_FEATURES_OFFSET && len <= 4) {
  //   uint32_t mask_1bit = 0x00000001;
  //   memcpy((uint8_t*)&hw_features_reg, bytes, len);
  //   hw_features.bootrom     = (hw_features_reg >> 0)  & mask_1bit;
  //   hw_features.llc         = (hw_features_reg >> 1)  & mask_1bit;
  //   hw_features.uart        = (hw_features_reg >> 2)  & mask_1bit;
  //   hw_features.spi_host    = (hw_features_reg >> 3)  & mask_1bit;
  //   hw_features.i2c         = (hw_features_reg >> 4)  & mask_1bit;
  //   hw_features.gpio        = (hw_features_reg >> 5)  & mask_1bit;
  //   hw_features.dma         = (hw_features_reg >> 6)  & mask_1bit;
  //   hw_features.serial_link = (hw_features_reg >> 7)  & mask_1bit;
  //   hw_features.vga         = (hw_features_reg >> 8)  & mask_1bit;
  //   hw_features.axirt       = (hw_features_reg >> 9)  & mask_1bit;
  //   hw_features.clic        = (hw_features_reg >> 10) & mask_1bit;
  //   hw_features.irq_router  = (hw_features_reg >> 11) & mask_1bit;
  //   hw_features.bus_err     = (hw_features_reg >> 12) & mask_1bit;  
  // } else if (addr == CHESHIRE_LLC_SIZE_OFFSET && len <= 4) {
  //   memcpy((uint8_t*)&llc_size, bytes, len);
  // } else if (addr == CHESHIRE_VGA_PARAMS_OFFSET && len <= 4) {
  //   uint32_t mask_8bit = 0x000000ff;
  //   memcpy((uint8_t*)&vga_params_reg, bytes, len);
  //   vga_params.red_width    = (vga_params_reg >> 0)  & mask_8bit;
  //   vga_params.green_width  = (vga_params_reg >> 8)  & mask_8bit;
  //   vga_params.blue_width   = (vga_params_reg >> 16) & mask_8bit;
  } else if (addr >= CHESHIRE_LLC_REG_OFFSET && addr + len < CHESHIRE_LLC_REG_OFFSET + CHESHIRE_LLC_REG_SIZE) {

  } else {
    return false;
  }
  return true;
}
