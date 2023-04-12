`include "phy_definitions.svh"

module dram_wrapper (
    // System reset
    input                              sys_rst,
    // Slave Interface Write Address Ports
    input                              aresetn,
    input  [5:0]                       s_axi_awid,
    input  [31:0]                      s_axi_awaddr,
    input  [7:0]                       s_axi_awlen,
    input  [2:0]                       s_axi_awsize,
    input  [1:0]                       s_axi_awburst,
    input  [0:0]                       s_axi_awlock,
    input  [3:0]                       s_axi_awcache,
    input  [2:0]                       s_axi_awprot,
    input  [3:0]                       s_axi_awqos,
    input                              s_axi_awvalid,
    output                             s_axi_awready,
    // Slave Interface Write Data Ports
    input  [511:0]                     s_axi_wdata,
    input  [63:0]                      s_axi_wstrb,
    input                              s_axi_wlast,
    input                              s_axi_wvalid,
    output                             s_axi_wready,
    // Slave Interface Write Response Ports
    input                              s_axi_bready,
    output [5:0]                       s_axi_bid,
    output [1:0]                       s_axi_bresp,
    output                             s_axi_bvalid,
    // Slave Interface Read Address Ports
    input  [5:0]                       s_axi_arid,
    input  [31:0]                      s_axi_araddr,
    input  [7:0]                       s_axi_arlen,
    input  [2:0]                       s_axi_arsize,
    input  [1:0]                       s_axi_arburst,
    input  [0:0]                       s_axi_arlock,
    input  [3:0]                       s_axi_arcache,
    input  [2:0]                       s_axi_arprot,
    input  [3:0]                       s_axi_arqos,
    input                              s_axi_arvalid,
    output                             s_axi_arready,
    // Slave Interface Read Data Ports
    input                              s_axi_rready,
    output [5:0]                       s_axi_rid,
    output [511:0]                     s_axi_rdata,
    output [1:0]                       s_axi_rresp,
    output                             s_axi_rlast,
    output                             s_axi_rvalid,
    // Clk out (referenced in constraints file)
    (* dont_touch = "yes" *) output    clk_o,
    (* dont_touch = "yes" *) output    addn_clk_1_o,
    output                             sync_rst_o,
    // Phy interface for DDR4
    `ifdef USE_DDR4
    `DDR4_INTF
    `endif
);

`ifdef USE_DDR4

// Todo use a reset synchronizer to synch on addn_ui_clkout1?

xlnx_mig_ddr4 i_dram (
    // Rst
    .   sys_rst                     ( sys_rst        ),
    .   c0_ddr4_aresetn             ( aresetn        ),
    // Clk rst out
    .   c0_ddr4_ui_clk              ( clk_o          ),
    .   c0_ddr4_ui_clk_sync_rst     ( sync_rst_o     ),
    // Axi
    .   c0_ddr4_s_axi_awid          ( s_axi_awid     ),
    .   c0_ddr4_s_axi_awaddr        ( s_axi_awaddr   ),
    .   c0_ddr4_s_axi_awlen         ( s_axi_awlen    ),
    .   c0_ddr4_s_axi_awsize        ( s_axi_awsize   ),
    .   c0_ddr4_s_axi_awburst       ( s_axi_awburst  ),
    .   c0_ddr4_s_axi_awlock        ( s_axi_awlock   ),
    .   c0_ddr4_s_axi_awcache       ( s_axi_awcache  ),
    .   c0_ddr4_s_axi_awprot        ( s_axi_awprot   ),
    .   c0_ddr4_s_axi_awqos         ( s_axi_awqos    ),
    .   c0_ddr4_s_axi_awvalid       ( s_axi_awvalid  ),
    .   c0_ddr4_s_axi_awready       ( s_axi_awready  ),
    .   c0_ddr4_s_axi_wdata         ( s_axi_wdata    ),
    .   c0_ddr4_s_axi_wstrb         ( s_axi_wstrb    ),
    .   c0_ddr4_s_axi_wlast         ( s_axi_wlast    ),
    .   c0_ddr4_s_axi_wvalid        ( s_axi_wvalid   ),
    .   c0_ddr4_s_axi_wready        ( s_axi_wready   ),
    .   c0_ddr4_s_axi_bready        ( s_axi_bready   ),
    .   c0_ddr4_s_axi_bid           ( s_axi_bid      ),
    .   c0_ddr4_s_axi_bresp         ( s_axi_bresp    ),
    .   c0_ddr4_s_axi_bvalid        ( s_axi_bvalid   ),
    .   c0_ddr4_s_axi_arid          ( s_axi_arid     ),
    .   c0_ddr4_s_axi_araddr        ( s_axi_araddr   ),
    .   c0_ddr4_s_axi_arlen         ( s_axi_arlen    ),
    .   c0_ddr4_s_axi_arsize        ( s_axi_arsize   ),
    .   c0_ddr4_s_axi_arburst       ( s_axi_arburst  ),
    .   c0_ddr4_s_axi_arlock        ( s_axi_arlock   ),
    .   c0_ddr4_s_axi_arcache       ( s_axi_arcache  ),
    .   c0_ddr4_s_axi_arprot        ( s_axi_arprot   ),
    .   c0_ddr4_s_axi_arqos         ( s_axi_arqos    ),
    .   c0_ddr4_s_axi_arvalid       ( s_axi_arvalid  ),
    .   c0_ddr4_s_axi_arready       ( s_axi_arready  ),
    .   c0_ddr4_s_axi_rready        ( s_axi_rready   ),
    .   c0_ddr4_s_axi_rid           ( s_axi_rid      ),
    .   c0_ddr4_s_axi_rdata         ( s_axi_rdata    ),
    .   c0_ddr4_s_axi_rresp         ( s_axi_rresp    ),
    .   c0_ddr4_s_axi_rlast         ( s_axi_rlast    ),
    .   c0_ddr4_s_axi_rvalid        ( s_axi_rvalid   ),
    // Axi ctrl
    .   c0_ddr4_s_axi_ctrl_awvalid  ( '0             ),
    .   c0_ddr4_s_axi_ctrl_awready  (                ),
    .   c0_ddr4_s_axi_ctrl_awaddr   ( '0             ),
    .   c0_ddr4_s_axi_ctrl_wvalid   ( '0             ),
    .   c0_ddr4_s_axi_ctrl_wready   (                ),
    .   c0_ddr4_s_axi_ctrl_wdata    ( '0             ),
    .   c0_ddr4_s_axi_ctrl_bvalid   (                ),
    .   c0_ddr4_s_axi_ctrl_bready   ( '0             ),
    .   c0_ddr4_s_axi_ctrl_bresp    (                ),
    .   c0_ddr4_s_axi_ctrl_arvalid  ( '0             ),
    .   c0_ddr4_s_axi_ctrl_arready  (                ),
    .   c0_ddr4_s_axi_ctrl_araddr   ( '0             ),
    .   c0_ddr4_s_axi_ctrl_rvalid   (                ),
    .   c0_ddr4_s_axi_ctrl_rready   ( '0             ),
    .   c0_ddr4_s_axi_ctrl_rdata    (                ),
    .   c0_ddr4_s_axi_ctrl_rresp    (                ),
    // Others
    .   c0_init_calib_complete      (                ), // keep open
    .   addn_ui_clkout1             ( addn_clk_1_o   ),
    .   dbg_clk                     (                ),
    .   c0_ddr4_interrupt           (                ),
    .   dbg_bus                     (                ),
    // Phy
    .*
);
`endif

