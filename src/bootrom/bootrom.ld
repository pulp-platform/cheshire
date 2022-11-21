ENTRY(_start)

MEMORY
{
  bootrom (rx)  : ORIGIN = 0x01000000, LENGTH = 16K
  spm (rwx)     : ORIGIN = 0x70000000, LENGTH = 128K
}

SECTIONS
{
  .text : { *(.text._start) *(.text) *(.text.*) } > bootrom

  .misc ALIGN(8): { *(.data) *(.sdata) *(.*) } > bootrom

  /DISCARD/ : { *(.riscv.attributes) *(.comment) }
  /* Global and stack pointer */
  __global_pointer$ = ADDR(.misc) + SIZEOF(.misc) / 2;
  __stack_pointer$  = ORIGIN(spm) + LENGTH(spm) - 8;
  /* Further addresses */
  __clint_mtime               = 0x0400bff8; 
  __base_app_sym              = ORIGIN(spm);
  __base_dtb_sym              = ORIGIN(spm);
  __base_fll_sym              = 0x02002000;
  __base_i2c_sym              = 0x02001000;
  __base_padring_sym          = 0x02003000;
  __base_scratch_regs_sym     = 0x02004000;
  __base_serial_link_conf_sym = 0x20000000;
  __base_spi_sym              = 0x03000000;
  __base_spm_sym              = ORIGIN(spm);
  __base_uart_sym             = 0x02000000;
}
