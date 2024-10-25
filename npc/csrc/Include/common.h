#ifndef COMMON_H
#define COMMON_H

#include "macro.h"
#include <stdint.h>

#define cycle  \
do { \
    cpu.pc = dut.rootp->ysyx__DOT__pc;  \
    dut.clk = 0;    \
    dut.eval();     \
    dut.clk = 1;    \
    dut.eval();     \
    for (int i = 0; i < 32; i++) {  \
        cpu.registerFile[i] = dut.rootp->ysyx__DOT___registerFile__DOT__registerFile[i];    \
    }   \
} while(0) \



#define cpu_rst \
do {    \
    dut.rst = 1;    \
    dut.clk = 0;    \
    dut.eval();     \
    dut.clk = 1;    \
    dut.eval();     \
    dut.rst = 0;    \
    cpu.pc = dut.rootp->ysyx__DOT__pc;  \
} while(0) \

typedef MUXDEF(ISA64, uint64_t, uint32_t)   word_t;


#endif

