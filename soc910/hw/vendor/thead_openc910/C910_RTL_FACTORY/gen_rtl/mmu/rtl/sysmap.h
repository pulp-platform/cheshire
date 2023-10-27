
// `ifdef FPGA 
// `define SYSMAP_BASE_ADDR0  28'h01000
// `define SYSMAP_FLG0        5'b01111

// `define SYSMAP_BASE_ADDR1  28'h02000
// `define SYSMAP_FLG1        5'b10000

// `define SYSMAP_BASE_ADDR2  28'hd0000
// `define SYSMAP_FLG2        5'b10000

// `define SYSMAP_BASE_ADDR3  28'heffff
// `define SYSMAP_FLG3        5'b01101

// `define SYSMAP_BASE_ADDR4  28'hfffff
// `define SYSMAP_FLG4        5'b01111

// `define SYSMAP_BASE_ADDR5  28'h4000000
// `define SYSMAP_FLG5        5'b01111

// `define SYSMAP_BASE_ADDR6  28'h5000000 
// `define SYSMAP_FLG6        5'b10000

// `define SYSMAP_BASE_ADDR7  28'hfffffff 
// `define SYSMAP_FLG7        5'b01111
// `else
// `define SYSMAP_BASE_ADDR0  28'h01000
// `define SYSMAP_FLG0        5'b01111

// `define SYSMAP_BASE_ADDR1  28'h02000
// `define SYSMAP_FLG1        5'b10000

// `define SYSMAP_BASE_ADDR2  28'hd0000
// `define SYSMAP_FLG2        5'b10000

// `define SYSMAP_BASE_ADDR3  28'heffff
// `define SYSMAP_FLG3        5'b01101

// `define SYSMAP_BASE_ADDR4  28'hfffff
// `define SYSMAP_FLG4        5'b01111

// `define SYSMAP_BASE_ADDR5  28'h4000000
// `define SYSMAP_FLG5        5'b01111

// `define SYSMAP_BASE_ADDR6  28'h5000000 
// `define SYSMAP_FLG6        5'b10000

// `define SYSMAP_BASE_ADDR7  28'hfffffff 
// `define SYSMAP_FLG7        5'b01111
// `endif

// 256K periphs @ AXI: Debug ROM
`define SYSMAP_BASE_ADDR0  28'h1000
`define SYSMAP_FLG0        5'b01111

// 4K periphs @ AXI: AXI DMA (Cfg)
`define SYSMAP_BASE_ADDR1  28'h2000
`define SYSMAP_FLG1        5'b10000

// 256K periphs @ Reg: Boot ROM
`define SYSMAP_BASE_ADDR2  28'h2040
`define SYSMAP_FLG2        5'b01111

// 256K periphs @ Reg: CLINT, IRQ router, AXI RT (Cfg)
`define SYSMAP_BASE_ADDR3  28'h3000
`define SYSMAP_FLG3        5'b10000

// 4K periphs @ Reg: SoC Regs, LLC (Cfg), UART, I2C, SPI Host, GPIO, Serial Link (Cfg), VGA (Cfg), UNBENT
`define SYSMAP_BASE_ADDR4  28'h4000
`define SYSMAP_FLG4        5'b10000

// INTCs @ Reg: PLIC, CLICs
`define SYSMAP_BASE_ADDR5  28'h1_0000
`define SYSMAP_FLG5        5'b10000

// LLC SPM @ AXI: cached
`define SYSMAP_BASE_ADDR6  28'h1_4000 
`define SYSMAP_FLG6        5'b01111

// LLC SPM @ AXI: uncached
`define SYSMAP_BASE_ADDR7  28'h1_8000
`define SYSMAP_FLG7        5'b00111