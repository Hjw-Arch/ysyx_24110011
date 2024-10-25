#include "../Include/sdb.h"
#include "../Include/common.h"
#include "../Include/cpu_exec.h"
#include "../Include/log.h"
#include "../Include/common.h"
#include "Vysyx___024root.h"

#define ebreak      0x00100073

cpu_t cpu;

enum {
    reset = 0,
    end,
};

static int cpu_state = reset;

void halt() {
    cpu_state = end;
    if (cpu.registerFile[10] != 0) {
        printf(ANSI_FG_RED "Hit bad trap" ANSI_NONE " at pc = 0x%08x\n", cpu.pc);
        return;
    } else {
        printf(ANSI_FG_GREEN "Hit good trap" ANSI_NONE " at pc = 0x%08x\n", cpu.pc);
        return;
    }
}

void cpu_exec_one() {
    cpu.pc = dut.rootp->ysyx__DOT__pc;
    cycle;
    for (int i = 0; i < 32; i++) {
        cpu.registerFile[i] = dut.rootp->ysyx__DOT___registerFile__DOT__registerFile[i];
    }
    if (dut.rootp->ysyx__DOT__inst == ebreak) {
        Log("Get 'ebreak' instruction, program over.");
        halt();
    }
}

void cpu_exec(uint32_t n) {
    cpu_rst;
    for (int i = 0; i < n; ++i) {
        cpu_exec_one();
        if (cpu_state == end) {
            break;
        }
    }
}
