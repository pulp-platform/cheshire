`include "common_cells/registers.svh"
`include "common_cells/assertions.svh"
`include "defines.svh"

module dat_buffer #(
  parameter int unsigned NumWords        = 256,
  parameter int unsigned MaxBlockBitSize
) (
  input  logic clk_i,
  input  logic rst_ni,

  input  logic read_operation_i,
  input  logic write_operation_i,

  input  logic        read_ready_i,
  output logic        read_valid_o,
  output logic [31:0] read_data_o,

  input  logic        write_valid_i,
  input  logic [31:0] write_data_i,
  output logic        write_ready_o,

  output logic        empty_o,

  input  sdhci_reg_pkg::sdhci_reg2hw_t reg2hw_i,

  output logic [31:0]      buffer_data_port_d_o,
  output `writable_reg_t() buffer_read_enable_o,
  output `writable_reg_t() buffer_write_enable_o,

  output `writable_reg_t([15:0]) block_count_o
);
  localparam int NumBytes = NumWords * 4;

  logic [cf_math_pkg::idx_width(NumBytes + 1)-1:0] reg_remaining_bytes;
  logic [cf_math_pkg::idx_width(NumWords + 1)-1:0] reg_length;
  logic enable_reg, reg_empty, reg_full, reg_push, reg_pop;
  logic [31:0] reg_push_data, reg_pop_data;

  logic [MaxBlockBitSize-1:0] block_size;
  assign block_size = MaxBlockBitSize'(reg2hw_i.block_size.transfer_block_size.q);

  logic [MaxBlockBitSize-1:0] current_word_counter_q, current_word_counter_d;
  `FF (current_word_counter_q, current_word_counter_d, '0);

  assign empty_o = reg_empty;

  logic has_block, has_space;
  assign has_space = reg_remaining_bytes >= block_size;
  assign has_block = reg_length * 4 >= block_size;

  assign enable_reg = read_operation_i || write_operation_i;

  always_comb begin
    reg_push      = '0;
    reg_push_data = 'X;
    reg_pop       = '0;

    buffer_read_enable_o  = '{ de: '1, d: '0 };
    buffer_write_enable_o = '{ de: '1, d: '0 };
    buffer_data_port_d_o  = '0;

    block_count_o = '{ de: '0, d: 'X };

    write_ready_o = '0;
    read_valid_o  = '0;
    read_data_o   = 'X;

    if (read_operation_i) begin
      reg_push      = write_valid_i;
      reg_push_data = write_data_i;
      write_ready_o = has_space;

      buffer_read_enable_o.d = has_block;
      buffer_data_port_d_o   = reg_pop_data;
      reg_pop                = reg2hw_i.buffer_data_port.re;
    end else if (write_operation_i) begin
      reg_pop      = read_ready_i;
      read_data_o  = reg_pop_data;
      read_valid_o = has_block;

      buffer_write_enable_o.d = has_space; 
      reg_push_data           = reg2hw_i.buffer_data_port.q;
      reg_push                = reg2hw_i.buffer_data_port.qe;
    end


    current_word_counter_d = current_word_counter_q;

    if ((read_operation_i && reg2hw_i.buffer_data_port.re) || (write_operation_i && reg2hw_i.buffer_data_port.qe)) begin
      if (current_word_counter_q == (block_size + 3) / 4 - 1) begin
        current_word_counter_d = '0;

        // TODO block count enable / infity block transfer
        if (reg2hw_i.transfer_mode.multi_single_block_select.q) begin
          // TODO this will have to be changed when adding support for suspend / resume
          block_count_o = '{ de: '1, d: reg2hw_i.block_count.q - 1 };
          if (reg2hw_i.block_count.q != 'b1) begin
            // To trigger an interrupt
            buffer_write_enable_o.d = '0;
            buffer_read_enable_o.d  = '0;
          end
        end
      end else begin
        current_word_counter_d = current_word_counter_q + 1;
      end
    end
  end

  // assign reg_remaining_bytes = {cf_math_pkg::idx_width(NumBytes + 1)}'(NumBytes - reg_length * 4);
  assign reg_remaining_bytes = NumBytes - reg_length * 4;

  sram_shift_reg #(
    .NumWords (NumWords)
  ) i_sram_shift_reg (
    .clk_i,
    .rst_ni,
  
    .en_i (enable_reg),

    .pop_front_i  (reg_pop),
    .front_data_o (reg_pop_data),
  
    .push_back_i  (reg_push),
    .back_data_i  (reg_push_data),
  
    .full_o   (reg_full),
    .empty_o  (reg_empty),
    .length_o (reg_length)
  );
endmodule