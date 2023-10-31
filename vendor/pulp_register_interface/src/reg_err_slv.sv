// Copyright 2022 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Nicole Narr <narrn@student.ethz.ch>
// Christopher Reinwardt <creinwar@student.ethz.ch>

// Simple module that permanently answers with an error

module reg_err_slv #(
  parameter int unsigned    DW        = 0,
  parameter logic [DW-1:0]  ERR_VAL   = '0,
  parameter type            req_t     = logic,
  parameter type            rsp_t     = logic
) (
  input  req_t               req_i,
  output rsp_t               rsp_o
);

  // Always ready to return an error and the error message
  assign rsp_o.rdata = ERR_VAL;
  assign rsp_o.error = 1'b1;
  assign rsp_o.ready = 1'b1;

endmodule // reg_err_slv
