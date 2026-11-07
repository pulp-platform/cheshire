// Copyright 2026 CheshireAra contributors.
// SPDX-License-Identifier: Apache-2.0
// Compile the actual HAL and DIF. Instrument only their MMIO boundary.
#include <stdint.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "hal/i2c_24fc1025.h"
#include "util.h"
#include "i2c_regs.h"

// The current HAL initializes the non-instrumented mmio_region_t.base member.
// Alias only that token while including the exact HAL source for this host test.
#define base mock
#include HAL_SOURCE
#undef base

void *__i2c_base_addr__;
static unsigned cases, errors, fdata_index, rx_remaining, read_count, calls;
static uint32_t control_reg;
static uint64_t address;
static uint8_t expected_control;
static unsigned char identity;

static void compare(const char *label, uint32_t got, uint32_t want) {
  if (got != want) {
    errors++;
    printf("EEPROM_MISMATCH case=%u %s got=%#x want=%#x\n",cases,label,got,want);
  }
}
static void budget(void) {
  if (++calls > 10000) {
    puts("EEPROM_CONTROL_ERROR MMIO polling did not complete");
    exit(2);
  }
}
void clint_spin_ticks(uint64_t ticks) { (void)ticks; }
mmio_region_t mmio_region_from_addr(uintptr_t addr) {
  return (mmio_region_t){.mock=(void *)addr};
}
uint32_t mmio_region_read32(mmio_region_t region, ptrdiff_t offset) {
  budget();
  if (region.mock != &identity) { puts("EEPROM_CONTROL_ERROR MMIO identity"); exit(2); }
  if (offset == I2C_CTRL_REG_OFFSET) return control_reg;
  if (offset == I2C_FIFO_STATUS_REG_OFFSET)
    return rx_remaining << I2C_FIFO_STATUS_RXLVL_OFFSET;
  if (offset == I2C_RDATA_REG_OFFSET) {
    if (!rx_remaining) { puts("EEPROM_CONTROL_ERROR empty RX read"); exit(2); }
    rx_remaining--;
    return 0x5a;
  }
  puts("EEPROM_CONTROL_ERROR unexpected MMIO read"); exit(2);
}
void mmio_region_write32(mmio_region_t region, ptrdiff_t offset, uint32_t value) {
  budget();
  if (region.mock != &identity) { puts("EEPROM_CONTROL_ERROR MMIO identity"); exit(2); }
  if (offset == I2C_CTRL_REG_OFFSET) {
    control_reg=value;
    if (value & (1u<<I2C_CTRL_ENABLEHOST_BIT)) rx_remaining=read_count;
    else { fdata_index=0; read_count=0; }
    return;
  }
  if (offset != I2C_FDATA_REG_OFFSET) { puts("EEPROM_CONTROL_ERROR unexpected MMIO write"); exit(2); }
  uint8_t byte=value & 0xff;
  // Datasheet control byte: 1010 B0 A1 A0 R/W.
  // Logical address A16 selects B0; A17/A18 select the device pins.
  uint8_t expected=expected_control;
  switch (fdata_index++) {
    case 0: compare("write control",byte,expected); break;
    case 1: compare("address high",byte,(address>>8)&255); break;
    case 2: compare("address low",byte,address&255); break;
    case 3: compare("read control",byte,expected|1); break;
    case 4:
      compare("read count",byte,1);
      compare("read flag",(value>>I2C_FDATA_READ_BIT)&1,1);
      read_count=byte;
      break;
    default: puts("EEPROM_CONTROL_ERROR too many format writes"); exit(2);
  }
}
int main(void) {
  const uint64_t addresses[]={0,0xffff,0x10000,0x1ffff,0x20000,0x30000,0x40000,0x50000,0x60000,0x70000};
  const uint8_t controls[]={0xa0,0xa0,0xa8,0xa8,0xa2,0xaa,0xa4,0xac,0xa6,0xae};
  dif_i2c_t i2c={.base_addr={.mock=&identity}};
  for (unsigned i=0;i<sizeof(addresses)/sizeof(addresses[0]);i++) {
    uint8_t data[256]; memset(data,0xcc,sizeof(data));
    address=addresses[i]; expected_control=controls[i]; cases++; control_reg=1; rx_remaining=read_count=fdata_index=calls=0;
    int result=i2c_24fc1025_read(&i2c,&data[64],address,1);
    compare("return",result,0); compare("format count",fdata_index,5);
    compare("returned byte",data[64],0x5a);
    for(unsigned j=0;j<sizeof(data);j++) if(j!=64) compare("guard",data[j],0xcc);
  }
  printf("EEPROM_CONTROL_DONE cases=%u errors=%u\n",cases,errors);
  return errors?1:0;
}
