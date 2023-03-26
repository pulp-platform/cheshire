set TESTBENCH tb_cheshire_soc

vsim -c $TESTBENCH -t 1ps -voptargs=+acc -permissive -suppress 3009 -suppress 8386

set StdArithNoWarnings 1
set NumericStdNoWarnings 1

log -r *
