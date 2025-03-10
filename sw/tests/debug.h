// Copyright 2023 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Nicole Narr <narrn@student.ethz.ch>
// Christopher Reinwardt <creinwar@student.ethz.ch>
//
// Debug utility

#pragma once

#ifdef DEBUG
#include "printf.h"
#define debugf(x...) printf(x)
#else
#define debugf(x...)
#endif

