module sd_card(
    input  logic       sd_clk_i,

    input  logic       cmd_en_i,
    input  logic       cmd_i,
    output logic       cmd_o,

    input  logic       dat_en_i,
    input  logic [3:0] dat_i,
    output logic [3:0] dat_o
);
  tri1 cmd;
  logic delayed_cmd_en;
  logic delayed_cmd;
  assign #(3ns) delayed_cmd_en = cmd_en_i;
  assign #(3ns) delayed_cmd    = cmd_i;
  assign cmd = delayed_cmd_en ? delayed_cmd : 'z;
  assign #(3ns) cmd_o = cmd;

  tri1 [3:0] dat;
  logic delayed_dat_en;
  logic [3:0] delayed_dat;
  assign #(3ns) delayed_dat_en = dat_en_i;
  assign #(3ns) delayed_dat    = dat_i;
  assign dat = delayed_dat_en ? delayed_dat : 'z;
  assign #(3ns) dat_o = dat;

  sdModel i_model (
    .sdClk (sd_clk_i),
    .cmd   (cmd),
    .dat   (dat)
  );
endmodule
