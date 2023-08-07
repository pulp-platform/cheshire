// Copyright 2023 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Thomas Benz <tbenz@iis.ee.ethz.ch>

`include "axi/typedef.svh"

/// Version 2 of a protocol converter from AXI4 to the register interface.
/// AXI Data Width >= Reg Data Width
module axi_to_reg_v2 #(
  /// The width of the address.
  parameter int unsigned AxiAddrWidth = 32'd0,
  /// The width of the data.
  parameter int unsigned AxiDataWidth = 32'd0,
  /// The width of the id.
  parameter int unsigned AxiIdWidth   = 32'd0,
  /// The width of the user signal.
  parameter int unsigned AxiUserWidth = 32'd0,
  /// The data width of the Reg bus
  parameter int unsigned RegDataWidth = 32'd0,
  /// AXI request struct type.
  parameter type         axi_req_t    = logic,
  /// AXI response struct type.
  parameter type         axi_rsp_t    = logic,
  /// Regbus request struct type.
  parameter type         reg_req_t    = logic,
  /// Regbus response struct type.
  parameter type         reg_rsp_t    = logic,
  /// Dependent parameter: ID Width
  parameter type         id_t         = logic[AxiIdWidth-1:0]
)(
  input  logic      clk_i,
  input  logic      rst_ni,
  input  axi_req_t  axi_req_i,
  output axi_rsp_t  axi_rsp_o,
  output reg_req_t  reg_req_o,
  input  reg_rsp_t  reg_rsp_i,
  output id_t       reg_id_o,
  output logic      busy_o
);

  // how many times is the AXI bus wider than the regbus?
  localparam int unsigned NumBanks = AxiDataWidth / RegDataWidth;

  localparam type addr_t     = logic [AxiAddrWidth-1  :0];
  localparam type reg_data_t = logic [RegDataWidth-1  :0];
  localparam type reg_strb_t = logic [RegDataWidth/8-1:0];

  // TCDM BUS
  logic      [NumBanks-1:0] mem_req;
  logic      [NumBanks-1:0] mem_gnt;
  addr_t     [NumBanks-1:0] mem_addr;
  reg_data_t [NumBanks-1:0] mem_wdata;
  reg_strb_t [NumBanks-1:0] mem_strb;
  logic      [NumBanks-1:0] mem_we;
  id_t       [NumBanks-1:0] mem_id;
  logic      [NumBanks-1:0] mem_rvalid;
  reg_data_t [NumBanks-1:0] mem_rdata;
  logic      [NumBanks-1:0] mem_err;

  // sub reg buses
  reg_req_t [NumBanks-1:0] reg_req, valid_req, zero_w_req;
  reg_rsp_t [NumBanks-1:0] reg_rsp, valid_rsp, zero_w_rsp;

  // convert to TCDM first
  axi_to_detailed_mem #(
    .axi_req_t    ( axi_req_t     ),
    .axi_resp_t   ( axi_rsp_t     ),
    .AddrWidth    ( AxiAddrWidth  ),
    .DataWidth    ( AxiDataWidth  ),
    .IdWidth      ( AxiIdWidth    ),
    .UserWidth    ( AxiUserWidth  ),
    .NumBanks     ( NumBanks      ),
    .BufDepth     ( 32'd1         ),
    .HideStrb     ( 1'b0          ),
    .OutFifoDepth ( 32'd1         )
  ) i_axi_to_detailed_mem (
    .clk_i,
    .rst_ni,
    .busy_o,
    .axi_req_i,
    .axi_resp_o   ( axi_rsp_o           ),
    .mem_req_o    ( mem_req             ),
    .mem_gnt_i    ( mem_gnt             ),
    .mem_addr_o   ( mem_addr            ),
    .mem_wdata_o  ( mem_wdata           ),
    .mem_strb_o   ( mem_strb            ),
    .mem_atop_o   ( /* NOT CONNECTED */ ),
    .mem_lock_o   ( /* NOT CONNECTED */ ),
    .mem_we_o     ( mem_we              ),
    .mem_id_o     ( mem_id              ),
    .mem_user_o   ( /* NOT CONNECTED */ ),
    .mem_cache_o  ( /* NOT CONNECTED */ ),
    .mem_prot_o   ( /* NOT CONNECTED */ ),
    .mem_qos_o    ( /* NOT CONNECTED */ ),
    .mem_region_o ( /* NOT CONNECTED */ ),
    .mem_rvalid_i ( mem_rvalid          ),
    .mem_rdata_i  ( mem_rdata           ),
    .mem_err_i    ( mem_err             ),
    .mem_exokay_i ( '0                  )
  );

  // every subbus is converted independently
  for (genvar i = 0; i < NumBanks; i++) begin : gen_tcdm_to_reg
    periph_to_reg #(
      .AW    ( AxiAddrWidth ),
      .DW    ( RegDataWidth ),
      .IW    ( AxiIdWidth   ),
      .req_t ( reg_req_t    ),
      .rsp_t ( reg_rsp_t    )
    ) i_periph_to_reg (
      .clk_i,
      .rst_ni,
      .req_i     ( mem_req    [i]      ),
      .add_i     ( mem_addr   [i]      ),
      .wen_i     ( !mem_we    [i]      ),
      .wdata_i   ( mem_wdata  [i]      ),
      .be_i      ( mem_strb   [i]      ),
      .id_i      ( '0                  ),
      .gnt_o     ( mem_gnt    [i]      ),
      .r_rdata_o ( mem_rdata  [i]      ),
      .r_opc_o   ( mem_err    [i]      ),
      .r_id_o    ( /* NOT CONNECTED */ ),
      .r_valid_o ( mem_rvalid [i]      ),
      .reg_req_o ( reg_req    [i]      ),
      .reg_rsp_i ( reg_rsp    [i]      )
    );

    // filter zero strobe writes early, directly ack them
    reg_demux #(
      .NoPorts ( 32'd2     ),
      .req_t   ( reg_req_t ),
      .rsp_t   ( reg_rsp_t )
    ) i_reg_demux (
      .clk_i,
      .rst_ni,
      .in_select_i ( reg_req[i].write & (reg_req[i].wstrb == '0) ),
      .in_req_i    ( reg_req[i]                                  ),
      .in_rsp_o    ( reg_rsp[i]                                  ),
      .out_req_o   ( {zero_w_req[i], valid_req[i]}               ),
      .out_rsp_i   ( {zero_w_rsp[i], valid_rsp[i]}               )
    );

    // ack zero strobe writes here
    assign zero_w_rsp[i].ready = 1'b1;
    assign zero_w_rsp[i].error = 1'b0;
    assign zero_w_rsp[i].rdata = '0;
  end

  // arbitrate over valid accesses in sub buses
  reg_mux #(
    .NoPorts( NumBanks     ),
    .AW     ( AxiAddrWidth ),
    .DW     ( AxiDataWidth ),
    .req_t  ( reg_req_t    ),
    .rsp_t  ( reg_rsp_t    )
  ) i_reg_mux (
    .clk_i,
    .rst_ni,
    .in_req_i  ( valid_req ),
    .in_rsp_o  ( valid_rsp ),
    .out_req_o ( reg_req_o ),
    .out_rsp_i ( reg_rsp_i )
  );

  // forward the id, all banks carry the same ID here
  assign reg_id_o = mem_id[0];

endmodule
