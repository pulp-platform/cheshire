// Copyright 2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

// APB Read-Write Registers
// Description: This module exposes a number of registers on an APB interface.
//              It responds to not mapped accesses with a slave error.
//              Some of the registers can be configured to be read only.
// Parameters:
// - `NoApbRegs`:    Number of registers.
// - `ApbAddrWidth`: Address width of `req_i.paddr`, is used to generate internal address map.
// - `AddrOffset`:   The address offset in bytes between the registers. Is asserted to be a least
//                   `32'd4`, the reason is to prevent overlap in the address map.
//                   Each register is mapped to a 4 byte wide address range. When this parameter
//                   is bigger than `32'd4` there will be holes in the address map and the module
//                   answers with `apb_pkg::RESP_SLVERR`. It is recommended that this value is a
//                   power of 2, to prevent data alignment issues on upstream buses.
// - `ApbDataWidth`: The data width of the APB4 bus, this value can be up to `32'd32` (bit).
// - `RegDataWidth`: The data width of the registers, this value has to be less or equal to
//                   `ApbDataWidth`. If it is less the register gets zero extended for reads and
//                   higher bits on writes get ignored.
// - `ReadOnly`:     This flag can specify a read only register at the given register index of the
//                   array. When in the array the corresponding bit is set, the `reg_init_i` signal
//                   at given index can be read out. Writes are ignored if the flag is set.
// - `req_t`:        APB4 request struct. See macro definition in `include/typedef.svh`
// - `resp_t`:       APB4 response struct. See macro definition in `include/typedef.svh`
//
// Ports:
//
// - `pclk_i:        Clock input signal (1-bit).
// - `preset_ni:     Asynchronous active low reset signal (1-bit).
// - `req_i:         APB4 request struct, bundles all APB4 signals from the master (req_t).
// - `resp_o:        APB4 response struct, bundles all APB4 signals to the master (resp_t).
// - `base_addr_i:   Base address of this module, from here the registers `0` are mapped, starting
//                   with index `0`. All subsequent register with higher indices have their bases
//                   mapped with reg_index * `AddrOffset` from this value (ApbAddrWidth-bit).
// - `reg_init_i:    Initialization value for each register, when the register index is configured
//                   as `ReadOnly[reg_index] == 1'b1` this value is passed through directly to
//                   the APB4 bus (Array size `NoApbRegs` * RegDataWidth-bit).
// - `reg_q_o:       The current value of the register. If the register at the array index is
//                   read only, the `reg_init_i` value is passed through to the respective index
//                   (Array size `NoApbRegs` * RegDataWidth-bit).
//
// This file also features the module `apb_regs_intf`. The difference is that instead of the
// request and response structs it uses an `APB.Salve` interface. The parameters have the same
// Function, however are defined in `ALL_CAPS`.


