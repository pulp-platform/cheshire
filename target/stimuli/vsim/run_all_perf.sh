#!/bin/bash

questa_cmd="questa-2022.3"
# Define an array of BINARY values, each on a new line
binary_root="/home/zexifu/embench-iot-baremetal/bd_cheshire_uart_baremetal/src"

# binaries=(
#     "aha-mont64"
#     "crc32"
#     "edn"
#     "huffbench"
#     "matmult-int"
#     "minver"
#     "nbody"
#     "nettle-aes"
#     "nettle-sha256"
#     "nsichneu"
#     "picojpeg"
#     "qrduino"
#     "sglib-combined"
#     "slre"
#     "st"
#     "statemate"
#     "ud"
#     "wikisort"
# )

# binaries=(
#     "wikisort"
# )

binaries=(
    "minver"
    "statemate"
    "wikisort"
)

# binary_root="/usr/scratch2/larain1/zexifu/cheshire_try_bak/cva6pp_gf22_cva6/working_dir/cheshire/sw/tests"
# binaries=(
#     "helloworld.spm.elf"
# )


# vcd_start_times=(
#     "438288000"
#     "470673000"
#     "492540000"
#     "840565000"
#     "576790000"
#     "434587000"
#     "433792000"
#     "523486000"
#     "447473000"
#     "441875000"
#     "1526749000"
#     "1481936000"
#     "600776000"
#     "476122000"
#     "446026000"
#     "434560000"
#     "435048000"
#     "1305063000"
# )

vcd_start_times=(
    "434587000"
    "434560000"
    "1305063000"
)


vcd_dur_times=(
    "2000ns"
    "2000ns"
    "2000ns"
    "2000ns"
    "2000ns"
    "2000ns"
    "2000ns"
    "2000ns"
    "2000ns"
    "2000ns"
    "2000ns"
    "2000ns"
    "2000ns"
    "2000ns"
    "2000ns"
    "2000ns"
    "2000ns"
    "2000ns"
    "2000ns"
)

# Loop through each BINARY value and start a QuestaSim process
for i in "${!binaries[@]}"; do
    export BINARY=${binaries[$i]}
    export BINARY_PATH=${binary_root}/${binaries[$i]}/${binaries[$i]}
    # export BINARY_PATH=${binary_root}/${binaries[$i]}
    # export VCD_START=${vcd_start_times[$i]}
    export VCD_START=${vcd_start_times[$i]}
    export VCD_DUR=${vcd_dur_times[$i]}

    mkdir -p "work_${binaries[$i]}"
    cp compile.cheshire_soc.tcl work_${binaries[$i]}
    cp start.cheshire_soc.tcl work_${binaries[$i]}

    # # multi gui mode
    # cd work_${binaries[$i]} && \
    # xterm -hold -e "${questa_cmd} vsim -do ../../../stimuli/vsim/run.tcl" &

    # # not used
    # cd work_${binaries[$i]} && \
    # ${questa_cmd} vsim -do ../../stimuli/vsim/run.tcl &
    
    # bash mode
    ${questa_cmd} vsim -do ../../stimuli/vsim/run.tcl &

    # # single gui mode
    # ${questa_cmd} vsim -do ../../stimuli/vsim/run.tcl
done

# Wait for all background processes to complete
wait
