#!/bin/bash
# Copyright (c) 2014-2020 ETH Zurich, University of Bologna
#
# Copyright and related rights are licensed under the Solderpad Hardware
# License, Version 0.51 (the "License"); you may not use this file except in
# compliance with the License.  You may obtain a copy of the License at
# http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
# or agreed to in writing, software, hardware and materials distributed under
# this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
# CONDITIONS OF ANY KIND, either express or implied. See the License for the
# specific language governing permissions and limitations under the License.
#
# Fabian Schuiki      <fschuiki@iis.ee.ethz.ch>
# Andreas Kurth       <akurth@iis.ee.ethz.ch>
# Wolfgang Roenninger <wroennin@ethz.ch>

set -e
ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)

[ ! -z "$VSIM" ] || VSIM=vsim

call_vsim() {
	echo "run -all" | $VSIM "$@" | tee vsim.log 2>&1
	grep "Errors: 0," vsim.log
}

call_vsim tb_apb_regs -64 -t 1ns -coverage -lib work -voptargs="+acc +cover=bcesfx"
