#pragma once

#ifdef DEBUG
#include "printf.h"
#define debugf(x...) printf(x)
#else
#define debugf(x...)
#endif

