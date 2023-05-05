// Copyright 2018 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Author: Florian Zaruba, zarubaf@iis.ee.ethz.ch
// Description: PWM Fan Control for Genesys II board

module fan_ctrl (
    input  logic       clk_i,
    input  logic       rst_ni,
    input  logic [3:0] pwm_setting_i,
    output logic       fan_pwm_o
);
    logic [3:0]  ms_clock_d, ms_clock_q;
    logic [11:0] cycle_counter_d, cycle_counter_q;

    // clock divider
    always_comb begin
        cycle_counter_d = cycle_counter_q + 1;
        ms_clock_d = ms_clock_q;

        // divide clock by 49
        // At 50 MHz input clock this results in a 62.5 kHz
        // PWM Signal 
        if (cycle_counter_q == 49) begin
            cycle_counter_d = 0;
            ms_clock_d = ms_clock_q + 1;
        end

        if (ms_clock_q == 15) begin
            ms_clock_d = 0;
        end
    end

    // duty cycle
    always_comb begin
        if (ms_clock_q < pwm_setting_i) begin
            fan_pwm_o = 1'b1;
        end else begin
            fan_pwm_o = 1'b0;
        end
    end

    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (~rst_ni) begin
            ms_clock_q      <= '0;
            cycle_counter_q <= '0;
        end else begin
            ms_clock_q      <= ms_clock_d;
            cycle_counter_q <= cycle_counter_d;
        end
    end
endmodule
