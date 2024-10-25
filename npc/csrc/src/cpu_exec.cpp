#include "../Include/sdb.h"
#include "../Include/common.h"
#include "../Include/cpu_exec.h"
#include "../Include/log.h"
#include "../Include/common.h"
#include "Vysyx___024root.h"

#define ebreak      0x00100073

#define min_num_to_disasm   10

cpu_t cpu;

enum {
    RUNNING = 0,
    IDLE,
};

uint32_t cpu_state = IDLE;

void halt() {
    cpu_state = IDLE;
    if (cpu.registerFile[10] != 0) {
        printf(ANSI_FG_RED "Hit bad trap" ANSI_NONE " at pc = 0x%08x\n", cpu.pc);
        return;
    } else {
        printf(ANSI_FG_GREEN "Hit good trap" ANSI_NONE " at pc = 0x%08x\n", cpu.pc);
        return;
    }
}

void cpu_exec_one() {
    cycle;
}

void cpu_exec(uint32_t n) {
    if (cpu_state == IDLE) {
        cpu_rst;
        cpu_state = RUNNING;
    }

    for (int i = 0; i < n; ++i) {
        
        if (n < min_num_to_disasm) {
            char p[64];
            printf("0x%08x: ", cpu.pc);
            for(int j = 3; j >= 0; j--) {
                printf("%02x ", ((uint8_t *)&dut.rootp->ysyx__DOT__inst)[j]);
            }
            disassemble(p, sizeof(p), cpu.pc, (uint8_t *)&dut.rootp->ysyx__DOT__inst, 4);
            printf("        %s\n", p);
        }

        iringbuf_load(cpu.pc, dut.rootp->ysyx__DOT__inst);

        // 执行一次
        cpu_exec_one();

        if (dut.rootp->ysyx__DOT__inst == ebreak) {
            Log("Get 'ebreak' instruction, program over.");
            halt();
            iringbuf_display();
            break;
        }

    }
}
