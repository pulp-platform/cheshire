ENTRY(_start)

MEMORY
{
  spm (rwx)     : ORIGIN = 0x70000000, LENGTH = 128K
  dram (rwx)    : ORIGIN = 0x80000000, LENGTH = 1024M
}

SECTIONS
{
  .text : { *(.text._start) *(.text) *(.text.*) } > dram

  . = ALIGN(8);
  .bulk : ALIGN(8) { *(.bulk) *(.bulk.*) } > dram

  . = ALIGN(16);
  .misc : { *(.data) *(.sdata) *(.*) } > dram


  /DISCARD/ : { *(.riscv.attributes) *(.comment) }
  /* Global and stack pointer */
  __global_pointer$ = ADDR(.misc) + SIZEOF(.misc) / 2;
  __stack_pointer$  = ORIGIN(spm) + LENGTH(spm) - 8;
  /* Further addresses */
  __clint_mtime       = 0x0400bff8; 
  __base_uart_sym     = 0x02000000;
  __base_i2c_sym      = 0x02001000;
  __base_spi_sym      = 0x03000000;
  __base_spm_sym      = ORIGIN(spm);
  __base_dram_sym     = ORIGIN(dram);
}
