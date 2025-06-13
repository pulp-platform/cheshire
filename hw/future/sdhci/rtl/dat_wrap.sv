`include "common_cells/registers.svh"
`include "defines.svh"

module dat_wrap #(
  parameter int MaxBlockBitSize = 10 // max_block_length = 512 in caps
) (
  input  logic clk_i,
  input  logic sd_clk_en_p_i,
  input  logic sd_clk_en_n_i,
  input  logic div_1_i,
  input  logic rst_ni,
  
  input  logic [3:0] dat_i,
  output logic       dat_en_o,
  output logic [3:0] dat_o,

  input  logic sd_cmd_done_i,
  input  logic sd_rsp_done_i,

  output logic request_cmd12_o,
  output logic pause_sd_clk_o,

  input  sdhci_reg_pkg::sdhci_reg2hw_t reg2hw_i,

  output `writable_reg_t()       data_crc_error_o,
  output `writable_reg_t()       data_end_bit_error_o,
  output `writable_reg_t()       data_timeout_error_o,

  output logic [31:0]            buffer_data_port_d_o,
  output `writable_reg_t()       buffer_read_enable_o,
  output `writable_reg_t()       buffer_write_enable_o,

  output `writable_reg_t()       read_transfer_active_o,
  output `writable_reg_t()       write_transfer_active_o,

  output `writable_reg_t([15:0]) block_count_o
);

  typedef enum logic [3:0] {
    READY,

    // Read
    WAIT_FOR_CMD,
    WAIT_FOR_READ_BUFFER,
    START_READING,
    READING,
    DONE_READING_BLOCK,
    READING_BUSY,
    TIMEOUT_READING,
    DONE_READING,

    // Write
    WAIT_FOR_RSP,
    WAIT_FOR_WRITE_BUFFER,
    START_WRITING,
    WRITING,
    DONE_WRITING_BLOCK,
    DONE_WRITING
  } dat_state_e;

  dat_state_e state_q, state_d;
  `FF (state_q, state_d, READY, clk_i, rst_ni);

  logic buffer_write_operation, buffer_read_operation;
  logic buffer_write_ready, buffer_write_valid, buffer_read_ready, buffer_read_valid, buffer_empty;
  logic [31:0] buffer_write_data, buffer_read_data;

  logic start_read, read_valid, read_done, read_crc_err, read_end_bit_err;
  logic [31:0] read_data;

  logic start_write, write_requests_next_word, write_done, write_crc_err, write_end_bit_err;
  logic [31:0] write_data;

  logic [MaxBlockBitSize-1:0] reg_start_length_q, reg_start_length_d;
  logic [MaxBlockBitSize-1:0] block_size;
  logic rsp_done_q, rsp_done_d;
  logic [15:0] transmitted_block_counter_q, transmitted_block_counter_d;

  logic read_timeout;

  always_comb begin
    state_d = state_q;

    unique case (state_q)
      READY: begin
        if (reg2hw_i.command.command_index.qe && reg2hw_i.command.data_present_select.q) begin
          if (reg2hw_i.transfer_mode.data_transfer_direction_select.q) begin
            state_d = WAIT_FOR_CMD;
          end else begin
            state_d = WAIT_FOR_WRITE_BUFFER;
          end
        end
      end

      WAIT_FOR_CMD:         if (sd_cmd_done_i) state_d = START_READING;
      WAIT_FOR_READ_BUFFER: if (buffer_write_ready) state_d = START_READING;
      START_READING:        if (sd_clk_en_p_i) state_d = READING;
      READING: begin
        if (read_timeout) begin
          state_d = TIMEOUT_READING;
          // Reset reader
        end else if (read_done) begin
          state_d = DONE_READING_BLOCK;
        end
      end
      DONE_READING_BLOCK: begin
        if (transmitted_block_counter_q == 'b1) begin
          state_d = READING_BUSY;
        end else if (buffer_write_ready) begin
          state_d = START_READING;
        end else begin
          state_d = WAIT_FOR_READ_BUFFER;
        end
      end
      READING_BUSY:       if (buffer_empty) state_d = DONE_READING;
      TIMEOUT_READING:    state_d = DONE_READING;
      DONE_READING:       state_d = READY;

      WAIT_FOR_RSP:          if (sd_rsp_done_i) state_d = WAIT_FOR_WRITE_BUFFER;
      WAIT_FOR_WRITE_BUFFER: if (buffer_read_valid) state_d = START_WRITING;
      START_WRITING:         if (sd_clk_en_p_i) state_d = WRITING;
      WRITING:               if (write_done) state_d = DONE_WRITING_BLOCK;
      DONE_WRITING_BLOCK:    state_d = transmitted_block_counter_q == 'b1 ? DONE_WRITING : WAIT_FOR_WRITE_BUFFER;
      DONE_WRITING:          state_d = READY;

      default: state_d = READY;
    endcase
  end
  
  `FF (reg_start_length_q, reg_start_length_d, '0, clk_i, rst_ni)

  assign block_size = MaxBlockBitSize'(reg2hw_i.block_size.transfer_block_size.q);

  `FF (rsp_done_q, rsp_done_d, '0, clk_i, rst_ni);

  `FF (transmitted_block_counter_q, transmitted_block_counter_d, '0)

  logic read_run_timeout;
  always_comb begin
    read_run_timeout = '0;

    request_cmd12_o  = '0;
    pause_sd_clk_o   = '0;

    data_crc_error_o     = '{ de: '0, d: '1};
    data_end_bit_error_o = '{ de: '0, d: '1};
    data_timeout_error_o = '{ de: '0, d: '1};

    read_transfer_active_o  = '{ de: '1, d: '0};
    write_transfer_active_o = '{ de: '1, d: '0};

    transmitted_block_counter_d = transmitted_block_counter_q;

    start_read  = '0;
    start_write = '0;
    write_data  = 'X;

    buffer_read_ready  = '0;
    buffer_write_valid = '0;
    buffer_write_data  = 'X;

    unique case (state_q)
      READY: begin
        transmitted_block_counter_d = reg2hw_i.block_count.q;
      end
      WAIT_FOR_CMD: begin
        read_transfer_active_o.d  = '1;
      end
      WAIT_FOR_READ_BUFFER: begin
        read_transfer_active_o.d = '1;
        pause_sd_clk_o = '1;
      end
      START_READING: begin
        read_transfer_active_o.d = '1;
        start_read = '1;
      end
      READING: begin
        read_transfer_active_o.d = '1;
        read_run_timeout = '1;

        if (read_valid) begin
          buffer_write_valid = '1;
          buffer_write_data  = read_data;
        end

        if (read_done) begin
          data_crc_error_o.de     = read_crc_err;
          data_end_bit_error_o.de = read_end_bit_err;
        end
      end
      READING_BUSY: begin
        read_transfer_active_o.d = '1;
      end
      DONE_READING_BLOCK: begin
        read_transfer_active_o.d = '1;
        transmitted_block_counter_d = transmitted_block_counter_q - 1;
      end
      TIMEOUT_READING: begin
        read_transfer_active_o.d = '1;
        data_timeout_error_o.de  = '1;
      end
      DONE_READING: begin
        read_transfer_active_o.d = '1;

        if (reg2hw_i.transfer_mode.auto_cmd12_enable.q) request_cmd12_o = '1;
      end

      WAIT_FOR_RSP: begin
        write_transfer_active_o.d = '1;
      end
      WAIT_FOR_WRITE_BUFFER: begin
        write_transfer_active_o.d = '1;
      end
      START_WRITING: begin
        write_transfer_active_o.d = '1;
        start_write = '1;
      end
      WRITING: begin
        write_transfer_active_o.d = '1;

        if (write_requests_next_word) buffer_read_ready = '1;
        write_data = buffer_read_data; 

        if (write_done) begin
          data_crc_error_o.de     = write_crc_err;
          data_end_bit_error_o.de = write_end_bit_err;
        end
      end
      DONE_WRITING_BLOCK: begin
        write_transfer_active_o.d = '1;

        transmitted_block_counter_d = transmitted_block_counter_q - 1;
      end
      DONE_WRITING: begin
        write_transfer_active_o.d = '1;

        if (reg2hw_i.transfer_mode.auto_cmd12_enable.q) request_cmd12_o = '1;
      end
      
      default: ;
    endcase
  end
  
  // Read timeout
  dat_read_timeout i_read_timeout (
    .clk_i,
    .rst_ni,

    .running_i      (read_run_timeout),
    .timeout_bits_i (reg2hw_i.timeout_control.data_timeout_counter_value),

    .timeout_o      (read_timeout)
  );


  dat_buffer #(
    .NumWords        (256), // = 1024, Just enough to double buffer 512 byte blocks
    .MaxBlockBitSize (MaxBlockBitSize)
  ) i_dat_buffer (
    .clk_i,
    .rst_ni,

    .read_operation_i  (reg2hw_i.present_state.read_transfer_active.q),
    .write_operation_i (reg2hw_i.present_state.write_transfer_active.q),

    .read_ready_i  (buffer_read_ready),
    .read_valid_o  (buffer_read_valid),
    .read_data_o   (buffer_read_data),

    .write_valid_i (buffer_write_valid),
    .write_data_i  (buffer_write_data),
    .write_ready_o (buffer_write_ready),

    .empty_o       (buffer_empty),
  
    .reg2hw_i,
    .buffer_data_port_d_o,
    .buffer_read_enable_o,
    .buffer_write_enable_o,
    .block_count_o
  );

  dat_read #(
    .MaxBlockBitSize (MaxBlockBitSize)
  ) i_read (
    .clk_i,
    .sd_clk_en_i   (sd_clk_en_p_i),
    .rst_ni,
    .dat_i,

    .start_i          (start_read),
    .block_size_i     (block_size),
    .bus_width_is_4_i (reg2hw_i.host_control.data_transfer_width.q),
    
    .data_valid_o  (read_valid),
    .data_o        (read_data),
    
    .done_o        (read_done),
    .crc_err_o     (read_crc_err),
    .end_bit_err_o (read_end_bit_err)
  );

  dat_write #(
    .MaxBlockBitSize (MaxBlockBitSize)
  ) i_write (
    .clk_i,
    .sd_clk_en_p_i  (sd_clk_en_p_i),
    .sd_clk_en_n_i  (sd_clk_en_n_i),
    .div_1_i        (div_1_i),
    .rst_ni,
    .dat0_i         (dat_i[0]),
    .dat_o,
    .dat_en_o,

    .start_i          (start_write),
    .block_size_i     (block_size),
    .bus_width_is_4_i (reg2hw_i.host_control.data_transfer_width.q),

    .data_i        (write_data),
    .next_word_o   (write_requests_next_word),

    .done_o        (write_done),
    .crc_err_o     (write_crc_err),
    .end_bit_err_o (write_end_bit_err)
  );
endmodule