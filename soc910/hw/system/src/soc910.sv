// Copyright 2023 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Nils Wistoff <nwistoff@iis.ee.ethz.ch>

`include "axi/assign.svh"

module soc910 import soc910_pkg::*; (
  input  logic            clk_i           ,
  input  logic            rst_ni          ,
  // To main memory (platform-specific)
  output axi_slave_req_t  axi_dram_req_o  ,
  input  axi_slave_resp_t axi_dram_resp_i ,
  // To debug master
  input  axi_master_req_t  axi_debug_req_i  ,
  output axi_master_resp_t axi_debug_resp_o ,
  // common part
  // input logic      trst_n      ,
  input  logic            tck             ,
  input  logic            tms             ,
  input  logic            tdi             ,
  output wire             tdo             ,
  output wire             tdo_en          ,
  input  logic            rx              ,
  output logic            tx
);

// disable test-enable
logic test_en;
logic debug_req_irq;
logic timer_irq;
logic ipi;
logic irq_uart;

// ROM
logic                    rom_req;
logic [AxiAddrWidth-1:0] rom_addr;
logic [AxiDataWidth-1:0] rom_rdata;

// IRQ
logic [1:0] irq;
assign test_en    = 1'b0;


// ---------------
// AXI Xbar
// ---------------

typedef enum int unsigned {
  DRAM     = 0,
  GPIO     = 1,
  Ethernet = 2,
  SPI      = 3,
  Timer    = 4,
  UART     = 5,
  PLIC     = 6,
  CLINT    = 7,
  ROM      = 8
} axi_slaves_t;

localparam NrPeripherals = ROM + 1;

localparam logic[63:0] ROMLength      = 64'h10000;
localparam logic[63:0] CLINTLength    = 64'hC0000;
localparam logic[63:0] PLICLength     = 64'h3FF_FFFF;
localparam logic[63:0] UARTLength     = 64'h1000;
localparam logic[63:0] TimerLength    = 64'h1000;
localparam logic[63:0] SPILength      = 64'h800000;
localparam logic[63:0] EthernetLength = 64'h10000;
localparam logic[63:0] GPIOLength     = 64'h1000;
localparam logic[63:0] DRAMLength     = 64'h40000000; // 1GByte of DDR (split between two chips on Genesys2)
localparam logic[63:0] SRAMLength     = 64'h1800000;  // 24 MByte of SRAM
// Instantiate AXI protocol checkers
localparam bit GenProtocolChecker = 1'b0;

typedef enum logic [63:0] {
  ROMBase      = 64'h0000_0000,
  CLINTBase    = 64'h0200_0000,
  PLICBase     = 64'h0C00_0000,
  UARTBase     = 64'h1000_0000,
  TimerBase    = 64'h1800_0000,
  SPIBase      = 64'h2000_0000,
  EthernetBase = 64'h3000_0000,
  GPIOBase     = 64'h4000_0000,
  DRAMBase     = 64'h8000_0000
} soc_bus_start_t;

typedef struct packed {
  int unsigned idx;
  logic [39:0] start_addr;
  logic [39:0] end_addr;
} xbar_rule_40_t;

xbar_rule_40_t [NrPeripherals-1:0] addr_map;

assign addr_map = '{
  '{ idx: ROM,      start_addr: ROMBase,      end_addr: ROMBase + ROMLength           },
  '{ idx: CLINT,    start_addr: CLINTBase,    end_addr: CLINTBase + CLINTLength       },
  '{ idx: PLIC,     start_addr: PLICBase,     end_addr: PLICBase + PLICLength         },
  '{ idx: UART,     start_addr: UARTBase,     end_addr: UARTBase + UARTLength         },
  '{ idx: Timer,    start_addr: TimerBase,    end_addr: TimerBase + TimerLength       },
  '{ idx: SPI,      start_addr: SPIBase,      end_addr: SPIBase + SPILength           },
  '{ idx: Ethernet, start_addr: EthernetBase, end_addr: EthernetBase + EthernetLength },
  '{ idx: GPIO,     start_addr: GPIOBase,     end_addr: GPIOBase + GPIOLength         },
  '{ idx: DRAM,     start_addr: DRAMBase,     end_addr: DRAMBase + DRAMLength         }
};

localparam axi_pkg::xbar_cfg_t AxiXbarCfg = '{
  NoSlvPorts:         NrMasters,
  NoMstPorts:         NrPeripherals,
  MaxMstTrans:        1,
  MaxSlvTrans:        1,
  FallThrough:        1'b0,
  LatencyMode:        axi_pkg::CUT_ALL_PORTS,
  AxiIdWidthSlvPorts: AxiIdWidthMaster,
  AxiIdUsedSlvPorts:  AxiIdWidthMaster,
  UniqueIds:          1'b0,
  AxiAddrWidth:       AxiAddrWidth,
  AxiDataWidth:       AxiDataWidth,
  NoAddrRules:        NrPeripherals
};

localparam int unsigned AxiXbarCombs = NrMasters * NrPeripherals;
localparam logic [AxiXbarCombs-1:0] AxiXbarConnectivity = {AxiXbarCombs{1'b1}};

axi_master_req_t  [NrMasters-1:0]     axi_xbar_slv_port_reqs;
axi_master_resp_t [NrMasters-1:0]     axi_xbar_slv_port_rsps;
axi_slave_req_t   [NrPeripherals-1:0] axi_xbar_mst_port_reqs;
axi_slave_resp_t  [NrPeripherals-1:0] axi_xbar_mst_port_rsps;

axi_xbar #(
    .Cfg            ( AxiXbarCfg           ),
    .ATOPs          ( 1'b1                 ),
    .Connectivity   ( AxiXbarConnectivity  ),
    .slv_aw_chan_t  ( axi_master_aw_chan_t ),
    .mst_aw_chan_t  ( axi_slave_aw_chan_t  ),
    .w_chan_t       ( axi_master_w_chan_t  ),
    .slv_b_chan_t   ( axi_master_b_chan_t  ),
    .mst_b_chan_t   ( axi_slave_b_chan_t   ),
    .slv_ar_chan_t  ( axi_master_ar_chan_t ),
    .mst_ar_chan_t  ( axi_slave_ar_chan_t  ),
    .slv_r_chan_t   ( axi_master_r_chan_t  ),
    .mst_r_chan_t   ( axi_slave_r_chan_t   ),
    .slv_req_t      ( axi_master_req_t     ),
    .slv_resp_t     ( axi_master_resp_t    ),
    .mst_req_t      ( axi_slave_req_t      ),
    .mst_resp_t     ( axi_slave_resp_t     ),
    .rule_t         ( xbar_rule_40_t       )
  ) i_axi_xbar (
    .clk_i                  ( clk_i                  ),
    .rst_ni                 ( rst_ni                 ),
    .test_i                 ( test_en                ),
    .slv_ports_req_i        ( axi_xbar_slv_port_reqs ),
    .slv_ports_resp_o       ( axi_xbar_slv_port_rsps ),
    .mst_ports_req_o        ( axi_xbar_mst_port_reqs ),
    .mst_ports_resp_i       ( axi_xbar_mst_port_rsps ),
    .addr_map_i             ( addr_map               ),
    .en_default_mst_port_i  ( '0                     ),
    .default_mst_port_i     ( '0                     )
  );

assign axi_xbar_slv_port_reqs[1] = axi_debug_req_i;
assign axi_debug_resp_o          = axi_xbar_slv_port_rsps[1];


// ---------------
// Core
// ---------------

c910_axi_wrap #(
    .axi_req_t ( axi_master_req_t  ),
    .axi_rsp_t ( axi_master_resp_t )
) i_c910_axi_wrap (
    .clk_i        ( clk_i                     ),
    .rst_ni       ( rst_ni                    ),
    .ext_int_i    ( {39'h0, irq_uart}         ),
    .jtag_tck_i   ( tck                       ),
    .jtag_tdi_i   ( tdi                       ),
    .jtag_tms_i   ( tms                       ),
    .jtag_tdo_o   ( tdo                       ),
    .jtag_tdo_en_o ( tdo_en                   ),
    .jtag_trst_ni ( 1'b1                      ),
    .axi_req_o    ( axi_xbar_slv_port_reqs[0] ),
    .axi_rsp_i    ( axi_xbar_slv_port_rsps[0] )
);


// ---------------
// UART
// ---------------

axi_narrow_req_t  axi_uart_req;
axi_narrow_resp_t axi_uart_resp;

axi_dw_converter #(
  .AxiSlvPortDataWidth ( AxiDataWidth         ),
  .AxiMstPortDataWidth ( 32'd32               ),
  .AxiAddrWidth        ( AxiAddrWidth         ),
  .AxiIdWidth          ( AxiIdWidthSlaves     ),
  .aw_chan_t           ( axi_narrow_aw_chan_t ),
  .mst_w_chan_t        ( axi_narrow_w_chan_t  ),
  .slv_w_chan_t        ( axi_slave_w_chan_t   ),
  .b_chan_t            ( axi_narrow_b_chan_t  ),
  .ar_chan_t           ( axi_narrow_ar_chan_t ),
  .mst_r_chan_t        ( axi_narrow_r_chan_t  ),
  .slv_r_chan_t        ( axi_slave_r_chan_t   ),
  .axi_mst_req_t       ( axi_narrow_req_t     ),
  .axi_mst_resp_t      ( axi_narrow_resp_t    ),
  .axi_slv_req_t       ( axi_slave_req_t      ),
  .axi_slv_resp_t      ( axi_slave_resp_t     )
) i_axi_dw_converter_regbus (
  .clk_i      ( clk_i                        ),
  .rst_ni     ( rst_ni                       ),
  .slv_req_i  ( axi_xbar_mst_port_reqs[UART] ),
  .slv_resp_o ( axi_xbar_mst_port_rsps[UART] ),
  .mst_req_o  ( axi_uart_req                 ),
  .mst_resp_i ( axi_uart_resp                )
);

axi_lite_req_t  axi_lite_uart_req;
axi_lite_resp_t axi_lite_uart_resp;

axi_to_axi_lite #(
  .AxiAddrWidth    ( AxiAddrWidth      ),
  .AxiDataWidth    ( 32'd32            ),
  .AxiIdWidth      ( AxiIdWidthSlaves  ),
  .AxiUserWidth    ( AxiUserWidth      ),
  .AxiMaxWriteTxns ( 32'd1             ),
  .AxiMaxReadTxns  ( 32'd1             ),
  .FallThrough     ( 1'b1              ),
  .full_req_t      ( axi_narrow_req_t  ),
  .full_resp_t     ( axi_narrow_resp_t ),
  .lite_req_t      ( axi_lite_req_t    ),
  .lite_resp_t     ( axi_lite_resp_t   )
) i_axi_to_axi_lite_uart (
  .clk_i      ( clk_i              ),
  .rst_ni     ( rst_ni             ),
  .test_i     ( 1'b0               ),
  .slv_req_i  ( axi_uart_req       ),
  .slv_resp_o ( axi_uart_resp      ),
  .mst_req_o  ( axi_lite_uart_req  ),
  .mst_resp_i ( axi_lite_uart_resp )
);

typedef struct packed {
  int unsigned idx;
  logic [ AxiAddrWidth-1:0] start_addr;
  logic [ AxiAddrWidth-1:0] end_addr;
} apb_rule_t;

localparam apb_rule_t apb_map = '{idx: 32'd0,
                                  start_addr: 32'h0,
                                  end_addr: 32'hffff_ffff};

apb_req_t  apb_uart_req;
apb_resp_t apb_uart_resp;

axi_lite_to_apb #(
  .NoApbSlaves      ( 32'd1           ),
  .NoRules          ( 32'd1           ),
  .AddrWidth        ( AxiAddrWidth    ),
  .DataWidth        ( 32'd32          ),
  .PipelineRequest  ( 1'b0            ),
  .PipelineResponse ( 1'b0            ),
  .axi_lite_req_t   ( axi_lite_req_t  ),
  .axi_lite_resp_t  ( axi_lite_resp_t ),
  .apb_req_t        ( apb_req_t       ),
  .apb_resp_t       ( apb_resp_t      ),
  .rule_t           ( apb_rule_t      )
) i_axi_lite_to_apb_uart (
  .clk_i           ( clk_i              ),
  .rst_ni          ( rst_ni             ),
  .axi_lite_req_i  ( axi_lite_uart_req  ),
  .axi_lite_resp_o ( axi_lite_uart_resp ),
  .apb_req_o       ( apb_uart_req       ),
  .apb_resp_i      ( apb_uart_resp      ),
  .addr_map_i      ( apb_map            )
);

apb_uart i_apb_uart (
    .CLK     ( clk_i                   ),
    .RSTN    ( rst_ni                  ),
    .PSEL    ( apb_uart_req.psel       ),
    .PENABLE ( apb_uart_req.penable    ),
    .PWRITE  ( apb_uart_req.pwrite     ),
    .PADDR   ( apb_uart_req.paddr[4:2] ),
    .PWDATA  ( apb_uart_req.pwdata     ),
    .PRDATA  ( apb_uart_resp.prdata    ),
    .PREADY  ( apb_uart_resp.pready    ),
    .PSLVERR ( apb_uart_resp.pslverr   ),
    .INT     ( irq_uart                ),
    .OUT1N   (                         ), // keep open
    .OUT2N   (                         ), // keep open
    .RTSN    (                         ), // no flow control
    .DTRN    (                         ), // no flow control
    .CTSN    ( 1'b0                    ),
    .DSRN    ( 1'b0                    ),
    .DCDN    ( 1'b0                    ),
    .RIN     ( 1'b0                    ),
    .SIN     ( rx                      ),
    .SOUT    ( tx                      )
);


// // ---------------
// // CLINT
// // ---------------
// // divide clock by two
// always_ff @(posedge clk or negedge rst_ni    ) begin
//   if (~rst_ni    ) begin
//     rtc <= 0;
//   end else begin
//     rtc <= rtc ^ 1'b1;
//   end
// end

// axi_slave_req_t  axi_clint_req;
// axi_slave_resp_t axi_clint_resp;

// clint #(
//     .AXI_ADDR_WIDTH ( AxiAddrWidth     ),
//     .AXI_DATA_WIDTH ( AxiDataWidth     ),
//     .AXI_ID_WIDTH   ( AxiIdWidthSlaves ),
//     .NR_CORES       ( 1                ),
//     .axi_req_t      ( axi_slave_req_t  ),
//     .axi_resp_t     ( axi_slave_resp_t )
// ) i_clint (
//     .clk_i       ( clk_i          ),
//     .rst_ni      ( rst_ni         ),
//     .testmode_i  ( test_en        ),
//     .axi_req_i   ( axi_clint_req  ),
//     .axi_resp_o  ( axi_clint_resp ),
//     .rtc_i       ( rtc            ),
//     .timer_irq_o ( timer_irq      ),
//     .ipi_o       ( ipi            )
// );

// `AXI_ASSIGN_TO_REQ(axi_clint_req, master[CLINT])
// `AXI_ASSIGN_FROM_RESP(master[CLINT], axi_clint_resp)

