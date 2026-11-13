// Copyright 2026 CheshireAra contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
`timescale 1ns/1ps
module tb_i2c_resolved_inputs;
  tri sda, scl, sck;
  tri [1:0] csb;
  tri [3:0] sd;
  wire sda_i, scl_i;
  wire [3:0] sd_i;
  logic sda_en = 0, scl_en = 0;
  logic peer_sda_low = 0, peer_scl_low = 0;
  logic [3:0] sd_en = 0;
  logic [3:0] sd_o = 0;
  int checks = 0, errors = 0;
  assign sda = peer_sda_low ? 1'b0 : 1'bz;
  assign scl = peer_scl_low ? 1'b0 : 1'bz;
  vip_cheshire_soc_tristate dut (
    .i2c_sda_i(sda_i), .i2c_sda_o(1'b0), .i2c_sda_en(sda_en),
    .i2c_scl_i(scl_i), .i2c_scl_o(1'b0), .i2c_scl_en(scl_en),
    .i2c_sda(sda), .i2c_scl(scl),
    .spih_sck_o(1'b0), .spih_sck_en(1'b0), .spih_sck(sck),
    .spih_csb_o(2'b00), .spih_csb_en(2'b00), .spih_csb(csb),
    .spih_sd_o(sd_o), .spih_sd_en(sd_en), .spih_sd_i(sd_i), .spih_sd(sd)
  );
  task automatic check_bit(input string label, input logic got, want);
    checks++;
    if (got !== want) begin
      errors++;
      $display("PIN_MISMATCH %s got=%b want=%b",label,got,want);
    end
  endtask
  initial begin
    for (int state_id=0; state_id<16; state_id++) begin
      {sda_en,scl_en,peer_sda_low,peer_scl_low}=4'(state_id);
      #10;
      check_bit("SDA wire",sda,!(sda_en || peer_sda_low));
      check_bit("SDA input",sda_i,!(sda_en || peer_sda_low));
      check_bit("SCL wire",scl,!(scl_en || peer_scl_low));
      check_bit("SCL input",scl_i,!(scl_en || peer_scl_low));
    end
    sda_en=0; scl_en=0; peer_sda_low=0; peer_scl_low=0;
    #10;
    check_bit("SDA release",sda_i,1'b1);
    check_bit("SCL release",scl_i,1'b1);
    for (int pin=0;pin<4;pin++) begin
      sd_o=0; sd_en=4'(1<<pin); #10;
      check_bit("SPI driven output",sd[pin],1'b0);
      check_bit("SPI input gate",sd_i[pin],1'bz);
      sd_en=0; #10;
      check_bit("SPI released input",sd_i[pin],1'b1);
    end
    $display("I2C_PIN_DONE checks=%0d errors=%0d",checks,errors);
    if (errors) $fatal(1,"I2C_PIN_FAILURE");
    $finish;
  end
  initial begin #1000; $fatal(1,"I2C_PIN_TIMEOUT"); end
endmodule
