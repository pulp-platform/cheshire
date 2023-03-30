set TESTBENCH tb_cheshire_soc

set flags "-permissive -suppress 3009 -suppress 8386"

set pargs ""
if ([info exists BOOTMODE]) { append pargs "+BOOTMODE=${BOOTMODE} " }
if ([info exists PRELMODE]) { append pargs "+PRELMODE=${PRELMODE} " }
if ([info exists TESTMODE]) { append pargs "+TESTMODE=${TESTMODE} " }
if ([info exists BINARY])   { append pargs "+BINARY=${BINARY} " }
if ([info exists IMAGE])    { append pargs "+IMAGE=${IMAGE} " }

eval "vsim -c ${TESTBENCH} -t 1ps -voptargs=+acc" ${pargs} ${flags}

set StdArithNoWarnings 1
set NumericStdNoWarnings 1

log -r *
