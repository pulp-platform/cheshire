set -euo pipefail
set -x

CHANNEL_BENCH_TOOLS=../../au-ts-time-protection/tools/channel-bench/
export PATH=$PATH:$CHANNEL_BENCH_TOOLS

LOGS=$1

sed -re '/^[0-9]+\s[0-9]+\s$/!d' "${LOGS}" > "${LOGS}.data.csv"
channel_matrix "${LOGS}.cm" < "${LOGS}.data.csv"
extract_plot "${LOGS}.cm" 1024 1024 > "${LOGS}.plot"

cat "${LOGS}.data.csv" | dos2unix | awk '{print "("$1","$2")"}' FS=" " > "${LOGS}.prepared"

plot.py "${LOGS}.plot" 0.01 "${LOGS}.png"
java -jar "${CHANNEL_BENCH_TOOLS}/leakiest-1.4.9.jar" -co -o "${LOGS}.prepared"
