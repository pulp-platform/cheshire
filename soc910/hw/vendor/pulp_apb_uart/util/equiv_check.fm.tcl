set hdlin_warn_on_mismatch_message "FMR_ELAB-146 FMR_ELAB-149 FMR_VHDL-1002"
read_vhdl -container r -libname WORK -2008 { \
    ../src/vhdl_orig/apb_uart.vhd \
    ../src/vhdl_orig/slib_clock_div.vhd \
    ../src/vhdl_orig/slib_counter.vhd \
    ../src/vhdl_orig/slib_edge_detect.vhd \
    ../src/vhdl_orig/slib_fifo.vhd \
    ../src/vhdl_orig/slib_input_filter.vhd \
    ../src/vhdl_orig/slib_input_sync.vhd \
    ../src/vhdl_orig/slib_mv_filter.vhd \
    ../src/vhdl_orig/uart_baudgen.vhd \
    ../src/vhdl_orig/uart_interrupt.vhd \
    ../src/vhdl_orig/uart_receiver.vhd \
    ../src/vhdl_orig/uart_transmitter.vhd \
}
set_top r:/WORK/apb_uart
read_sverilog -container i -libname WORK -12 { \
    ../src/apb_uart.sv \
    ../src/slib_clock_div.sv \
    ../src/slib_counter.sv \
    ../src/slib_edge_detect.sv \
    ../src/slib_fifo.sv \
    ../src/slib_input_filter.sv \
    ../src/slib_input_sync.sv \
    ../src/slib_mv_filter.sv \
    ../src/uart_baudgen.sv \
    ../src/uart_interrupt.sv \
    ../src/uart_receiver.sv \
    ../src/uart_transmitter.sv \
}
set_top i:/WORK/apb_uart
match 
verify
report_hdlin_mismatches
analyze_points -all
quit
