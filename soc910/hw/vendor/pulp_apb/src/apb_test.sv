// Copyright (c) 2018 ETH Zurich, University of Bologna
//
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

// Test infrastructure for APB interfaces
package apb_test;

  class apb_request #(
    parameter ADDR_WIDTH = 32'd32,
    parameter DATA_WIDTH = 32'd32
  );
    localparam STRB_WIDTH = cf_math_pkg::ceil_div(DATA_WIDTH, 8);

    rand logic [ADDR_WIDTH-1:0]   paddr  = '0;
    rand logic [DATA_WIDTH-1:0]   pwdata = '0;
    rand logic [STRB_WIDTH-1:0]   pstrb  = '0;
    rand logic                    pwrite = 1'b1;
  endclass;

  class apb_response #(
    parameter DATA_WIDTH = 32'd32
  );
    rand logic [DATA_WIDTH-1:0] prdata  = '0;
    rand logic                  pslverr = 1'b0;
  endclass;

  // Simple APB driver with thread-safe read and write functions
  class apb_driver #(
    parameter int unsigned ADDR_WIDTH = 32'd32, // APB4 address width
    parameter int unsigned DATA_WIDTH = 32'd32, // APB4 data width
    parameter time         TA         = 0ns,    // application time
    parameter time         TT         = 0ns     // test time
  );
    localparam int unsigned STRB_WIDTH = cf_math_pkg::ceil_div(DATA_WIDTH, 8);
    typedef logic [ADDR_WIDTH-1:0] addr_t;
    typedef logic [DATA_WIDTH-1:0] data_t;
    typedef logic [STRB_WIDTH-1:0] strb_t;
    typedef apb_request #(.ADDR_WIDTH(ADDR_WIDTH), .DATA_WIDTH(DATA_WIDTH)) apb_request_t;
    typedef apb_response #(.DATA_WIDTH(DATA_WIDTH)) apb_response_t;
    virtual APB_DV #(
      .ADDR_WIDTH(ADDR_WIDTH),
      .DATA_WIDTH(DATA_WIDTH)
    ) apb;
    semaphore lock;

    function new(virtual APB_DV #(.ADDR_WIDTH(ADDR_WIDTH), .DATA_WIDTH(DATA_WIDTH)) apb);
      this.apb = apb;
      this.lock = new(1);
    endfunction

    function void reset_master();
      apb.paddr   <= '0;
      apb.pprot   <= '0;
      apb.psel    <= 1'b0;
      apb.penable <= 1'b0;
      apb.pwrite  <= 1'b0;
      apb.pwdata  <= '0;
      apb.pstrb   <= '0;
    endfunction

    function void reset_slave();
      apb.pready  <= 1'b0;
      apb.prdata  <= '0;
      apb.pslverr <= 1'b0;
    endfunction

    task cycle_start;
      #TT;
    endtask

    task cycle_end;
      @(posedge apb.clk_i);
    endtask

    // this task reads from an APB4 slave, acts as master
    task read(
      input  addr_t addr,
      output data_t data,
      output logic  err
    );
      while (!lock.try_get()) begin
        cycle_end();
      end
      apb.paddr   <= #TA addr;
      apb.pwrite  <= #TA 1'b0;
      apb.psel    <= #TA 1'b1;
      cycle_end();
      apb.penable <= #TA 1'b1;
      cycle_start();
      while (!apb.pready) begin
        cycle_end();
        cycle_start();
      end
      data  = apb.prdata;
      err   = apb.pslverr;
      cycle_end();
      apb.paddr   <= #TA '0;
      apb.psel    <= #TA 1'b0;
      apb.penable <= #TA 1'b0;
      lock.put();
    endtask

    // this task writes to an APB4 slave, acts as master
    task write(
      input  addr_t addr,
      input  data_t data,
      input  strb_t strb,
      output logic  err
    );
      while (!lock.try_get()) begin
        cycle_end();
      end
      apb.paddr   <= #TA addr;
      apb.pwdata  <= #TA data;
      apb.pstrb   <= #TA strb;
      apb.pwrite  <= #TA 1'b1;
      apb.psel    <= #TA 1'b1;
      cycle_end();
      apb.penable <= #TA 1'b1;
      cycle_start();
      while (!apb.pready) begin
        cycle_end();
        cycle_start();
      end
      err = apb.pslverr;
      cycle_end();
      apb.paddr   <= #TA '0;
      apb.pwdata  <= #TA '0;
      apb.pstrb   <= #TA '0;
      apb.pwrite  <= #TA 1'b0;
      apb.psel    <= #TA 1'b0;
      apb.penable <= #TA 1'b0;
      lock.put();
    endtask

    // Wait for incoming apb request
    task recv_request (
      output apb_request_t request
    );
      cycle_start();
      while (!apb.psel) begin cycle_end(); cycle_start(); end
      while (!apb.penable) begin cycle_end(); cycle_start(); end
      request        = new;
      request.paddr  = apb.paddr;
      request.pwdata = apb.pwdata;
      request.pwrite = apb.pwrite;
      request.pstrb  = apb.pstrb;
      cycle_end();
    endtask

    // Acknowledge incoming APB write request (assert pready).
    task send_write_ack();
      apb.pready <= #TA 1;
      cycle_end();
      apb.pready <= #TA 0;
    endtask

    // Send response for incoming APB read request acknowledging the request (assert pready).
    task send_read_response (
      input apb_response_t response
    );
      apb.pready <= #TA 1;
      apb.prdata <= #TA response.prdata;
      apb.pslverr <= #TA response.pslverr;
      cycle_end();
      apb.pready    <= #TA 0;
      apb.prdata    <= #TA '0;
      apb.pslverr   <= #TA 0;
    endtask

  endclass

  class apb_rand_slave #(
    // APB interface parmeters
    parameter int unsigned ADDR_WIDTH = 32'd32,
    parameter int unsigned DATA_WIDTH = 32'd32,
    // Stimuli application and test time
    parameter time  TA = 0ps,
    parameter time  TT = 0ps,
    // Upper and lower bounds on wait states on Response (pready)
    parameter int   RESP_MIN_WAIT_CYCLES = 0,
    parameter int   RESP_MAX_WAIT_CYCLES = 20
  );

    typedef apb_test::apb_driver #(
      .ADDR_WIDTH(ADDR_WIDTH), .DATA_WIDTH(DATA_WIDTH), .TA(TA), .TT(TT)
    ) apb_driver_t;

    typedef apb_driver_t::addr_t addr_t;
    typedef apb_driver_t::data_t data_t;
    typedef apb_driver_t::strb_t strb_t;

    typedef apb_driver_t::apb_request_t apb_request_t;
    typedef apb_driver_t::apb_response_t apb_response_t;

    apb_driver_t 	    drv;
    mailbox #(apb_request_t) request_queue;
    mailbox #(apb_response_t) response_queue;

    function new(
      virtual APB_DV #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
      ) apb
    );
      this.drv            = new(apb);
      this.request_queue  = new;
      this.response_queue = new;
      this.reset();
    endfunction

    function reset();
      drv.reset_slave();
    endfunction

    // TODO: The `rand_wait` task exists in `rand_verif_pkg`, but that task cannot be called with
    // `this.drv.apb.clk_i` as `clk` argument.  What is the syntax getting an assignable reference?
    task automatic rand_wait(input int unsigned min, max);
      int unsigned rand_success, cycles;
      rand_success = std::randomize(cycles) with {
        cycles >= min;
        cycles <= max;
      };
      assert (rand_success) else $error("Failed to randomize wait cycles!");
      repeat (cycles) @(posedge this.drv.apb.clk_i);
    endtask : rand_wait

    task handle_requests();
      forever begin
        automatic apb_request_t request;
        automatic apb_response_t read_response = new;
        automatic logic rand_success;
        drv.recv_request(request);
        request_queue.put(request);
        if (request.pwrite) begin
          rand_wait(RESP_MIN_WAIT_CYCLES, RESP_MAX_WAIT_CYCLES);
          drv.send_write_ack();
        end else begin
          rand_success = read_response.randomize(); assert(rand_success);
          response_queue.put(read_response);
          rand_wait(RESP_MIN_WAIT_CYCLES, RESP_MAX_WAIT_CYCLES);
          drv.send_read_response(read_response);
        end
      end
    endtask : handle_requests // recv_requests

    task run();
      handle_requests();
    endtask

  endclass

  class apb_rand_master #(
    // APB interface parmeters
    parameter int unsigned ADDR_WIDTH = 32'd32,
    parameter int unsigned DATA_WIDTH = 32'd32,
    // Stimuli application and test time
    parameter time         TA = 0ps,
    parameter time         TT = 0ps,
    // Upper and lower bounds on wait cycles on request channel
    parameter int          REQ_MIN_WAIT_CYCLES = 0,
    parameter int          REQ_MAX_WAIT_CYCLES = 20
  );

    typedef apb_test::apb_driver #(
      .ADDR_WIDTH(ADDR_WIDTH), .DATA_WIDTH(DATA_WIDTH), .TA(TA), .TT(TT)
    ) apb_driver_t;

    typedef apb_driver_t::addr_t addr_t;
    typedef apb_driver_t::data_t data_t;
    typedef apb_driver_t::strb_t strb_t;

    typedef apb_driver_t::apb_request_t apb_request_t;
    typedef apb_driver_t::apb_response_t apb_response_t;

    apb_driver_t 	    drv;
    mailbox #(apb_request_t) request_queue;
    mailbox #(apb_response_t) response_queue;


    function new(
      virtual APB_DV #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
      ) apb
    );
      this.drv            = new(apb);
      this.request_queue  = new;
      this.response_queue = new;
      this.reset();
    endfunction

    function reset();
      drv.reset_master();
    endfunction

    // TODO: The `rand_wait` task exists in `rand_verif_pkg`, but that task cannot be called with
    // `this.drv.apb.clk_i` as `clk` argument.  What is the syntax getting an assignable reference?
    task automatic rand_wait(input int unsigned min, max);
      int unsigned rand_success, cycles;
      rand_success = std::randomize(cycles) with {
        cycles >= min;
        cycles <= max;
      };
      assert (rand_success) else $error("Failed to randomize wait cycles!");
      repeat (cycles) @(posedge this.drv.apb.clk_i);
    endtask

    task automatic send_requests(input int unsigned n_requests);
      automatic apb_request_t request = new;
      automatic apb_response_t response = new;
      automatic logic write_err;
      automatic logic rand_success;
      repeat (n_requests) begin
        rand_wait(REQ_MIN_WAIT_CYCLES, REQ_MAX_WAIT_CYCLES);
        rand_success       = request.randomize(); assert(rand_success);
        request_queue.put(request);
        if (request.pwrite) begin
          $info("Sending write request with addr: %h, pstrb: %b and pwdata: %h", request.paddr, request.pstrb, request.pwdata);
          drv.write(request.paddr, request.pwdata, request.pstrb, write_err);
        end else begin
          $info("Sending read request with addr: %h...", request.paddr);
          drv.read(request.paddr, response.prdata, response.pslverr);
          response_queue.put(response);
        end
      end
    endtask : send_requests

    task automatic run(input int unsigned n_request);
      $info("Run apb_rand_master for %0d transactions", n_request);
      send_requests(n_request);
    endtask

  endclass
endpackage
