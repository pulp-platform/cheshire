`include "common_cells/registers.svh"
`include "defines.svh"

module sd_clk_generator (
  input  logic clk_i,
  input  logic rst_ni,

  input  sdhci_reg_pkg::sdhci_reg2hw_t reg2hw_i,

  input  logic pause_sd_clk_i,
  output logic sd_clk_o,

  output logic clk_en_p_o, //high when next rising clk edge coincides with rising sd_clk edge
  output logic clk_en_n_o, //high when next rising clk edge coincides with falling sd_clk edge

  output logic div_1_o,   //high if source clock isn't divided, needed for negative edge triggering

  output `writable_reg_t() sd_clk_stable_o
);
  logic[7:0] div_d, div_q;
  always_comb begin : clk_divider_logic
    div_d = div_q;
    if (!reg2hw_i.clock_control.sd_clock_enable.q) div_d = reg2hw_i.clock_control.sdclk_frequency_select.q;
  end  
  `FF(div_q, div_d, 8'b0, clk_i, rst_ni);

  //counter
  logic[7:0]  cnt_d, cnt_q;
  always_comb begin : counter
    cnt_d = cnt_q + 1;
  end
  `FF(cnt_q, cnt_d, 8'b0, clk_i, rst_ni);

  logic clk_en_p_d, clk_en_p_q;
  `FF(clk_en_p_q, clk_en_p_d, '0, clk_i, rst_ni);

  logic clk_en_n_d, clk_en_n_q;
  `FF(clk_en_n_q, clk_en_n_d, '0, clk_i, rst_ni);

  //clk source multiplexer
  logic clk_div_d, clk_div_q, clk_o_ungated;
  always_comb begin : clk_div_mux
    clk_en_p_d  = clk_en_p_q;
    clk_en_n_d  = clk_en_n_q;

    unique case (div_q)
      8'h01:  begin 
        clk_div_d = cnt_q[0];
        clk_en_p_d  = !cnt_q[0];
        clk_en_n_d  = cnt_q[0];
      end
      8'h02:  begin
        clk_div_d = cnt_q[1];
        clk_en_p_d  = cnt_q[1:0] == 2'b01;
        clk_en_n_d  = cnt_q[1:0] == 2'b11;
      end
      8'h04:  begin
        clk_div_d = cnt_q[2];
        clk_en_p_d  = cnt_q[2:0] == 3'b011;   
        clk_en_n_d  = cnt_q[2:0] == 3'b111;   
      end
      8'h08:  begin
        clk_div_d = cnt_q[3];    
        clk_en_p_d  = cnt_q[3:0] == 4'b0111;
        clk_en_n_d  = cnt_q[3:0] == 4'b1111;
      end
      8'h10:  begin
        clk_div_d = cnt_q[4];
        clk_en_p_d  = cnt_q[4:0] == 5'b01111;
        clk_en_n_d  = cnt_q[4:0] == 5'b11111;
      end
      8'h20:  begin
        clk_div_d = cnt_q[5];
        clk_en_p_d  = cnt_q[5:0] == 6'b011111;
        clk_en_n_d  = cnt_q[5:0] == 6'b111111;
      end
      8'h40:  begin
        clk_div_d = cnt_q[6];
        clk_en_p_d  = cnt_q[6:0] == 7'b0111111;
        clk_en_n_d  = cnt_q[6:0] == 7'b1111111;
      end
      8'h80:  begin
        clk_div_d = cnt_q[7];
        clk_en_p_d  = cnt_q[7:0] == 8'b01111111;
        clk_en_n_d  = cnt_q[7:0] == 8'b11111111;
      end
      
      default: clk_div_d = 1'b1;
    endcase

    clk_o_ungated = (div_q == 8'h00) ?  clk_i : clk_div_q;
    clk_en_p_o      = (div_q == 8'h00) ?  '1 : clk_en_p_q;
    clk_en_n_o      = (div_q == 8'h00) ?  '1 : clk_en_n_q;
    sd_clk_o =  (reg2hw_i.clock_control.sd_clock_enable.q && !pause_sd_clk_i) ? clk_o_ungated : 1'b1;
  end
  `FF(clk_div_q, clk_div_d, 1'b1, clk_i, rst_ni);

  assign div_1_o = (div_q == 8'h00);
  assign sd_clk_stable_o = '{ de: '1, d: reg2hw_i.clock_control.internal_clock_enable.q};
endmodule