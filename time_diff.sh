#!/bin/sh
directory="$1"

totaltime=$(echo "scale=3; $(cat "$1"/endtime.txt) - $(cat "$1"/starttime.txt)" | bc)
runtime=$(echo "scale=3; $(cat "$1"/endtime.txt) - $(cat "$1"/launchtime.txt)" | bc)
totalcycle=$(echo "$(cat "$1"/endcycle.txt) - $(cat "$1"/startcycle.txt)" | bc)
runcycle=$(echo "$(cat "$1"/endcycle.txt) - $(cat "$1"/launchcycle.txt)" | bc)

totalrate=$(echo "scale=3; $totalcycle / $totaltime / 1000" | bc)
runrate=$(echo "scale=3; $runcycle / $runtime / 1000" | bc)

echo "Total: $totaltime sec, $totalcycle cycles, $totalrate kHz"
echo "Run:   $runtime sec, $runcycle cycles, $runrate kHz"