// // ---------------
// // ROM
// // ---------------
// axi2mem #(
//     .AXI_ID_WIDTH   ( AxiIdWidthSlaves ),
//     .AXI_ADDR_WIDTH ( AxiAddrWidth     ),
//     .AXI_DATA_WIDTH ( AxiDataWidth     ),
//     .AXI_USER_WIDTH ( AxiUserWidth     )
// ) i_axi2rom (
//     .clk_i  ( clk_i                   ),
//     .rst_ni ( rst_ni                  ),
//     .slave  ( master[ariane_soc::ROM] ),
//     .req_o  ( rom_req                 ),
//     .we_o   (                         ),
//     .addr_o ( rom_addr                ),
//     .be_o   (                         ),
//     .data_o (                         ),
//     .data_i ( rom_rdata               )
// );

// if (riscv::XLEN==32 ) begin
//     bootrom_32 i_bootrom (
//         .clk_i   ( clk_i     ),
//         .req_i   ( rom_req   ),
//         .addr_i  ( rom_addr  ),
//         .rdata_o ( rom_rdata )
//     );
// end else begin 
//     bootrom_64 i_bootrom (
//         .clk_i   ( clk_i     ),
//         .req_i   ( rom_req   ),
//         .addr_i  ( rom_addr  ),
//         .rdata_o ( rom_rdata )
//     );
// end

