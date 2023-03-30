onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -subitemconfig {/tb_cheshire_soc/fix/i_dut/gen_llc/i_llc/slv_req_i.aw -expand /tb_cheshire_soc/fix/i_dut/gen_llc/i_llc/slv_req_i.w -expand} /tb_cheshire_soc/fix/i_dut/gen_llc/i_llc/slv_req_i
add wave -noupdate /tb_cheshire_soc/fix/i_dut/gen_llc/i_llc/slv_resp_o
add wave -noupdate /tb_cheshire_soc/fix/i_dut/clk_i
add wave -noupdate /tb_cheshire_soc/fix/i_dut/rst_ni
add wave -noupdate /tb_cheshire_soc/fix/i_dut/test_mode_i
add wave -noupdate /tb_cheshire_soc/fix/i_dut/boot_mode_i
add wave -noupdate /tb_cheshire_soc/fix/i_dut/rtc_i
add wave -noupdate /tb_cheshire_soc/fix/i_dut/axi_llc_mst_req_o
add wave -noupdate /tb_cheshire_soc/fix/i_dut/axi_llc_mst_rsp_i
add wave -noupdate /tb_cheshire_soc/fix/i_dut/axi_ext_mst_req_i
add wave -noupdate /tb_cheshire_soc/fix/i_dut/axi_ext_mst_rsp_o
add wave -noupdate /tb_cheshire_soc/fix/i_dut/axi_ext_slv_req_o
add wave -noupdate /tb_cheshire_soc/fix/i_dut/axi_ext_slv_rsp_i
add wave -noupdate /tb_cheshire_soc/fix/i_dut/reg_ext_slv_req_o
add wave -noupdate /tb_cheshire_soc/fix/i_dut/reg_ext_slv_rsp_i
add wave -noupdate /tb_cheshire_soc/fix/i_dut/intr_ext_i
add wave -noupdate /tb_cheshire_soc/fix/i_dut/meip_ext_o
add wave -noupdate /tb_cheshire_soc/fix/i_dut/seip_ext_o
add wave -noupdate /tb_cheshire_soc/fix/i_dut/mtip_ext_o
add wave -noupdate /tb_cheshire_soc/fix/i_dut/msip_ext_o
add wave -noupdate /tb_cheshire_soc/fix/i_dut/dbg_active_o
add wave -noupdate /tb_cheshire_soc/fix/i_dut/dbg_ext_req_o
add wave -noupdate /tb_cheshire_soc/fix/i_dut/dbg_ext_unavail_i
add wave -noupdate /tb_cheshire_soc/fix/i_dut/jtag_tck_i
add wave -noupdate /tb_cheshire_soc/fix/i_dut/jtag_trst_ni
add wave -noupdate /tb_cheshire_soc/fix/i_dut/jtag_tms_i
add wave -noupdate /tb_cheshire_soc/fix/i_dut/jtag_tdi_i
add wave -noupdate /tb_cheshire_soc/fix/i_dut/jtag_tdo_o
add wave -noupdate /tb_cheshire_soc/fix/i_dut/jtag_tdo_oe_o
add wave -noupdate /tb_cheshire_soc/fix/i_dut/uart_tx_o
add wave -noupdate /tb_cheshire_soc/fix/i_dut/uart_rx_i
add wave -noupdate /tb_cheshire_soc/fix/i_dut/uart_rts_no
add wave -noupdate /tb_cheshire_soc/fix/i_dut/uart_dtr_no
add wave -noupdate /tb_cheshire_soc/fix/i_dut/uart_cts_ni
add wave -noupdate /tb_cheshire_soc/fix/i_dut/uart_dsr_ni
add wave -noupdate /tb_cheshire_soc/fix/i_dut/uart_dcd_ni
add wave -noupdate /tb_cheshire_soc/fix/i_dut/uart_rin_ni
add wave -noupdate /tb_cheshire_soc/fix/i_dut/i2c_sda_o
add wave -noupdate /tb_cheshire_soc/fix/i_dut/i2c_sda_i
add wave -noupdate /tb_cheshire_soc/fix/i_dut/i2c_sda_en_o
add wave -noupdate /tb_cheshire_soc/fix/i_dut/i2c_scl_o
add wave -noupdate /tb_cheshire_soc/fix/i_dut/i2c_scl_i
add wave -noupdate /tb_cheshire_soc/fix/i_dut/i2c_scl_en_o
add wave -noupdate /tb_cheshire_soc/fix/i_dut/spih_sck_o
add wave -noupdate /tb_cheshire_soc/fix/i_dut/spih_sck_en_o
add wave -noupdate /tb_cheshire_soc/fix/i_dut/spih_csb_o
add wave -noupdate /tb_cheshire_soc/fix/i_dut/spih_csb_en_o
add wave -noupdate /tb_cheshire_soc/fix/i_dut/spih_sd_o
add wave -noupdate /tb_cheshire_soc/fix/i_dut/spih_sd_en_o
add wave -noupdate /tb_cheshire_soc/fix/i_dut/spih_sd_i
add wave -noupdate /tb_cheshire_soc/fix/i_dut/gpio_i
add wave -noupdate /tb_cheshire_soc/fix/i_dut/gpio_o
add wave -noupdate /tb_cheshire_soc/fix/i_dut/gpio_en_o
add wave -noupdate /tb_cheshire_soc/fix/i_dut/slink_rcv_clk_i
add wave -noupdate /tb_cheshire_soc/fix/i_dut/slink_rcv_clk_o
add wave -noupdate /tb_cheshire_soc/fix/i_dut/slink_i
add wave -noupdate /tb_cheshire_soc/fix/i_dut/slink_o
add wave -noupdate /tb_cheshire_soc/fix/i_dut/vga_hsync_o
add wave -noupdate /tb_cheshire_soc/fix/i_dut/vga_vsync_o
add wave -noupdate /tb_cheshire_soc/fix/i_dut/vga_red_o
add wave -noupdate /tb_cheshire_soc/fix/i_dut/vga_green_o
add wave -noupdate /tb_cheshire_soc/fix/i_dut/vga_blue_o
add wave -noupdate -divider <NULL>
add wave -noupdate -divider <NULL>
add wave -noupdate -divider <NULL>
add wave -noupdate -divider <NULL>
add wave -noupdate /tb_cheshire_soc/fix/i_dut/gen_uart/i_uart/i_apb_uart/iRXData
add wave -noupdate -divider <NULL>
add wave -noupdate /tb_cheshire_soc/fix/i_dut/gen_uart/i_uart/i_apb_uart/rx_State
add wave -noupdate /tb_cheshire_soc/fix/i_dut/gen_uart/i_uart/i_apb_uart/tx_State
add wave -noupdate -divider <NULL>
add wave -noupdate /tb_cheshire_soc/fix/i_dut/gen_uart/i_uart/reg_req_i
add wave -noupdate /tb_cheshire_soc/fix/i_dut/gen_uart/i_uart/reg_rsp_o
add wave -noupdate /tb_cheshire_soc/fix/i_dut/gen_uart/i_uart/intr_o
add wave -noupdate /tb_cheshire_soc/fix/i_dut/gen_uart/i_uart/out1_no
add wave -noupdate /tb_cheshire_soc/fix/i_dut/gen_uart/i_uart/out2_no
add wave -noupdate /tb_cheshire_soc/fix/i_dut/gen_uart/i_uart/rts_no
add wave -noupdate /tb_cheshire_soc/fix/i_dut/gen_uart/i_uart/dtr_no
add wave -noupdate /tb_cheshire_soc/fix/i_dut/gen_uart/i_uart/cts_ni
add wave -noupdate /tb_cheshire_soc/fix/i_dut/gen_uart/i_uart/dsr_ni
add wave -noupdate /tb_cheshire_soc/fix/i_dut/gen_uart/i_uart/dcd_ni
add wave -noupdate /tb_cheshire_soc/fix/i_dut/gen_uart/i_uart/rin_ni
add wave -noupdate /tb_cheshire_soc/fix/i_dut/gen_uart/i_uart/sin_i
add wave -noupdate /tb_cheshire_soc/fix/i_dut/gen_uart/i_uart/sout_o
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {6853275373 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 196
configure wave -valuecolwidth 40
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {37216462292 ps}
