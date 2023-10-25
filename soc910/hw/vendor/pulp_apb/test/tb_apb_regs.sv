// Copyright 2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

// Author: Wolfgang Roenninger <wreonnin@ethz.ch>

// Description: Testbench for `apb_rw_regs`.
//   Step 1: Read over a range of addresses, where the registers are inbetween.
//   Step 2: Random reads and writes to the different registers.
// Assertions provide checking for correct functionality.

`include "apb/assign.svh"

module tb_apb_regs;

  localparam int unsigned ApbAddrWidth   = 32'd32;
  localparam int unsigned ApbDataWidth   = 32'd27;
  localparam int unsigned ApbStrbWidth   = cf_math_pkg::ceil_div(ApbDataWidth, 8);
  localparam int unsigned RegDataWidth   = 32'd16;

  localparam int unsigned NoApbRegs      = 32'd342;
  localparam logic [NoApbRegs-1:0] ReadOnly = 342'hFFF0;

  localparam time         CyclTime       = 10ns;
  localparam time         ApplTime       = 2ns;
  localparam time         TestTime       = 8ns;
  localparam int unsigned NoRandAccesses = 32'd50000;

  typedef logic [ApbAddrWidth-1:0] apb_addr_t;
  typedef logic [ApbDataWidth-1:0] apb_data_t;
  typedef logic [ApbStrbWidth-1:0] apb_strb_t;
  typedef logic [RegDataWidth-1:0] reg_data_t;

  localparam apb_addr_t BaseAddr      = 32'h0003_0000;
  localparam apb_addr_t TestStartAddr = 32'h0002_FF00;
  localparam apb_addr_t TestEndAddr   = 32'h0003_0F00;


  logic                      clk;
  logic                      rst_n;
  logic                      done;
  apb_addr_t                 last_addr;
  reg_data_t [NoApbRegs-1:0] reg_data,  reg_init, reg_compare;


  APB_DV #(
    .ADDR_WIDTH ( ApbAddrWidth ),
    .DATA_WIDTH ( ApbDataWidth )
  ) apb_slave_dv(clk);
  APB #(
    .ADDR_WIDTH ( ApbAddrWidth ),
    .DATA_WIDTH ( ApbDataWidth )
  ) apb_slave();
  `APB_ASSIGN ( apb_slave, apb_slave_dv )

  //-----------------------------------
  // Clock generator
  //-----------------------------------
  clk_rst_gen #(
    .CLK_PERIOD    ( CyclTime ),
    .RST_CLK_CYCLES( 5        )
  ) i_clk_gen (
    .clk_o (clk),
    .rst_no(rst_n)
  );

  apb_test::apb_driver #(
    .ADDR_WIDTH ( ApbAddrWidth ),
    .DATA_WIDTH ( ApbDataWidth ),
    .TA         ( ApplTime     ),
    .TT         ( TestTime     )
  ) apb_master = new(apb_slave_dv);

  initial begin : proc_apb_master
    automatic apb_addr_t addr;
    automatic apb_data_t data;
    automatic apb_strb_t strb;
    automatic logic      resp;
    automatic bit        w;
    automatic reg_data_t init_val;
    // initialize reset values and golden model
    for (int unsigned i = 0; i < NoApbRegs; i++) begin
      init_val       = reg_data_t'($urandom());
      reg_init[i]    = init_val;
      reg_compare[i] = init_val;
    end
    done <= 1'b0;

    // reset dut
    @(posedge rst_n);
    apb_master.reset_master();
    repeat (10) @(posedge clk);

    // First test
    addr = apb_addr_t'(BaseAddr);
    data = apb_data_t'(32'd0000_0000);
    strb = apb_strb_t'(4'hF);

    apb_master.write( addr, data, strb, resp);
    $display("Write addr: %0h", addr);
    $display("Write data: %0h strb: %0h", data, strb);
    $display("Write resp: %0h", resp);
    assert(resp == apb_pkg::RESP_OKAY);
    if (resp == apb_pkg::RESP_OKAY) begin
      // update golden model
      $display("Update golden model");
      for (int unsigned j = 0; j < RegDataWidth; j++) begin
        if (strb[j/8]) begin
          $info("Write bit @%0h, bit: %0h", addr>>2, j);
          reg_compare[(addr-BaseAddr)>>2][j] = data[j];
        end
      end
    end

    // Step 1
    for (int unsigned i = TestStartAddr; i < TestEndAddr; i++) begin
      addr = apb_addr_t'(i);
      apb_master.read(addr, data, resp);
      $display("Read from addr: %0h", addr);
      $display("Read data: %0h", data);
      $display("Read resp: %0h", resp);
      repeat ($urandom_range(0,5)) @(posedge clk);
    end

    // Step 2
    for (int unsigned i = 0; i < NoRandAccesses; i++) begin
      w    = bit'($urandom());
      addr = apb_addr_t'($urandom_range(TestStartAddr, TestEndAddr));
      data = apb_data_t'($urandom());
      strb = apb_strb_t'($urandom());
      if (w) begin
        apb_master.write( addr, data, strb, resp);
        $display("Write addr: %0h", addr);
        $display("Write data: %0h strb: %0h", data, strb);
        $display("Write resp: %0h", resp);
        if (resp == apb_pkg::RESP_OKAY) begin
          // update golden model
          for (int unsigned j = 0; j < RegDataWidth; j++) begin
            if (strb[j/8]) begin
              reg_compare[(addr-BaseAddr)>>2][j] = data[j];
            end
          end
        end
      end else begin
        apb_master.read(addr, data, resp);
        $display("Read from addr: %0h", addr);
        $display("Read data: %0h", data);
        $display("Read resp: %0h", resp);
      end
      $display("Last Addr: %0h", last_addr);
      repeat ($urandom_range(0,5)) @(posedge clk);
    end

    done <= 1'b1;
  end

  initial begin : proc_end_sim
    @(posedge done);
    repeat(10) @(posedge clk);
    $stop();
  end

  // one cycle delayed addr
  always_ff @(posedge clk or negedge rst_n) begin : proc_last_addr_reg
    if(~rst_n) begin
      last_addr <= '0;
    end else begin
      last_addr <= apb_slave.paddr;
    end
  end


  // pragma translate_off
  `ifndef VERILATOR
  // Assertions to determine correct APB protocol sequencing
  default disable iff (!rst_n);
  // when psel is not asserted, the bus is in the idle state
  sequence APB_IDLE;
    !apb_slave.psel;
  endsequence

  // when psel is set and penable is not, it is the setup state
  sequence APB_SETUP;
    apb_slave.psel && !apb_slave.penable;
  endsequence

  // when psel and penable are set it is the access state
  sequence APB_ACCESS;
    apb_slave.psel && apb_slave.penable;
  endsequence

  sequence APB_RESP_OKAY;
    apb_slave.pready && (apb_slave.pslverr == apb_pkg::RESP_OKAY);
  endsequence

  sequence APB_RESP_SLVERR;
    apb_slave.pready && (apb_slave.pslverr == apb_pkg::RESP_SLVERR);
  endsequence

  // APB Transfer is APB state going from setup to access
  sequence APB_TRANSFER;
    APB_SETUP ##1 APB_ACCESS;
  endsequence

  apb_complete:   assert property ( @(posedge clk)
      (APB_SETUP |-> APB_TRANSFER));

  apb_penable:    assert property ( @(posedge clk)
      (apb_slave.penable && apb_slave.psel && apb_slave.pready |=> (!apb_slave.penable)));

  control_stable: assert property ( @(posedge clk)
      (APB_TRANSFER |-> $stable({apb_slave.pwrite, apb_slave.paddr})));

  apb_valid:      assert property ( @(posedge clk)
      (APB_TRANSFER |-> ((!{apb_slave.pwrite, apb_slave.pstrb, apb_slave.paddr}) !== 1'bx)));

  write_stable:   assert property ( @(posedge clk)
      ((apb_slave.penable && apb_slave.pwrite) |-> $stable(apb_slave.pwdata)));

  strb_stable:    assert property ( @(posedge clk)
      ((apb_slave.penable && apb_slave.pwrite) |-> $stable(apb_slave.pstrb)));

  correct_rdata:   assert property ( @(posedge clk)
      (apb_slave.penable && apb_slave.pready &&
          (apb_slave.pslverr == apb_pkg::RESP_OKAY) && !apb_slave.pwrite)
      |-> (apb_slave.prdata == apb_data_t'(reg_compare[(apb_slave.paddr-BaseAddr)>>2]))) else
      $fatal(1, "Unexpected read response!");
  correct_wdata:   assert property ( @(posedge clk)
      ((apb_slave.penable && apb_slave.pready &&
          (apb_slave.pslverr == apb_pkg::RESP_OKAY) && apb_slave.pwrite)
      |=> (reg_data[(last_addr-BaseAddr)>>2] == reg_compare[(last_addr-BaseAddr)>>2]))) else
      $fatal(1, "Unexpected write output!: addr: %0h, output: %0h, expected: %0h",
          (last_addr-BaseAddr)>>2, reg_data[(last_addr-BaseAddr)>>2],
          reg_compare[(last_addr-BaseAddr)>>2] );
  `endif
  // pragma translate_on

  // Dut
  apb_regs_intf #(
    .NO_APB_REGS    ( NoApbRegs    ),
    .ADDR_OFFSET    ( 32'd4        ),
    .APB_ADDR_WIDTH ( ApbAddrWidth ),
    .APB_DATA_WIDTH ( ApbDataWidth ),
    .REG_DATA_WIDTH ( RegDataWidth ),
    .READ_ONLY      ( ReadOnly     )
  ) i_apb_regs_dut (
    .pclk_i      ( clk       ),
    .preset_ni   ( rst_n     ),
    .slv         ( apb_slave ),
    .base_addr_i ( BaseAddr  ),
    .reg_init_i  ( reg_init  ),
    .reg_q_o     ( reg_data  )
  );
endmodule
