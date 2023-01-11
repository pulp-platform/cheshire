// Copyright 2022 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51

module uart_tb_rx #(
    parameter BaudRate = 115200,
    parameter ParityEn = 0
) (
    input  logic rx,
    input  logic rx_en,
    output logic word_done,
    output byte  bite,
    output logic bite_evt   // Track posedges to wait for, capture characters
);

  timeunit 1ns;

  // bit period is in ns
  localparam unsigned NsUnitScaler = 1000000000;
  localparam real     BitPeriod = (NsUnitScaler / BaudRate);

  logic   [      7:0] character;
  logic               debug_clock;
  logic   [256*8-1:0] stringa;
  logic               parity;
  integer             charnum;
  integer             file;

  event               byte_evt_internal;

  // Generate pulsed byte event output
  initial bite_evt = 1'b0;
  always @(byte_evt_internal) begin
    bite_evt = 1'b1;
    #1;
    bite_evt = 1'b0;
  end

  initial begin
    charnum = 0;
    file    = $fopen("uart.log", "w");
  end

  always begin
    if (rx_en) begin
      debug_clock = 1;
      @(negedge rx);

      #(BitPeriod / 2 - 1);
      debug_clock = 0;
      for (int i = 0; i <= 7; i++) begin
        #BitPeriod character[i] = rx;
        debug_clock = 1 - debug_clock;
      end

      if (ParityEn == 1) begin
        // check parity
        #BitPeriod parity = rx;
        debug_clock = 1 - debug_clock;

        for (int i = 7; i >= 0; i--) begin
          parity = character[i] ^ parity;
        end

        if (parity == 1'b1) begin
          $display("Parity error detected");
        end
      end

      // STOP BIT
      #(BitPeriod / 2);
      debug_clock = 1 - debug_clock;

      // Apply at output, fire output event
      bite = character;
      ->byte_evt_internal;

      $fwrite(file, "%c", character);
      stringa[(255-charnum)*8 +: 8] = character;
      if (character == 8'h0A || charnum == 254) // line feed or max. chars reached
          begin
        if (character == 8'h0A)
          stringa[(255-charnum)*8 +: 8] = 8'h0;      // null terminate string, replace line feed
        else stringa[(255-charnum-1)*8 +: 8] = 8'h0; // null terminate string

        $write("UART: %s\n", stringa);
        charnum   = 0;
        stringa   = "";
        word_done = 1;
        #1 word_done = 0;
      end else begin
        charnum = charnum + 1;
      end
    end else begin
      charnum   = 0;
      stringa   = "";
      word_done = 0;
      #10;
    end
  end
endmodule
