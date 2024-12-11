// Copyright 2024 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51

// Fabian Hauser <fhauser@student.ethz.ch>

/// Crc modules for USB Crc5 (token) and Crc16 (data)


module Crc_dataRx (
  input  wire          io_flush,
  input  wire          io_input_valid,
  input  wire [7:0]    io_input_payload,
  output wire [15:0]   io_result,
  output wire [15:0]   io_resultNext,
  input  wire          ctrl_clk,
  input  wire          ctrl_reset
);

  wire       [15:0]   _zz_acc_1;
  wire       [15:0]   _zz_acc_2;
  wire       [15:0]   _zz_acc_3;
  wire       [15:0]   _zz_acc_4;
  wire       [15:0]   _zz_acc_5;
  wire       [15:0]   _zz_acc_6;
  wire       [15:0]   _zz_acc_7;
  wire       [15:0]   _zz_acc_8;
  reg        [15:0]   acc_8;
  reg        [15:0]   acc_7;
  reg        [15:0]   acc_6;
  reg        [15:0]   acc_5;
  reg        [15:0]   acc_4;
  reg        [15:0]   acc_3;
  reg        [15:0]   acc_2;
  reg        [15:0]   acc_1;
  reg        [15:0]   state;
  wire       [15:0]   acc;
  wire       [15:0]   stateXor;
  wire       [15:0]   accXor;

  assign _zz_acc_1 = (acc <<< 1);
  assign _zz_acc_2 = (acc_1 <<< 1);
  assign _zz_acc_3 = (acc_2 <<< 1);
  assign _zz_acc_4 = (acc_3 <<< 1);
  assign _zz_acc_5 = (acc_4 <<< 1);
  assign _zz_acc_6 = (acc_5 <<< 1);
  assign _zz_acc_7 = (acc_6 <<< 1);
  assign _zz_acc_8 = (acc_7 <<< 1);
  always @(*) begin
    acc_8 = acc_7;
    acc_8 = (_zz_acc_8 ^ ((io_input_payload[7] ^ acc_7[15]) ? 16'h8005 : 16'h0000));
  end

  always @(*) begin
    acc_7 = acc_6;
    acc_7 = (_zz_acc_7 ^ ((io_input_payload[6] ^ acc_6[15]) ? 16'h8005 : 16'h0000));
  end

  always @(*) begin
    acc_6 = acc_5;
    acc_6 = (_zz_acc_6 ^ ((io_input_payload[5] ^ acc_5[15]) ? 16'h8005 : 16'h0000));
  end

  always @(*) begin
    acc_5 = acc_4;
    acc_5 = (_zz_acc_5 ^ ((io_input_payload[4] ^ acc_4[15]) ? 16'h8005 : 16'h0000));
  end

  always @(*) begin
    acc_4 = acc_3;
    acc_4 = (_zz_acc_4 ^ ((io_input_payload[3] ^ acc_3[15]) ? 16'h8005 : 16'h0000));
  end

  always @(*) begin
    acc_3 = acc_2;
    acc_3 = (_zz_acc_3 ^ ((io_input_payload[2] ^ acc_2[15]) ? 16'h8005 : 16'h0000));
  end

  always @(*) begin
    acc_2 = acc_1;
    acc_2 = (_zz_acc_2 ^ ((io_input_payload[1] ^ acc_1[15]) ? 16'h8005 : 16'h0000));
  end

  always @(*) begin
    acc_1 = acc;
    acc_1 = (_zz_acc_1 ^ ((io_input_payload[0] ^ acc[15]) ? 16'h8005 : 16'h0000));
  end

  assign acc = state;
  assign stateXor = (state ^ 16'h0000);
  assign accXor = (acc_8 ^ 16'h0000);
  assign io_result = stateXor;
  assign io_resultNext = accXor;
  always @(posedge ctrl_clk or posedge ctrl_reset) begin
    if(ctrl_reset) begin
      state <= 16'hffff;
    end else begin
      if(io_input_valid) begin
        state <= acc_8;
      end
      if(io_flush) begin
        state <= 16'hffff;
      end
    end
  end


endmodule

module Crc_dataTx (
  input  wire          io_flush,
  input  wire          io_input_valid,
  input  wire [7:0]    io_input_payload,
  output wire [15:0]   io_result,
  output wire [15:0]   io_resultNext,
  input  wire          ctrl_clk,
  input  wire          ctrl_reset
);

  wire       [15:0]   _zz_acc_1;
  wire       [15:0]   _zz_acc_2;
  wire       [15:0]   _zz_acc_3;
  wire       [15:0]   _zz_acc_4;
  wire       [15:0]   _zz_acc_5;
  wire       [15:0]   _zz_acc_6;
  wire       [15:0]   _zz_acc_7;
  wire       [15:0]   _zz_acc_8;
  wire                _zz_io_result;
  wire       [0:0]    _zz_io_result_1;
  wire       [6:0]    _zz_io_result_2;
  wire                _zz_io_resultNext;
  wire       [0:0]    _zz_io_resultNext_1;
  wire       [6:0]    _zz_io_resultNext_2;
  reg        [15:0]   acc_8;
  reg        [15:0]   acc_7;
  reg        [15:0]   acc_6;
  reg        [15:0]   acc_5;
  reg        [15:0]   acc_4;
  reg        [15:0]   acc_3;
  reg        [15:0]   acc_2;
  reg        [15:0]   acc_1;
  reg        [15:0]   state;
  wire       [15:0]   acc;
  wire       [15:0]   stateXor;
  wire       [15:0]   accXor;

  assign _zz_acc_1 = (acc <<< 1);
  assign _zz_acc_2 = (acc_1 <<< 1);
  assign _zz_acc_3 = (acc_2 <<< 1);
  assign _zz_acc_4 = (acc_3 <<< 1);
  assign _zz_acc_5 = (acc_4 <<< 1);
  assign _zz_acc_6 = (acc_5 <<< 1);
  assign _zz_acc_7 = (acc_6 <<< 1);
  assign _zz_acc_8 = (acc_7 <<< 1);
  assign _zz_io_result = stateXor[7];
  assign _zz_io_result_1 = stateXor[8];
  assign _zz_io_result_2 = {stateXor[9],{stateXor[10],{stateXor[11],{stateXor[12],{stateXor[13],{stateXor[14],stateXor[15]}}}}}};
  assign _zz_io_resultNext = accXor[7];
  assign _zz_io_resultNext_1 = accXor[8];
  assign _zz_io_resultNext_2 = {accXor[9],{accXor[10],{accXor[11],{accXor[12],{accXor[13],{accXor[14],accXor[15]}}}}}};
  always @(*) begin
    acc_8 = acc_7;
    acc_8 = (_zz_acc_8 ^ ((io_input_payload[7] ^ acc_7[15]) ? 16'h8005 : 16'h0000));
  end

  always @(*) begin
    acc_7 = acc_6;
    acc_7 = (_zz_acc_7 ^ ((io_input_payload[6] ^ acc_6[15]) ? 16'h8005 : 16'h0000));
  end

  always @(*) begin
    acc_6 = acc_5;
    acc_6 = (_zz_acc_6 ^ ((io_input_payload[5] ^ acc_5[15]) ? 16'h8005 : 16'h0000));
  end

  always @(*) begin
    acc_5 = acc_4;
    acc_5 = (_zz_acc_5 ^ ((io_input_payload[4] ^ acc_4[15]) ? 16'h8005 : 16'h0000));
  end

  always @(*) begin
    acc_4 = acc_3;
    acc_4 = (_zz_acc_4 ^ ((io_input_payload[3] ^ acc_3[15]) ? 16'h8005 : 16'h0000));
  end

  always @(*) begin
    acc_3 = acc_2;
    acc_3 = (_zz_acc_3 ^ ((io_input_payload[2] ^ acc_2[15]) ? 16'h8005 : 16'h0000));
  end

  always @(*) begin
    acc_2 = acc_1;
    acc_2 = (_zz_acc_2 ^ ((io_input_payload[1] ^ acc_1[15]) ? 16'h8005 : 16'h0000));
  end

  always @(*) begin
    acc_1 = acc;
    acc_1 = (_zz_acc_1 ^ ((io_input_payload[0] ^ acc[15]) ? 16'h8005 : 16'h0000));
  end

  assign acc = state;
  assign stateXor = (state ^ 16'hffff);
  assign accXor = (acc_8 ^ 16'hffff);
  assign io_result = {stateXor[0],{stateXor[1],{stateXor[2],{stateXor[3],{stateXor[4],{stateXor[5],{stateXor[6],{_zz_io_result,{_zz_io_result_1,_zz_io_result_2}}}}}}}}};
  assign io_resultNext = {accXor[0],{accXor[1],{accXor[2],{accXor[3],{accXor[4],{accXor[5],{accXor[6],{_zz_io_resultNext,{_zz_io_resultNext_1,_zz_io_resultNext_2}}}}}}}}};
  always @(posedge ctrl_clk or posedge ctrl_reset) begin
    if(ctrl_reset) begin
      state <= 16'hffff;
    end else begin
      if(io_input_valid) begin
        state <= acc_8;
      end
      if(io_flush) begin
        state <= 16'hffff;
      end
    end
  end


endmodule

module Crc_token (
  input  wire          io_flush,
  input  wire          io_input_valid,
  input  wire [10:0]   io_input_payload,
  output wire [4:0]    io_result,
  output wire [4:0]    io_resultNext,
  input  wire          ctrl_clk,
  input  wire          ctrl_reset
);

  wire       [4:0]    _zz_acc_1;
  wire       [4:0]    _zz_acc_2;
  wire       [4:0]    _zz_acc_3;
  wire       [4:0]    _zz_acc_4;
  wire       [4:0]    _zz_acc_5;
  wire       [4:0]    _zz_acc_6;
  wire       [4:0]    _zz_acc_7;
  wire       [4:0]    _zz_acc_8;
  wire       [4:0]    _zz_acc_9;
  wire       [4:0]    _zz_acc_10;
  wire       [4:0]    _zz_acc_11;
  reg        [4:0]    acc_11;
  reg        [4:0]    acc_10;
  reg        [4:0]    acc_9;
  reg        [4:0]    acc_8;
  reg        [4:0]    acc_7;
  reg        [4:0]    acc_6;
  reg        [4:0]    acc_5;
  reg        [4:0]    acc_4;
  reg        [4:0]    acc_3;
  reg        [4:0]    acc_2;
  reg        [4:0]    acc_1;
  reg        [4:0]    state;
  wire       [4:0]    acc;
  wire       [4:0]    stateXor;
  wire       [4:0]    accXor;

  assign _zz_acc_1 = (acc <<< 1);
  assign _zz_acc_2 = (acc_1 <<< 1);
  assign _zz_acc_3 = (acc_2 <<< 1);
  assign _zz_acc_4 = (acc_3 <<< 1);
  assign _zz_acc_5 = (acc_4 <<< 1);
  assign _zz_acc_6 = (acc_5 <<< 1);
  assign _zz_acc_7 = (acc_6 <<< 1);
  assign _zz_acc_8 = (acc_7 <<< 1);
  assign _zz_acc_9 = (acc_8 <<< 1);
  assign _zz_acc_10 = (acc_9 <<< 1);
  assign _zz_acc_11 = (acc_10 <<< 1);
  always @(*) begin
    acc_11 = acc_10;
    acc_11 = (_zz_acc_11 ^ ((io_input_payload[10] ^ acc_10[4]) ? 5'h05 : 5'h00));
  end

  always @(*) begin
    acc_10 = acc_9;
    acc_10 = (_zz_acc_10 ^ ((io_input_payload[9] ^ acc_9[4]) ? 5'h05 : 5'h00));
  end

  always @(*) begin
    acc_9 = acc_8;
    acc_9 = (_zz_acc_9 ^ ((io_input_payload[8] ^ acc_8[4]) ? 5'h05 : 5'h00));
  end

  always @(*) begin
    acc_8 = acc_7;
    acc_8 = (_zz_acc_8 ^ ((io_input_payload[7] ^ acc_7[4]) ? 5'h05 : 5'h00));
  end

  always @(*) begin
    acc_7 = acc_6;
    acc_7 = (_zz_acc_7 ^ ((io_input_payload[6] ^ acc_6[4]) ? 5'h05 : 5'h00));
  end

  always @(*) begin
    acc_6 = acc_5;
    acc_6 = (_zz_acc_6 ^ ((io_input_payload[5] ^ acc_5[4]) ? 5'h05 : 5'h00));
  end

  always @(*) begin
    acc_5 = acc_4;
    acc_5 = (_zz_acc_5 ^ ((io_input_payload[4] ^ acc_4[4]) ? 5'h05 : 5'h00));
  end

  always @(*) begin
    acc_4 = acc_3;
    acc_4 = (_zz_acc_4 ^ ((io_input_payload[3] ^ acc_3[4]) ? 5'h05 : 5'h00));
  end

  always @(*) begin
    acc_3 = acc_2;
    acc_3 = (_zz_acc_3 ^ ((io_input_payload[2] ^ acc_2[4]) ? 5'h05 : 5'h00));
  end

  always @(*) begin
    acc_2 = acc_1;
    acc_2 = (_zz_acc_2 ^ ((io_input_payload[1] ^ acc_1[4]) ? 5'h05 : 5'h00));
  end

  always @(*) begin
    acc_1 = acc;
    acc_1 = (_zz_acc_1 ^ ((io_input_payload[0] ^ acc[4]) ? 5'h05 : 5'h00));
  end

  assign acc = state;
  assign stateXor = (state ^ 5'h1f);
  assign accXor = (acc_11 ^ 5'h1f);
  assign io_result = {stateXor[0],{stateXor[1],{stateXor[2],{stateXor[3],stateXor[4]}}}};
  assign io_resultNext = {accXor[0],{accXor[1],{accXor[2],{accXor[3],accXor[4]}}}};
  always @(posedge ctrl_clk or posedge ctrl_reset) begin
    if(ctrl_reset) begin
      state <= 5'h1f;
    end else begin
      if(io_input_valid) begin
        state <= acc_11;
      end
      if(io_flush) begin
        state <= 5'h1f;
      end
    end
  end


endmodule

always @(posedge ctrl_clk or posedge ctrl_reset) begin
    if(ctrl_reset) begin
        state <= 16'hffff;
        acc_1 <= 16'hffff;
        acc_2 <= 16'hffff;
        acc_3 <= 16'hffff;
        acc_4 <= 16'hffff;
        acc_5 <= 16'hffff; //maybe remove these
        acc_6 <= 16'hffff;
        acc_7 <= 16'hffff;
        acc_8 <= 16'hffff;
    end 
    else begin
        if(io_input_valid) begin
            acc_8 <= (acc_7 <<< 1) ^ ((io_input_payload[7] ^ acc_7[15]) ? 16'h8005 : 16'h0000);
            acc_7 <= (acc_6 <<< 1) ^ ((io_input_payload[6] ^ acc_6[15]) ? 16'h8005 : 16'h0000);
            acc_6 <= (acc_5 <<< 1) ^ ((io_input_payload[5] ^ acc_5[15]) ? 16'h8005 : 16'h0000);
            acc_5 <= (acc_4 <<< 1) ^ ((io_input_payload[4] ^ acc_4[15]) ? 16'h8005 : 16'h0000);
            acc_4 <= (acc_3 <<< 1) ^ ((io_input_payload[3] ^ acc_3[15]) ? 16'h8005 : 16'h0000);
            acc_3 <= (acc_2 <<< 1) ^ ((io_input_payload[2] ^ acc_2[15]) ? 16'h8005 : 16'h0000);
            acc_2 <= (acc_1 <<< 1) ^ ((io_input_payload[1] ^ acc_1[15]) ? 16'h8005 : 16'h0000);
            acc_1 <= (state <<< 1) ^ ((io_input_payload[0] ^ state[15]) ? 16'h8005 : 16'h0000);
            state <= acc_8;
        end
        if(io_flush) begin
            state <= 16'hffff;
        end
    end
end