`ifdef USE_DDR3
xlnx_mig_7_ddr3 i_dram (
    .sys_clk_p           ( sysclk_p               ),
    .sys_clk_n           ( sysclk_n               ),
    .sys_rst             ( cpu_resetn             ),
    .ui_clk              ( dram_clock_out         ),
    .ui_clk_sync_rst     ( dram_sync_reset        ),
    
    .mmcm_locked         (                        ), // keep open
    .app_sr_req          ( '0                     ),
    .app_ref_req         ( '0                     ),
    .app_zq_req          ( '0                     ),
    .app_sr_active       (                        ), // keep open
    .app_ref_ack         (                        ), // keep open
    .app_zq_ack          (                        ), // keep open
    .aresetn             ( rst_n                  ),
    .s_axi_awid          ( s_axi_awid             ),
    .s_axi_awaddr        ( s_axi_awaddr[29:0]     ),
    .s_axi_awlen         ( s_axi_awlen            ),
    .s_axi_awsize        ( s_axi_awsize           ),
    .s_axi_awburst       ( s_axi_awburst          ),
    .s_axi_awlock        ( s_axi_awlock           ),
    .s_axi_awcache       ( s_axi_awcache          ),
    .s_axi_awprot        ( s_axi_awprot           ),
    .s_axi_awqos         ( s_axi_awqos            ),
    .s_axi_awvalid       ( s_axi_aw_valid         ),
    .s_axi_awready       ( dram_respaw_ready      ),
    .s_axi_wdata         ( s_axi_wdata            ),
    .s_axi_wstrb         ( s_axi_wstrb            ),
    .s_axi_wlast         ( s_axi_wlast            ),
    .s_axi_wvalid        ( s_axi_w_valid          ),
    .s_axi_wready        ( dram_respw_ready       ),
    .s_axi_bready        ( s_axi_b_ready          ),
    .s_axi_bid           ( s_axi_bid              ),
    .s_axi_bresp         ( s_axi_bresp            ),
    .s_axi_bvalid        ( s_axi_b_valid          ),
    .s_axi_arid          ( s_axi_arid             ),
    .s_axi_araddr        ( s_axi_araddr[29:0]     ),
    .s_axi_arlen         ( s_axi_arlen            ),
    .s_axi_arsize        ( s_axi_arsize           ),
    .s_axi_arburst       ( s_axi_arburst          ),
    .s_axi_arlock        ( s_axi_arlock           ),
    .s_axi_arcache       ( s_axi_arcache          ),
    .s_axi_arprot        ( s_axi_arprot           ),
    .s_axi_arqos         ( s_axi_arqos            ),
    .s_axi_arvalid       ( s_axi_ar_valid         ),
    .s_axi_arready       ( s_axi_ar_ready         ),
    .s_axi_rready        ( s_axi_r_ready          ),
    .s_axi_rid           ( s_axi_rid              ),
    .s_axi_rdata         ( s_axi_rdata            ),
    .s_axi_rresp         ( s_axi_rresp            ),
    .s_axi_rlast         ( s_axi_rlast            ),
    .s_axi_rvalid        ( s_axi_r_valid          ),
    .init_calib_complete (                        ),  // keep open
    .device_temp         (                        )   // keep open
  );
`endif

endmodule