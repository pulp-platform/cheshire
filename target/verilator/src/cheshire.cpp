// Licensed to the Apache Software Foundation (ASF) under one
// or more contributor license agreements.  See the NOTICE file
// distributed with this work for additional information
// regarding copyright ownership.  The ASF licenses this file
// to you under the Apache License, Version 2.0 (the
// "License"); you may not use this file except in compliance
// with the License.  You may obtain a copy of the License at

//   http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

// #include "verilator.h"
//#include "elfloader.h"
#include "verilated.h"
#include "Vcheshire_testharness.h"
#include <verilated_vcd_c.h>
#if (VERILATOR_VERSION_INTEGER >= 5000000)
  // Verilator v5 adds $root wrapper that provides rootp pointer.
  #include "Vcheshire_testharness___024root.h"
#endif

// #include <fesvr/dtm.h>
#include <fesvr/htif_hexwriter.h>
#include <fesvr/elfloader.h>
#include <string>
#include <cstring>
#include <cassert>
#include <stdio.h>
#include <iostream>
#include <iomanip>
#include <string>
#include <getopt.h>
#include <chrono>
#include <ctime>
#include <signal.h>
#include <unistd.h>

// This software is heavily based on Rocket Chip
// Checkout this awesome project:
// https://github.com/freechipsproject/rocket-chip/


// This is a 64-bit integer to reduce wrap over issues and
// allow modulus.  You can also use a double, if you wish.
static vluint64_t main_time = 0;
int clk_ratio = 2;

static void cycle_start(std::shared_ptr<Vcheshire_testharness> top){
  top->rtc_i = 1;
  top->jtag_tck = 1;
  for (int i = 0; i < clk_ratio; i++){
    top->clk_i = 1;
    top->rtc_i = 1;
    printf("tick\n");
    top->eval();
    main_time += 2500;
    top->clk_i = 0;
    top->rtc_i = 0;
    top->eval();
    main_time += 2500;
  }
}

static void cycle_end(std::shared_ptr<Vcheshire_testharness> top){
  top->rtc_i = 0;
  for (int i = 0; i < clk_ratio; i++){
    top->clk_i = 1;
    top->rtc_i = 1;
    top->eval();
    main_time += 2500;
    top->clk_i = 0;
    top->rtc_i = 0;
    top->eval();
    main_time += 2500;
  }
}

static void wait_cycles(std::shared_ptr<Vcheshire_testharness> top, 
                        int cycles){
  for(int i = 0; i < cycles; i++){
      cycle_start(top);
      cycle_end(top);
  }
}


int main(int argc, char **argv) {

  Verilated::commandArgs(argc, argv);
  std::shared_ptr<Vcheshire_testharness> top(new Vcheshire_testharness);

  // reset 
  for (int i = 0; i < 10; i++) {
    top->rst_ni = 0;
    top->rtc_i = 0;
    wait_cycles(top, 5);
  }
  top->rst_ni = 1;

  top->final();

  return 0;
}