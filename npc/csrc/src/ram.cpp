#include "../Include/ram.h"
#include "../Include/log.h"
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

uint8_t pmem[RAM_SIZE];

extern Vysyx dut;

void *guset_to_host(uint32_t addr) {
    return ((uint8_t *)pmem + addr - RAM_START_ADDR);
}

int flag_read = 1;
int pmem_read(int addr, int len) {
    if (addr < RAM_START_ADDR || addr > RAM_END_ADDR) return 0;
    switch (len) {
        case 0: // 1
            return *(uint8_t *)guset_to_host(addr);
        case 1: // 2
            return *(uint16_t *)guset_to_host(addr);
        case 4:
        case 2: // 4
            return *(uint32_t *)guset_to_host(addr);
        
        default:
            return 0;
    }
}

int flag_write = 1;
void pmem_write(int addr, int data, int len) {
    if (flag_write == 1) {
        flag_write = 0;
        return;
    }
    Assert((addr <= RAM_END_ADDR) && (addr >= RAM_START_ADDR), "Addr 0x%08x transbordered the boundary.", addr);
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
