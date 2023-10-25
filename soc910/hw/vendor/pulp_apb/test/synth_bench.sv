// Copyright 2020 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.
//
// Wolfgang Roenninger <wroennin@ethz.ch>

/// A synthesis test bench which instantiates various APB modules.
module synth_bench (
  input logic clk_i,
  input logic rst_ni
);

  localparam int unsigned APB_ADDR_WIDTH[5] = {3, 7, 16, 27, 32};
  localparam int unsigned APB_DATA_WIDTH[5] = {1, 2, 16, 27, 32};
  localparam int unsigned REG_DATA_WIDTH[5] = {1, 4, 13, 27, 32};

  // APB REGS
  for (genvar i = 0; i < 5; i++) begin : gen_ro_addr
    for (genvar j = 0; j < 5; j++) begin : gen_ro_data
      for (genvar k = 0; k < 5; k++) begin : gen_ro_width
        for (genvar l = 0; l < 4; l++) begin : gen_no_ro_regs
          localparam int unsigned NoApbRegs    = 2**l;
          localparam int unsigned RegDataWidth = (APB_DATA_WIDTH[j] >= REG_DATA_WIDTH[k]) ?
              REG_DATA_WIDTH[k] : APB_DATA_WIDTH[j];
          synth_apb_regs #(
            .NoApbRegs   ( NoApbRegs         ),
            .ApbAddrWidth( APB_ADDR_WIDTH[i] ),
            .ApbDataWidth( APB_DATA_WIDTH[j] ),
            .RegDataWidth( RegDataWidth      )
          ) i_synth_apb_regs (.*);
        end
      end
    end
  end

endmodule


module synth_apb_regs #(
  parameter int unsigned NoApbRegs    = 32'd0,
  parameter int unsigned ApbAddrWidth = 32'd0,
  parameter int unsigned ApbDataWidth = 32'd0,
  parameter int unsigned RegDataWidth = 32'd0
) (
  input logic clk_i,
  input logic rst_ni
);
  localparam logic [NoApbRegs-1:0] ReadOnly = {NoApbRegs{1'b0}};
  typedef logic [ApbAddrWidth-1:0] apb_addr_t;
  typedef logic [RegDataWidth-1:0] reg_data_t;

  APB #(
    .ADDR_WIDTH ( ApbAddrWidth ),
    .DATA_WIDTH ( ApbDataWidth )
  ) apb_slave();

  apb_addr_t                 base_addr;
  reg_data_t [NoApbRegs-1:0] register,  reg_q;

  apb_regs_intf #(
    .NO_APB_REGS    ( NoApbRegs    ),
    .APB_ADDR_WIDTH ( ApbAddrWidth ),
    .ADDR_OFFSET    ( 32'd4        ),
    .APB_DATA_WIDTH ( ApbDataWidth ),
    .REG_DATA_WIDTH ( RegDataWidth ),
    .READ_ONLY      ( ReadOnly     )
  ) i_apb_reg_intf (
    .pclk_i      ( clk_i     ),
    .preset_ni   ( rst_ni    ),
    .slv         ( apb_slave ),
    .base_addr_i ( base_addr ),
    .reg_init_i  ( register  ),
    .reg_q_o     ( reg_q     )
  );
endmodule