// // ---------------
// // Peripherals
// // ---------------
// `ifdef KC705
//   logic [7:0] unused_led;
//   logic [3:0] unused_switches = 4'b0000;
// `endif

// ariane_peripherals #(
//     .AxiAddrWidth ( AxiAddrWidth     ),
//     .AxiDataWidth ( AxiDataWidth     ),
//     .AxiIdWidth   ( AxiIdWidthSlaves ),
//     .AxiUserWidth ( AxiUserWidth     ),
//     .InclUART     ( 1'b1             ),
//     .InclGPIO     ( 1'b1             ),
//     `ifdef KINTEX7
//     .InclSPI      ( 1'b1         ),
//     .InclEthernet ( 1'b1         )
//     `elsif KC705
//     .InclSPI      ( 1'b1         ),
//     .InclEthernet ( 1'b0         ) // Ethernet requires RAMB16 fpga/src/ariane-ethernet/dualmem_widen8.sv to be defined
//     `elsif VC707
//     .InclSPI      ( 1'b1         ),
//     .InclEthernet ( 1'b0         )
//     `elsif VCU118
//     .InclSPI      ( 1'b0         ),
//     .InclEthernet ( 1'b0         )
//     `endif
// ) i_ariane_peripherals (
//     .clk_i        ( clk_i                        ),
//     .clk_200MHz_i ( ddr_clock_out                ),
//     .rst_ni       ( rst_ni                       ),
//     .plic         ( master[PLIC]     ),
//     .uart         ( master[UART]     ),
//     .spi          ( master[SPI]      ),
//     .gpio         ( master[GPIO]     ),
//     .eth_clk_i    ( eth_clk                      ),
//     .ethernet     ( master[Ethernet] ),
//     .timer        ( master[Timer]    ),
//     .irq_o        ( irq                          ),
//     .rx_i         ( rx                           ),
//     .tx_o         ( tx                           ),
//     .eth_txck,
//     .eth_rxck,
//     .eth_rxctl,
//     .eth_rxd,
//     .eth_rst_n,
//     .eth_txctl,
//     .eth_txd,
//     .eth_mdio,
//     .eth_mdc,
//     .dram_clk_i   ( phy_tx_clk                  ),
//     .sd_clk_i       ( sd_clk_sys                  ),
//     .spi_clk_o      ( spi_clk_o                   ),
//     .spi_mosi       ( spi_mosi                    ),
//     .spi_miso       ( spi_miso                    ),
//     .spi_ss         ( spi_ss                      ),
//     `ifdef KC705
//       .leds_o         ( {led[3:0], unused_led[7:4]}),
//       .dip_switches_i ( {sw, unused_switches}     )
//     `else
//       .leds_o         ( led                       ),
//       .dip_switches_i ( sw                        )
//     `endif
// );

