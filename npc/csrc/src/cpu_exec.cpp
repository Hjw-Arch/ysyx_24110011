#include "../Include/sdb.h"
#include "../Include/common.h"
#include "../Include/cpu_exec.h"
#include "../Include/log.h"
#include "../Include/common.h"
#include "Vysyx___024root.h"
#include "../Include/difftest.h"

#define ebreak      0x00100073

#define min_num_to_disasm   10

#define FTRACE_RECORD     record_ftrace(old_pc, old_inst == 0x8067 ? 1 : 0, cpu.pc)

cpu_t cpu;

uint32_t cpu_state = RUNNING;

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

    if (dut.rootp->ysyx__DOT__inst == ebreak) {
        Log("Get 'ebreak' instruction, program over.");
        halt();
    }
}

void cpu_exec(uint32_t n) {
    if (cpu_state == IDLE) {
        Log("Program has over, if you want to restart, please enter 'q' and then restart again.");
        return;
    }

    for (int i = 0; i < n; ++i) {

#if defined(CONFIG_FTRACE) || defined(CONFIG_WATCHPOINT) || defined(CONFIG_DIFFTEST)
        vaddr_t old_pc = cpu.pc;
        word_t old_inst = dut.rootp->ysyx__DOT__inst;
#endif
        
        if (n < min_num_to_disasm) {
            char p[64];
            printf("0x%08x: ", cpu.pc);
            for(int j = 3; j >= 0; j--) {
                printf("%02x ", ((uint8_t *)&dut.rootp->ysyx__DOT__inst)[j]);
            }
            disassemble(p, sizeof(p), cpu.pc, (uint8_t *)&dut.rootp->ysyx__DOT__inst, 4);
            printf("        %s\n", p);
        }

        // 执行一次
        cpu_exec_one();


        iringbuf_load(cpu.pc, dut.rootp->ysyx__DOT__inst);

        IFDEF(CONFIG_FTRACE, FTRACE_RECORD);
        IFDEF(CONFIG_WATCHPOINT, diff_wp(old_pc));
        IFDEF(CONFIG_DIFFTEST, difftest_step(old_pc));

        if (cpu_state != RUNNING) {
            switch (cpu_state) {
                case IDLE:
                    iringbuf_display();
                    break;
                case STOPPED:
                    break;
            }
            return;
        }
    }
}
