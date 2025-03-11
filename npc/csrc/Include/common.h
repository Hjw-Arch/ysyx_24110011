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
    cpu.pc = dut.rootp->PC;  \
    for (int i = 0; i < 31; i++) {  \
        cpu.registerFile[i] = dut.rootp->ysyx__DOT__WBU_INTER__DOT__RF_INTER__DOT__register_file[i];    \
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
    cpu.pc = dut.rootp->PC;  \
    iringbuf_load(cpu.pc, dut.rootp->inst); \
} while(0) \

typedef MUXDEF(ISA64, uint64_t, uint32_t)   word_t;


#endif

