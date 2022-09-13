set BINARY /home/sem22f5/neo/neo-chip/sw/micro_tests/uart_minimal.elf

if {![info exists BINARY]} {
    puts "Set the \"BINARY\" variable before sourcing the start script"
    set BINARY ""
}

# vsim ${TESTBENCH} -t 1ps -voptargs=+acc +BINARY=$BINARY
#vsim cheshire -t 1ps -voptargs=+acc
# Suppress error of modules not having time specification
vsim tb_cheshire_soc -t 1ps -voptargs=+acc +BINARY=$BINARY -permissive -suppress 3009

set StdArithNoWarnings 1
set NumericStdNoWarnings 1

log -r *
run 1ms

