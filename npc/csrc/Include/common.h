#ifndef COMMON_H
#define COMMON_H

#include "macro.h"
#include <stdint.h>

#define cycle  \
do { \
    dut.clk = 0;    \
    dut.eval();     \
    dut.clk = 1;    \
    dut.eval();     \
} while(0) \



#define cpu_rst \
do {    \
    dut.rst = 1;    \
    cycle;          \
    dut.rst = 0;    \
} while(0) \

typedef MUXDEF(ISA64, uint64_t, uint32_t)   word_t;


#endif

