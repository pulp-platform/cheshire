//write 512-Byte data block

`include "common_cells/registers.svh"

module dat_write #(
  parameter int MaxBlockBitSize
) (
  input  logic       clk_i,
  input  logic       sd_clk_en_p_i,
  input  logic       sd_clk_en_n_i,
  input  logic       div_1_i,
  input  logic       rst_ni,
  input  logic       dat0_i,
  output logic [3:0] dat_o,
  output logic       dat_en_o,

  input  logic                       start_i,
  input  logic [MaxBlockBitSize-1:0] block_size_i, // In bytes
  input  logic                       bus_width_is_4_i,

  input  logic [31:0] data_i,
  output logic        next_word_o, //active for one cycle when next data word should be made available. Got time for 7 sd clock cycles after to provide data

  output logic done_o,
  output logic crc_err_o,
  output logic end_bit_err_o
);
  // Need space for block_size_i * 8 + 16
  localparam int CounterWidth = MaxBlockBitSize + 4;

  typedef enum logic [3:0] {
    READY,
    START_BIT,
    DAT,
    CRC,
    END_BIT,

    BUS_SWITCH, //wait 2 clock cycles before listening for Response

    STATUS_START_BIT,
    STATUS,
    STATUS_END_BIT,

    BUSY,
    DONE
  } dat_tx_state_e;

  logic [3:0] crc;
  logic shift_out_crc;

  dat_tx_state_e dat_tx_state_d, dat_tx_state_q;
  `FFL (dat_tx_state_q, dat_tx_state_d, sd_clk_en_p_i, READY);

  logic [CounterWidth-1:0] counter_q, counter_d;
  `FFL (counter_q, counter_d, sd_clk_en_p_i, 0);

  logic [CounterWidth-1:0] required_clock_count;
  assign required_clock_count = bus_width_is_4_i ? 2*block_size_i : 8*block_size_i;

  always_comb begin : dat_write_state_transition
    dat_tx_state_d  =   dat_tx_state_q;

    unique case (dat_tx_state_q)
      READY:            if (start_i) dat_tx_state_d = START_BIT;
      START_BIT:        dat_tx_state_d = DAT;
      DAT:              if (counter_q + 1 == required_clock_count) dat_tx_state_d = CRC;
      CRC:              if (counter_q + 1 == required_clock_count + 16) dat_tx_state_d = END_BIT;
      END_BIT:          dat_tx_state_d = BUS_SWITCH;

      BUS_SWITCH:       if (counter_q + 1 == 2) dat_tx_state_d = STATUS_START_BIT;

      STATUS_START_BIT: dat_tx_state_d = STATUS;
      STATUS:           if (counter_q + 1 == 3) dat_tx_state_d = STATUS_END_BIT;
      STATUS_END_BIT:   dat_tx_state_d = BUSY;

      BUSY:             if (dat0_i) dat_tx_state_d = DONE;
      DONE:             dat_tx_state_d = READY;
      default:          dat_tx_state_d = READY;
    endcase
  end

  logic [31:0] buffered_data_d, buffered_data_q;
  `FFL (buffered_data_q, buffered_data_d, sd_clk_en_p_i, '0);

  logic end_bit_err_q, end_bit_err_d;
  `FFL (end_bit_err_q, end_bit_err_d, sd_clk_en_p_i, '0);

  logic [2:0] status_q, status_d;
  `FFL (status_q, status_d, sd_clk_en_p_i, '0);

  logic [3:0] dat, dat_div1, dat_divn;
  
  //delay by half a clock cycle 
  always_ff @( negedge clk_i or negedge rst_ni) begin
    if(!rst_ni) dat_div1 <= 4'b1;
    else dat_div1 <= dat;
  end

  `FFL(dat_divn, dat, sd_clk_en_n_i, 4'b1, clk_i, rst_ni);

  assign dat_o = (div_1_i)  ? dat_div1 :  dat_divn; 

  always_comb begin : dat_write_datapath
    dat_en_o = '0;
    dat      = 'X;

    done_o        = '0;
    end_bit_err_o = 'X;
    crc_err_o     = 'X;

    counter_d       = '0;
    buffered_data_d = buffered_data_q;
    end_bit_err_d   = end_bit_err_q;
    status_d        = status_q;

    next_word_o     = '0;
    shift_out_crc   = '1;

    unique case (dat_tx_state_q)
      START_BIT: begin
        dat_en_o = '1;
        if (bus_width_is_4_i) dat = '0;
        else                  dat = 4'b1110;

        buffered_data_d = data_i;
        end_bit_err_d   = '0;
        status_d        = 0;
      end
      DAT: begin
        counter_d     = counter_q + 1;
        shift_out_crc = '0;

        dat_en_o = '1;
        if (bus_width_is_4_i) begin
          // Bus width = 4
          if (counter_q[2:0] == '0) begin
            next_word_o = sd_clk_en_p_i;
          end

          if (counter_q[2:0] == '1) begin
            buffered_data_d = data_i;
          end else if (counter_q[0] == '1) begin
            buffered_data_d = { 8'b0, buffered_data_q[31:8] };
          end

          if (counter_q[0] == '0) begin
            dat = buffered_data_q[7:4];
          end else begin
            dat = buffered_data_q[3:0];
          end
        end else begin
          // Bus width = 1

          if (counter_q[4:0] == '0) begin
            next_word_o = sd_clk_en_p_i;
          end

          if (counter_q[4:0] == '1) begin
            buffered_data_d = data_i;
          end else if (counter_q[2:0] == '1) begin
            buffered_data_d = { 8'b0, buffered_data_q[31:8] };
          end else begin
            buffered_data_d[7:0] = { buffered_data_q[6:0], 1'b0 };
          end

          dat = { 3'b111, buffered_data_q[7] };
        end
      end
      CRC: begin
        counter_d = counter_q + 1;
        shift_out_crc = '1;

        dat_en_o = '1;
        if (bus_width_is_4_i) begin
          dat = crc;
        end else begin
          dat = { 3'b111, crc[0] };
        end
      end
      END_BIT: begin
        dat_en_o = '1;
        dat      = '1;
      end

      BUS_SWITCH: counter_d = counter_q + 1;

      STATUS_START_BIT: if (dat0_i != '0) end_bit_err_d = '1;
      STATUS: begin
        counter_d = counter_q + 1;
        status_d = { status_q[1:0], dat0_i };
      end
      STATUS_END_BIT: if (dat0_i != '1) end_bit_err_d = '1;

      DONE: begin
        done_o        = sd_clk_en_p_i;
        end_bit_err_o = end_bit_err_q;
        crc_err_o     = status_q != 3'b010;
      end
      default: ;
    endcase
  end

  for (genvar i=0; i<4 ; i++) begin
    crc16_write i_crc16_write (
      .clk_i,
      .sd_clk_en_i        (sd_clk_en_p_i),
      .rst_ni,
      .shift_out_crc16_i  (shift_out_crc),
      .dat_ser_i          (dat[i]),
      .crc_ser_o          (crc[i])
    );
  end
endmodule
