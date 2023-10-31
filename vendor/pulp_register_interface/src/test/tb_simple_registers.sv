// Copyright 2023 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.
//
// Michael Rogenmoser <michaero@iis.ee.ethz.ch>

`include "register_interface/typedef.svh"
`include "register_interface/assign.svh"

module tb_simple_registers;

  localparam int AddrWidth = 32;
  localparam int DataWidth = 32;

  logic clk, rst_n;

  REG_BUS #(
    .DATA_WIDTH(DataWidth),
    .ADDR_WIDTH(AddrWidth)
  ) bus (.clk_i(clk));

  `REG_BUS_TYPEDEF_ALL(reg, logic[AddrWidth-1:0], logic[DataWidth-1:0], logic[DataWidth/8-1:0])
  reg_req_t reg_req;
  reg_rsp_t reg_rsp;

  `REG_BUS_ASSIGN_TO_REQ(reg_req, bus)
  `REG_BUS_ASSIGN_FROM_RSP(bus, reg_rsp)

  clk_rst_gen #(
    .ClkPeriod    ( 10ns ),
    .RstClkCycles ( 5    )
  ) i_clk_gen (
    .clk_o  ( clk   ),
    .rst_no ( rst_n )
  );

  import test_regs_reg_pkg::* ;

  test_regs_reg_top #(
    .reg_req_t ( reg_req_t ),
    .reg_rsp_t ( reg_rsp_t ),
    .AW        ( AddrWidth )
  ) i_test_regs (
    .clk_i    (clk),
    .rst_ni   (rst_n),
    .reg_req_i(reg_req),
    .reg_rsp_o(reg_rsp),
    .reg2hw   (),
    .hw2reg   ('0),
    .devmode_i(1'b1)
  );

  initial begin
    automatic reg_test::reg_driver #(
      .AW(AddrWidth),
      .DW(DataWidth),
      .TA(2ns),
      .TT(8ns)
    ) driver = new ( bus );
    automatic logic error;
    automatic logic [DataWidth-1:0] data;

    driver.reset_master();
    @(posedge rst_n);
    driver.send_write(32'h0000_0000, 32'hdeadbeef, 4'hf, error);
    if (error != 1'b0) $error("unexpected error");
    driver.send_read(32'h0000_0000, data, error);
    if (error != 1'b0) $error("unexpected error");
    if (data != 32'hdeadbeef) $error("unexpected data");
    repeat (10) @(posedge clk);
    $stop();
  end

endmodule
