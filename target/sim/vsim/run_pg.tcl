source compile.cheshire_soc.tcl
set BOOTMODE 0
set PRELMODE 0
set BINARY ../../../sw/tests/2d_dma.spm.elf
set VOPTARGS "+acc"

source start.cheshire_soc.tcl

log -r /*
