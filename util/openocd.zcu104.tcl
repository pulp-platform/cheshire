# Abdelkadir Chantar <abdelkadir.chantar@tuni.fi>

adapter driver ftdi
adapter serial FT5X1XMQ; 

adapter speed 1000
ftdi vid_pid 0x0403 0x6010
ftdi layout_init 0x0088 0x008b
ftdi channel 1
set irlen 5

source [file dirname [info script]]/openocd.common.tcl



