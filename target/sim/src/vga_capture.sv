// Copyright 2026 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

//Serge Wüest <swueest@student.ethz.ch>

//Additional testbench script for axi_vga integration into cheshire

module vga_capture #(
    parameter time ClkPeriod             = 5ns,
    parameter int unsigned RedWidth      = 5,
    parameter int unsigned GreenWidth    = 6,
    parameter int unsigned BlueWidth     = 5,

    parameter int unsigned FrameWidth    = 640,
    parameter int unsigned FrameHeight   = 480,

    parameter int unsigned ClkDiv        = 2,

    parameter int unsigned HoriBackPorch = 48,
    parameter int unsigned VertBackPorch = 33,

    parameter bit HsyncPol = 1'b1,
    parameter bit VsyncPol = 1'b1
) (
    input logic clk_i,
    input logic rst_ni,

    input logic hsync_i,
    input logic vsync_i,

    input logic [RedWidth-1:0]   red_i,
    input logic [GreenWidth-1:0] green_i,
    input logic [BlueWidth-1:0]  blue_i
);

    typedef struct packed {
        logic [RedWidth-1:0]   r;
        logic [GreenWidth-1:0] g;
        logic [BlueWidth-1:0]  b;
    } pixel_t;

    pixel_t framebuffer [FrameHeight][FrameWidth];

  // write_frame_to_bmp task
	task automatic write_frame_to_bmp(string file);
		automatic int fd, fd_debug;
		automatic int i, j;
		automatic byte r8, g8, b8;
		automatic int row_pad = (4 - (FrameWidth * 3) % 4) % 4;
		automatic int filesize = 54 + (FrameWidth * 3 + row_pad) * FrameHeight;

		fd = $fopen(file, "wb");
		fd_debug = $fopen("bmp_write_dump.txt", "w");

		// bitmap header (14 bytes)
		$fwrite(fd, "%c%c", "B", "M");                      // signature (fixed)
		$fwrite(fd, "%u", filesize);                        // file size (#bytes)
		$fwrite(fd, "%u", 0);                               // reserved
		$fwrite(fd, "%u", 54);                              // data offset

		// DIP header (BITMAPINFOHEADER)
		$fwrite(fd, "%u", 40);                              // header size
		$fwrite(fd, "%u", FrameWidth);                      // img width (#pixels)
		$fwrite(fd, "%u", FrameHeight);                     // img height (#pixels)
		$fwrite(fd, "%u", 32'h00_18_00_01); // #planes (must be 1), #bits per pixel (24)
		$fwrite(fd, "%u", 0);                               // compression (no)
		$fwrite(fd, "%u", (FrameWidth * 3 + row_pad) * FrameHeight); // image size
		$fwrite(fd, "%u", 1000);                            // X pixels/meter
		$fwrite(fd, "%u", 1000);                            // Y pixels/meter
		$fwrite(fd, "%u", 0);                               // colors used
		$fwrite(fd, "%u", 0);                               // important colors

		// Pixels (format:BGR, frame bottom-up)
		for (i = FrameHeight-1; i >= 0; i--) begin
			for (j = 0; j < FrameWidth; j++) begin
				r8 = framebuffer[i][j].r << (8 - RedWidth);
				g8 = framebuffer[i][j].g << (8 - GreenWidth);
				b8 = framebuffer[i][j].b << (8 - BlueWidth);
				$fwrite(fd, "%c%c%c", b8, g8, r8);
				$fwrite(fd_debug, "(row=%0d, col=%0d): R=%0d, G=%0d, B=%0d\n", FrameHeight - 1 - i, j, r8, g8, b8);
			end
			for (j = 0; j < row_pad; j++)
				$fwrite(fd, "%c", 8'h00);
		end

		$fclose(fd_debug);
		$fclose(fd);
	endtask

    // frame_capture initial block
	initial begin : frame_capture
		automatic int clk_div_counter = 0;
		automatic int hsync_porch = 0, vsync_porch = 0;
		automatic bit hsync_prev = 0,  vsync_prev = 0;
		automatic int row = 0, col = 0;
		automatic int frame_num = 0;
		automatic bit capturing = 0;
		automatic string file;

		wait (rst_ni === 0);
		@(posedge rst_ni);
		@(negedge vsync_i); // sync capturing on first vsync
		forever begin
			// before the divided clock, capture the previous values
			if (clk_div_counter == '0) begin
				hsync_prev = hsync_i;
				vsync_prev = vsync_i;
			end

			@(posedge clk_i);
			#(0.8 * ClkPeriod);

			// clock divider: skip rest except every N-th clock edge
			clk_div_counter++;
			if (clk_div_counter < ClkDiv) begin
				continue;
			end else begin
				clk_div_counter = 0;
			end

			// start capturing frame after vsync pulse
			if (vsync_prev == VsyncPol &&
			    vsync_i == ~VsyncPol) begin
				vsync_porch = 0;
				hsync_porch = 0;
				row = 0;
				col = 0;
				capturing = 1;
				$info("VSYNC PULSE: Start capturing frame");
				continue;
			end

			// skip vertical back porch
			if (capturing && vsync_porch < VertBackPorch) begin
				if (hsync_prev == HsyncPol &&
				    hsync_i == ~HsyncPol) begin
					vsync_porch++;
				end
				continue;
			end


			// capture lines with visible area
			if (capturing && row < FrameHeight) begin
				// start capturing current line after hsync pulse
				if (hsync_prev == HsyncPol &&
				    hsync_i == ~HsyncPol) begin
					hsync_porch = 0;
					col = 0;
					row++;
					$info("Capturing line no #%0d", row);
					continue;
				end

				// skip horizontal back porch
				if (hsync_porch < (HoriBackPorch-1)) begin
					hsync_porch++;
					continue;
				end

				// capture pixel in visible area of this line
				if (col < FrameWidth) begin
					framebuffer[row][col].r = red_i;
					framebuffer[row][col].g = green_i;
					framebuffer[row][col].b = blue_i;
					col++;
				end
			end

			// if (capturing && row == FrameHeight) begin
			// 	file = $sformatf("frame_%0d.bmp", frame_num++);
			// 	write_frame_to_bmp(file);
			// 	$info("Frame #%0d captured to %s", frame_num-1, file);
			// 	capturing = 0;
			// end

			//Capturing only one frame
			//
			if (capturing && row == FrameHeight) begin
				file = $sformatf("frame_%0d.bmp", frame_num++);
				write_frame_to_bmp(file);
				$info("Frame #%0d captured to %s", frame_num-1, file);
				capturing = 0;
			end
		end
	end

endmodule