`include "common_cells/registers.svh"

module apb_regs #(
  parameter int unsigned        NoApbRegs    = 32'd0,
  parameter int unsigned        ApbAddrWidth = 32'd0,
  parameter int unsigned        AddrOffset   = 32'd4,
  parameter int unsigned        ApbDataWidth = 32'd0,
  parameter int unsigned        RegDataWidth = 32'd0,
  parameter bit [NoApbRegs-1:0] ReadOnly     = 32'h0,
  parameter type                req_t        = logic,
  parameter type                resp_t       = logic,
  // DEPENDENT PARAMETERS DO NOT OVERWRITE!
  parameter type apb_addr_t                  = logic[ApbAddrWidth-1:0],
  parameter type reg_data_t                  = logic[RegDataWidth-1:0]
) (
  // APB Interface
  input  logic                      pclk_i,
  input  logic                      preset_ni,
  input  req_t                      req_i,
  output resp_t                     resp_o,
  // Register Interface
  input  apb_addr_t                 base_addr_i, // base address of the read/write registers
  input  reg_data_t [NoApbRegs-1:0] reg_init_i,
  output reg_data_t [NoApbRegs-1:0] reg_q_o
);
  localparam int unsigned IdxWidth  = (NoApbRegs > 32'd1) ? $clog2(NoApbRegs) : 32'd1;
  typedef logic [IdxWidth-1:0]     idx_t;
  typedef logic [ApbAddrWidth-1:0] apb_data_t;
  typedef struct packed {
    int unsigned idx;
    apb_addr_t   start_addr;
    apb_addr_t   end_addr;
  } rule_t;

  logic has_reset_d, has_reset_q;
  `FFARN(has_reset_q, has_reset_q, 1'b0, pclk_i, preset_ni)
  assign has_reset_d = 1'b1;

  // signal declarations
  rule_t     [NoApbRegs-1:0] addr_map;
  idx_t                      reg_idx;
  logic                      decode_valid;
  // register signals
  reg_data_t [NoApbRegs-1:0] reg_d, reg_q;
  logic      [NoApbRegs-1:0] reg_update;

  // generate address map for the registers
  for (genvar i = 0; i < NoApbRegs; i++) begin: gen_reg_addr_map
    assign addr_map[i] = rule_t'{
      idx:        unsigned'(i),
      start_addr: base_addr_i + apb_addr_t'( i        * AddrOffset),
      end_addr:   base_addr_i + apb_addr_t'((i+32'd1) * AddrOffset)
    };
  end

  always_comb begin
    // default assignments
    reg_d      = has_reset_q ? reg_q : reg_init_i;
    reg_update = '0;
    resp_o     = '{
      pready:  req_i.psel & req_i.penable,
      prdata:  apb_data_t'(32'h0BAD_B10C),
      pslverr: apb_pkg::RESP_OKAY
    };
    if (req_i.psel) begin
      if (!decode_valid) begin
        // Error response on decode errors
        resp_o.pslverr = apb_pkg::RESP_SLVERR;
      end else begin
        if (req_i.pwrite) begin
          if (!ReadOnly[reg_idx]) begin
            for (int unsigned i = 0; i < RegDataWidth; i++) begin
              if (req_i.pstrb[i/8]) begin
                reg_d[reg_idx][i] = req_i.pwdata[i];
              end
            end
            reg_update[reg_idx] = |req_i.pstrb;
          end else begin
            // this register is read only
            resp_o.pslverr = apb_pkg::RESP_SLVERR;
          end
        end else begin
          if (!ReadOnly[reg_idx]) begin
            resp_o.prdata = apb_data_t'(reg_q[reg_idx]);
          end else begin
            // for read only register the directly connect the init signal
            resp_o.prdata = apb_data_t'(reg_init_i[reg_idx]);
          end
        end
      end
    end
  end

  // output assignment and registers
  for (genvar i = 0; i < NoApbRegs; i++) begin : gen_rw_regs
    assign reg_q_o[i] = ReadOnly[i] ? reg_init_i[i] : reg_q[i];
    `FFLARN(reg_q[i], reg_d[i], reg_update[i], '0, pclk_i, preset_ni)
  end

  addr_decode #(
    .NoIndices ( NoApbRegs  ),
    .NoRules   ( NoApbRegs  ),
    .addr_t    ( apb_addr_t ),
    .rule_t    ( rule_t     )
  ) i_addr_decode (
    .addr_i      ( req_i.paddr  ),
    .addr_map_i  ( addr_map     ),
    .idx_o       ( reg_idx      ),
    .dec_valid_o ( decode_valid ),
    .dec_error_o ( /*not used*/ ),
    .en_default_idx_i ( '0      ),
    .default_idx_i    ( '0      )
  );

  // Validate parameters.
  // pragma translate_off
  `ifndef VERILATOR
    initial begin: p_assertions
      assert (NoApbRegs > 32'd0)
          else $fatal(1, "The number of registers must be at least 1!");
      assert (ApbAddrWidth > 32'd2)
          else $fatal(1, "ApbAddrWidth is not wide enough, has to be at least 3 bit wide!");
      assert (AddrOffset > 32'd3)
          else $fatal(1, "AddrOffset has to be at least 4 and is recommended to be a power of 2!");
      assert ($bits(req_i.paddr) == ApbAddrWidth)
          else $fatal(1, "AddrWidth does not match req_i.paddr!");
      assert (ApbDataWidth == $bits(resp_o.prdata))
          else $fatal(1, "ApbDataWidth has to be: ApbDataWidth == $bits(req_i.prdata)!");
      assert (ApbDataWidth > 32'd0 && ApbDataWidth <= 32'd32)
          else $fatal(1, "ApbDataWidth has to be: 32'd32 >= RegDataWidth > 0!");
      assert ($bits(resp_o.prdata) == $bits(req_i.pwdata))
          else $fatal(1, "req_i.pwdata has to match resp_o.prdata in width!");
      assert (RegDataWidth > 32'd0 && RegDataWidth <= 32'd32)
          else $fatal(1, "RegDataWidth has to be: 32'd32 >= RegDataWidth > 0!");
      assert (RegDataWidth <= $bits(resp_o.prdata))
          else $fatal(1, "RegDataWidth has to be: RegDataWidth <= $bits(req_i.prdata)!");
      assert (NoApbRegs == $bits(ReadOnly))
          else $fatal(1, "Each register need a `ReadOnly` flag!");
    end
  `endif
  // pragma translate_on
endmodule

`include "apb/assign.svh"
`include "apb/typedef.svh"

module apb_regs_intf #(
  parameter int unsigned          NO_APB_REGS    = 32'd0, // number of read only registers
  parameter int unsigned          APB_ADDR_WIDTH = 32'd0, // address width of `paddr`
  parameter int unsigned          ADDR_OFFSET    = 32'd4, // address offset in bytes
  parameter int unsigned          APB_DATA_WIDTH = 32'd0, // data width of the registers
  parameter int unsigned          REG_DATA_WIDTH = 32'd0,
  parameter bit [NO_APB_REGS-1:0] READ_ONLY      = 32'h0,
  // DEPENDENT PARAMETERS DO NOT OVERWRITE!
  parameter type                  apb_addr_t     = logic[APB_ADDR_WIDTH-1:0],
  parameter type                  reg_data_t     = logic[REG_DATA_WIDTH-1:0]
) (
  // APB Interface
  input  logic                        pclk_i,
  input  logic                        preset_ni,
  APB.Slave                           slv,
  // Register Interface
  input  apb_addr_t                   base_addr_i, // base address of the read only registers
  input  reg_data_t [NO_APB_REGS-1:0] reg_init_i,  // initalisation value for the registers
  output reg_data_t [NO_APB_REGS-1:0] reg_q_o
);
  localparam int unsigned APB_STRB_WIDTH = cf_math_pkg::ceil_div(APB_DATA_WIDTH, 8);
  typedef logic [APB_DATA_WIDTH-1:0] apb_data_t;
  typedef logic [APB_STRB_WIDTH-1:0] apb_strb_t;

  `APB_TYPEDEF_REQ_T(apb_req_t, apb_addr_t, apb_data_t, apb_strb_t)
  `APB_TYPEDEF_RESP_T(apb_resp_t, apb_data_t)

  apb_req_t  apb_req;
  apb_resp_t apb_resp;

  `APB_ASSIGN_TO_REQ(apb_req, slv)
  `APB_ASSIGN_FROM_RESP(slv, apb_resp )

  apb_regs #(
    .NoApbRegs    ( NO_APB_REGS    ),
    .ApbAddrWidth ( APB_ADDR_WIDTH ),
    .AddrOffset   ( ADDR_OFFSET    ),
    .ApbDataWidth ( APB_DATA_WIDTH ),
    .RegDataWidth ( REG_DATA_WIDTH ),
    .ReadOnly     ( READ_ONLY      ),
    .req_t        ( apb_req_t      ),
    .resp_t       ( apb_resp_t     )
  ) i_apb_regs (
    .pclk_i,
    .preset_ni,
    .req_i       ( apb_req  ),
    .resp_o      ( apb_resp ),
    .base_addr_i,
    .reg_init_i,
    .reg_q_o
  );

  // Validate parameters.
  // pragma translate_off
  `ifndef VERILATOR
    initial begin: p_assertions
      assert (APB_ADDR_WIDTH == $bits(slv.paddr))
          else $fatal(1, "APB_ADDR_WIDTH does not match slv interface!");
      assert (APB_DATA_WIDTH == $bits(slv.pwdata))
          else $fatal(1, "APB_DATA_WIDTH does not match slv interface!");
    end
  `endif
  // pragma translate_on
endmodule