AXI_BUS #(
    .AXI_ADDR_WIDTH ( AxiAddrWidth     ),
    .AXI_DATA_WIDTH ( AxiDataWidth     ),
    .AXI_ID_WIDTH   ( AxiIdWidthSlaves ),
    .AXI_USER_WIDTH ( AxiUserWidth     )
) dram_amo[0:0]();

AXI_BUS #(
    .AXI_ADDR_WIDTH ( AxiAddrWidth     ),
    .AXI_DATA_WIDTH ( AxiDataWidth     ),
    .AXI_ID_WIDTH   ( AxiIdWidthSlaves ),
    .AXI_USER_WIDTH ( AxiUserWidth     )
) dram[0:0]();

`AXI_ASSIGN_FROM_REQ(dram_amo[0], axi_xbar_mst_port_reqs[DRAM])
`AXI_ASSIGN_TO_RESP(axi_xbar_mst_port_rsps[DRAM], dram_amo[0])

axi_riscv_atomics_wrap #(
    .AXI_ADDR_WIDTH     ( AxiAddrWidth     ),
    .AXI_DATA_WIDTH     ( AxiDataWidth     ),
    .AXI_ID_WIDTH       ( AxiIdWidthSlaves ),
    .AXI_USER_WIDTH     ( AxiUserWidth     ),
    .AXI_MAX_READ_TXNS  ( 1                ),
    .AXI_MAX_WRITE_TXNS ( 1                ),
    .RISCV_WORD_WIDTH   ( 64               )
) i_axi_riscv_atomics (
    .clk_i  ( clk_i       ),
    .rst_ni ( rst_ni      ),
    .slv    ( dram_amo[0] ),
    .mst    ( dram[0]     )
);

`AXI_ASSIGN_TO_REQ(axi_dram_req_o, dram[0])
`AXI_ASSIGN_FROM_RESP(dram[0], axi_dram_resp_i)

endmodule
