#include "../Include/ram.h"
#include "../Include/log.h"
#include "../Include/sdb.h"
#include "../Include/cpu_exec.h"
#include "Vysyx___024root.h"
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

uint8_t pmem[RAM_SIZE];

extern Vysyx dut;

void *guset_to_host(uint32_t addr) {
    return ((uint8_t *)pmem + addr - RAM_START_ADDR);
}


int pmem_read(int addr, int len) {
    uint32_t ret = 0;
    switch (len) {
        case 0:  // 1
            ret = *(uint8_t *)guset_to_host(addr);
            break;

        case 1:  // 2
            ret = *(uint16_t *)guset_to_host(addr);
            break;

        case 4:
        case 2: 
            ret = *(uint32_t *)guset_to_host(addr);
            break;

        default:
            Assert(0, "Error len: %d", len);
            return 0;
    }

    IFDEF(CONFIG_MTRACE, mtrace_read(dut.rootp->ysyx__DOT__pc, len == 0 ? 1 : (len == 1 ? 2 : 4), ret, 0));

    return ret;
}


void pmem_write(int addr, int data, int len) {
    Assert((addr <= RAM_END_ADDR) && (addr >= RAM_START_ADDR), "Addr 0x%08x transbordered the boundary.", addr);
    IFDEF(CONFIG_MTRACE, mtrace_write(cpu.pc, len == 0 ? 1 : len == 1 ? 2 : 4, data, 0));

    switch (len) {
        case 0: // 1
            *(uint8_t *)guset_to_host(addr) = data;
            return;
        case 1: // 2
            *(uint16_t *)guset_to_host(addr) = data;
            return;
        case 2: // 4
            *(uint32_t *)guset_to_host(addr) = data;
            return;
        
        default:
            Assert(0, "pmem_write error, input 'len' is %d", len);
            return;
    }
}

// For DPI-C
static int flag = 1;
int fetch_inst(int pc) {
    if (flag == 1) {
        flag = 0;
        return 0;
    }
    uint32_t inst = pmem_read(pc, 4);
    return inst;
}
