//-----------------------------------------------------------------------------
// Copyright (C) 2022 ETH Zurich, University of Bologna
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License. You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.
// SPDX-License-Identifier: SHL-0.51
//-----------------------------------------------------------------------------

// Author: Manuel Eggimann <meggimann@iis.ee.ethz.ch>

`include "apb/assign.svh"

module tb_apb_demux #(
  parameter int unsigned  ApbAddrWidth = 32'd15,
  parameter int unsigned  ApbDataWidth = 32'd32,
  parameter int unsigned NoMstPorts    = 5,
  localparam int unsigned ApbStrbWidth = cf_math_pkg::ceil_div(ApbDataWidth, 8),

  // TB Parameters
  parameter time          TCLK = 10ns,
  parameter time          TA = TCLK * 1/4,
  parameter time          TT = TCLK * 3/4,
  parameter int unsigned  REQ_MIN_WAIT_CYCLES = 0,
  parameter int unsigned  REQ_MAX_WAIT_CYCLES = 10,
  parameter int unsigned  RESP_MIN_WAIT_CYCLES = 0,
  parameter int unsigned  RESP_MAX_WAIT_CYCLES = REQ_MAX_WAIT_CYCLES/2,
  parameter int unsigned  N_TXNS = 1000
);
  logic                   clk;
  logic                   rst_n;
  logic                   done;

  logic [$clog2(NoMstPorts)-1:0] select;

  clk_rst_gen #(
    .ClkPeriod    (TCLK),
    .RstClkCycles (5)
  ) i_clk_rst_gen (
    .clk_o  (clk),
    .rst_no (rst_n)
  );

  APB_DV #(
    .ADDR_WIDTH ( ApbAddrWidth ),
    .DATA_WIDTH ( ApbDataWidth )
  ) source_bus_dv(clk);

  APB #(
        .ADDR_WIDTH ( ApbAddrWidth ),
        .DATA_WIDTH ( ApbDataWidth )
        ) source_bus();
  `APB_ASSIGN(source_bus, source_bus_dv)

  APB_DV #(
    .ADDR_WIDTH ( ApbAddrWidth ),
    .DATA_WIDTH ( ApbDataWidth )
  ) sink_bus_dv[NoMstPorts-1:0](clk);
  APB #(
    .ADDR_WIDTH ( ApbAddrWidth ),
    .DATA_WIDTH ( ApbDataWidth )
  ) sink_bus[NoMstPorts-1:0]();

  typedef logic [ApbAddrWidth-1:0] apb_addr_t;
  typedef logic [ApbDataWidth-1:0] apb_data_t;
  typedef logic [ApbStrbWidth-1:0] apb_strb_t;
  typedef apb_test::apb_request #(.ADDR_WIDTH(ApbAddrWidth), .DATA_WIDTH(ApbDataWidth)) apb_request_t;
  typedef apb_test::apb_response #(.DATA_WIDTH(ApbDataWidth)) apb_response_t;

  typedef struct packed {
    int unsigned idx;
    apb_addr_t   start_addr;
    apb_addr_t   end_addr;
  } rule_t;

  localparam int unsigned ADDR_REGION_SIZE = (2**ApbAddrWidth)/NoMstPorts;
  rule_t[NoMstPorts-1:0] addr_map;

  addr_decode #(
    .NoIndices ( NoMstPorts ),
    .NoRules   ( NoMstPorts ),
    .addr_t    ( apb_addr_t ),
    .rule_t    ( rule_t     )
  ) i_addr_decode(
    .addr_i           ( source_bus_dv.paddr ),
    .addr_map_i       ( addr_map            ),
    .idx_o            ( select              ),
    .dec_valid_o      (                     ),
    .dec_error_o      (                     ),
    .en_default_idx_i ( 1'b1                ),
    .default_idx_i    ( '0                  )
  );

  apb_test::apb_rand_master #(
    .ADDR_WIDTH ( ApbAddrWidth ),
    .DATA_WIDTH ( ApbDataWidth ),
    .TA         ( TA  ),
    .TT         ( TT  )
  ) apb_master = new(source_bus_dv);

  logic mst_done = 1'b0;
  initial begin
    wait(rst_n);
    apb_master.run(N_TXNS);
    mst_done = 1'b1;
  end

  int unsigned slv_errors[NoMstPorts-1:0] = '{default: 0};
  int unsigned errors                 = 0;

  apb_test::apb_rand_slave #(
    .ADDR_WIDTH ( ApbAddrWidth ),
    .DATA_WIDTH ( ApbDataWidth ),
    .TA         ( TA           ),
    .TT         ( TT           )
  ) apb_slave[NoMstPorts-1:0];

  for (genvar idx = 0; idx < NoMstPorts; idx++) begin :gen_slaves
    `APB_ASSIGN(sink_bus_dv[idx], sink_bus[idx])

    assign addr_map[idx] = '{idx: idx, start_addr: idx*ADDR_REGION_SIZE, end_addr: (idx+1)*ADDR_REGION_SIZE};

    initial begin
      apb_slave[idx] = new(sink_bus_dv[idx]);
      wait (rst_n);
      apb_slave[idx].run();
    end
  end

  // Monitor master
  initial begin
    automatic apb_request_t expected_request   = new;
    automatic apb_request_t received_request = new;
    automatic apb_response_t received_response = new;
    automatic apb_response_t expected_response = new;
    automatic int unsigned expected_select;
    automatic bit pop_success;
    forever begin
      apb_master.request_queue.get(expected_request);
      @(posedge source_bus_dv.penable);
      $info("Checking new transaction...");
      expected_select = expected_request.paddr<NoMstPorts*ADDR_REGION_SIZE? expected_request.paddr / ADDR_REGION_SIZE: '0;
      // Wait for  1 cycle for the request to arrive
      #TCLK;
      // Comsourpare with request received at slaves
      pop_success     = apb_slave[expected_select].request_queue.try_get(received_request);
      assert (pop_success) else begin
        $error("Slave %0d did not receive the request.", expected_select);
        errors++;
      end
      assert (received_request.paddr == expected_request.paddr) else begin
        $error("Slave %0d: paddr missmatch on received request. Was %h instead of %h", expected_select, received_request.paddr, expected_request.paddr);
        errors++;
      end
      assert (received_request.pwrite == expected_request.pwrite) else begin
        $error("Slave %0d: pwrite missmatch on received request. Was %0b instead of %0b", expected_select, received_request.pwrite, expected_request.pwrite);
        errors++;
      end
      if (expected_request.pwrite) begin
        assert (received_request.pwdata == expected_request.pwdata) else begin
          $error("Slave %0d: pwdata missmatch on received request. Was %h instead of %h.", expected_select, received_request.pwdata, expected_request.pwdata);
          errors++;
        end
        assert (received_request.pstrb == expected_request.pstrb) else begin
          $error("Slave %0d: pstrb missmatch on received request. Was %h instead of %h", expected_select, received_request.pstrb, expected_request.pstrb);
          errors++;
        end
      end else begin
        apb_master.response_queue.get(received_response);
        // Compare received response with expected value
        // Wait one cycle for the apb_slave to put its response into the fifo
        pop_success = apb_slave[expected_select].response_queue.try_get(expected_response);
        assert(pop_success) else begin
          $error("Slave %0d did not send the response we just received on the master.", expected_select);
          errors++;
        end
        assert(received_response.prdata == expected_response.prdata) else begin
          $error("Received response's prdata: %h does not match the expected prdata: %h", received_response.prdata, expected_response.prdata);
          errors++;
        end
        assert(received_response.pslverr == expected_response.pslverr) else begin
          $error("Received response's pslverr: %b does not match the expected pslverr: %b", received_response.pslverr, expected_response.pslverr);
          errors++;
        end
      end
    end
  end

  // Terminate simulation once all transaction have left the master

  initial begin
    wait(mst_done);

    // Wait a couple of additional cycle to account for response delay
    #(RESP_MAX_WAIT_CYCLES*TCLK);

    // Make sure there are no more pending requests
    assert(apb_master.request_queue.num() == 0) else begin
      $error("Lost %0d requests.", apb_master.request_queue.num());
      errors += apb_master.request_queue.num();
    end

    $info("Total number of errors: %0d", errors);
    $stop();
  end

  apb_demux_intf #(
    .APB_ADDR_WIDTH(ApbAddrWidth),
    .APB_DATA_WIDTH(ApbDataWidth),
    .NoMstPorts(NoMstPorts)
  ) i_dut(
    .slv      ( source_bus ),
    .mst      ( sink_bus   ),
    .select_i ( select     )
  );

endmodule
