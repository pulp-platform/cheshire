// Copyright 2022 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51

module cheshire_bootrom #(
    parameter int unsigned AddrWidth = 32,
    parameter int unsigned DataWidth = 32
)(
    input  logic                 clk_i,
    input  logic                 rst_ni,
    input  logic                 req_i,
    input  logic [AddrWidth-1:0] addr_i,
    output logic [DataWidth-1:0] data_o
);
    localparam unsigned NumWords = (1 << AddrWidth)/(DataWidth/8);
    logic [$clog2(NumWords)-1:0] word;

    assign word = addr_i / (DataWidth / 8);


    reg [DataWidth-1:0] test_memory [0:NumWords-1];

    string     image_f;
    initial begin
        $value$plusargs("backdoor_load_image=%s", image_f);
        if(image_f == "") image_f = "/home/zexifu/c910_pulp/cheshire_with_c910/hw/riscv-tests/isa/rv64ui-p-add.txt2";
        $display("Loading rom from %s", image_f);
        $readmemh(image_f, test_memory);

        for (int i = 0; i < 256; i = i + 1) begin
          $display("test_memory[%d] = %h", i, test_memory[i]);
        end
    end

    always_comb begin
        data_o = test_memory[word];
    end
endmodule
