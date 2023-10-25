// Copyright 2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

// Author: Manuel Eggimann <meggimann@iis.ee.ethz.ch>

// Description: Testbench for `apb_cdc`.
//   Step 1: Read over a range of addresses, where the registers are inbetween.
//   Step 2: Random reads and writes to the different registers.
// Assertions provide checking for correct functionality.

`include "apb/assign.svh"

module tb_apb_cdc #(
  parameter int unsigned ApbAddrWidth = 32'd32,
  parameter int unsigned ApbDataWidth = 32'd27,
  localparam int unsigned ApbStrbWidth = cf_math_pkg::ceil_div(ApbDataWidth, 8),
  parameter int unsigned CDCLogDepth  = 3,

  // TB Parameters
  parameter time TCLK_UPSTREAM = 10ns,
  parameter time TA_UPSTREAM = TCLK_UPSTREAM * 1/4,
  parameter time TT_UPSTREAM = TCLK_UPSTREAM * 3/4,
  parameter time TCLK_DOWNSTREAM = 3ns,
  parameter time TA_DOWNSTREAM = TCLK_DOWNSTREAM * 1/4,
  parameter time TT_DOWNSTREAM = TCLK_DOWNSTREAM * 3/4,
  parameter int unsigned REQ_MIN_WAIT_CYCLES = 0,
  parameter int unsigned REQ_MAX_WAIT_CYCLES = 10,
  parameter int unsigned RESP_MIN_WAIT_CYCLES = 0,
  parameter int unsigned RESP_MAX_WAIT_CYCLES = REQ_MAX_WAIT_CYCLES/2,
  parameter int unsigned N_TXNS = 1000
);

  logic                      clk;
  logic                      rst_n;
  logic                      done;


    // Clocks and Resets

  logic upstream_clk,
        downstream_clk,
        upstream_rst_n,
        downstream_rst_n;

  clk_rst_gen #(
    .ClkPeriod    (TCLK_UPSTREAM),
    .RstClkCycles (5)
  ) i_clk_rst_gen_upstream (
    .clk_o  (upstream_clk),
    .rst_no (upstream_rst_n)
  );

  clk_rst_gen #(
    .ClkPeriod    (TCLK_DOWNSTREAM),
    .RstClkCycles (5)
  ) i_clk_rst_gen_downstream (
    .clk_o  (downstream_clk),
    .rst_no (downstream_rst_n)
  );


  APB_DV #(
    .ADDR_WIDTH ( ApbAddrWidth ),
    .DATA_WIDTH ( ApbDataWidth )
  ) upstream_dv(upstream_clk);
  APB #(
    .ADDR_WIDTH ( ApbAddrWidth ),
    .DATA_WIDTH ( ApbDataWidth )
  ) upstream();
  `APB_ASSIGN(upstream, upstream_dv)

  APB_DV #(
    .ADDR_WIDTH ( ApbAddrWidth ),
    .DATA_WIDTH ( ApbDataWidth )
  ) downstream_dv(downstream_clk);
  APB #(
    .ADDR_WIDTH ( ApbAddrWidth ),
    .DATA_WIDTH ( ApbDataWidth )
  ) downstream();
  `APB_ASSIGN(downstream_dv, downstream)


  typedef logic [ApbAddrWidth-1:0] apb_addr_t;
  typedef logic [ApbDataWidth-1:0] apb_data_t;
  typedef logic [ApbStrbWidth-1:0] apb_strb_t;
  typedef apb_test::apb_request #(.ADDR_WIDTH(ApbAddrWidth), .DATA_WIDTH(ApbDataWidth)) apb_request_t;
  typedef apb_test::apb_response #(.DATA_WIDTH(ApbDataWidth)) apb_response_t;

  apb_cdc_intf #(
    .APB_ADDR_WIDTH ( ApbAddrWidth ),
    .APB_DATA_WIDTH ( ApbDataWidth ),
    .LOG_DEPTH      ( CDCLogDepth  )
  ) i_dut (
    .src_pclk_i    ( upstream_clk     ),
    .src_preset_ni ( upstream_rst_n   ),
    .src           ( upstream         ),
    .dst_pclk_i    ( downstream_clk   ),
    .dst_preset_ni ( downstream_rst_n ),
    .dst           ( downstream       )
  );

  apb_test::apb_rand_master #(
    .ADDR_WIDTH ( ApbAddrWidth ),
    .DATA_WIDTH ( ApbDataWidth ),
    .TA         ( TA_UPSTREAM  ),
    .TT         ( TT_UPSTREAM  )
  ) apb_master = new(upstream_dv);


  logic mst_done = 1'b0;
  initial begin
    wait(upstream_rst_n);
    apb_master.run(N_TXNS);
    mst_done = 1'b1;
  end

  apb_test::apb_rand_slave #(
    .ADDR_WIDTH ( ApbAddrWidth  ),
    .DATA_WIDTH ( ApbDataWidth  ),
    .TA         ( TA_DOWNSTREAM ),
    .TT         ( TT_DOWNSTREAM )
  ) apb_slave = new(downstream_dv);

  initial begin
    wait (downstream_rst_n);
    apb_slave.run();
  end

  int unsigned upstream_errors = 0;

  // Monitor Upstream Respones
  initial begin
    automatic apb_response_t received_response = new;
    automatic apb_response_t expected_response = new;
    automatic bit pop_success;
    forever begin
      apb_master.response_queue.get(received_response);
      $info("Received new response");
      pop_success = apb_slave.response_queue.try_get(expected_response);
      assert(pop_success) else begin
        $error("Upstream: Received spurious read response. prdata: %h, pslverr: %b", received_response.prdata, received_response.pslverr);
        upstream_errors++;
        continue;
      end
      //Compare upstream received response with downstream sent response
      assert(received_response.prdata == expected_response.prdata) else begin
        $error("Upstream: Received response's prdata: %h does not match the expected prdata: %h", received_response.prdata, expected_response.prdata);
        upstream_errors++;
      end
      assert(received_response.pslverr == expected_response.pslverr) else begin
        $error("Upstream: Received response's pslverr: %b does not match the expected pslverr: %b", received_response.pslverr, expected_response.pslverr);
        upstream_errors++;
      end
    end
  end // initial begin

  int unsigned downstream_errors = 0;

  // Monitor Downstream Requests
  initial begin
    automatic apb_request_t received_request = new;
    automatic apb_request_t expected_request = new;
    automatic bit pop_success;
    forever begin
      apb_slave.request_queue.get(received_request);
      $info("Received new request");
      pop_success = apb_master.request_queue.try_get(expected_request); // Since the requests are recorded in
                                // the master driver strictly before they arrive in the slave, an
                                // empy request_queue in the master means, that we received an
                                // spurious request.
      assert(pop_success) else begin
        $error("Downstream: Received spurious request. Addr: %h, Data: %h, write_en: %b", received_request.paddr, received_request.pdata, received_request.pwrite);
        downstream_errors++;
        continue;
      end
      //Compare downstream received request with upstream sent request
      assert(received_request.paddr == expected_request.paddr) else begin
        $error("Downstream: Received request's paddr: %h does not match the paddr: %h", received_request.paddr, expected_request.paddr);
        downstream_errors++;
      end
      assert(received_request.pdata == expected_request.pdata) else begin
        $error("Downstream: Received request's pdata: %h does not match the expected pdata: %h", received_request.pdata, expected_request.pdata);
        downstream_errors++;
      end
      assert(received_request.pwrite == expected_request.pwrite) else begin
        $error("Downstream: Received request's pwrite: %b does not match the expected pwrite: %b", received_request.pwrite, expected_request.pwrite);
        downstream_errors++;
      end
    end
  end // initial begin

  // Terminate simulation after all transactions have left master and the last response should have
  // arrived back

  initial begin
    wait(mst_done);
    // 10 Additional cycles for the request/response to pass through the
    // CDC FIFO should be enough.
    #((REQ_MAX_WAIT_CYCLES+10)*TCLK_UPSTREAM+(RESP_MAX_WAIT_CYCLES+10)*TCLK_DOWNSTREAM);

    // Now check if all queues are empty. If all requests/responses passed through the CDC the
    // master and slave queue should all be empty now.
    assert(apb_master.request_queue.num() == 0) else begin
      $error("Lost %0d requests.", apb_master.request_queue.num());
      downstream_errors += apb_master.request_queue.num();
    end
    assert(apb_slave.response_queue.num() == 0) else begin
      $error("Lost %0d responses.", apb_slave.response_queue.num());
      upstream_errors += apb_slave.response_queue.num();
    end
    $info("TB CDC finished after simulation of %0d random transactions.", N_TXNS);
    $info("Got %0d upstream errors and %0d downstream errors.", upstream_errors, downstream_errors);
    $finish();
  end

endmodule
