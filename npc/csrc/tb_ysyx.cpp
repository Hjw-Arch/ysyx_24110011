#include <stdio.h>
#include <stdint.h>
#include <assert.h>
#include "Vysyx.h"

#include "svdpi.h"
#include "Vysyx__Dpi.h"

Vysyx dut;


// For DPI-C, an analog memory
uint8_t pmemory[] = {
    0x13, 0x00, 0xf0, 0xff,
    0x93, 0x00, 0xf0, 0xff,
    0x13, 0x01, 0xf0, 0xff,
    0x93, 0x01, 0xf0, 0xff,
    0x83, 0x00, 0x10, 0x00
};


int flag = 1;
int fetch_inst(int pc) {
    if (flag) {
        flag = 0;
        return 0;
    }
    uint32_t inst = *(uint32_t *)((uint8_t *)pmemory + (pc - 0x80000000));
    return inst;
}

void dut_cycle() {
    dut.clk = 0;
    dut.eval();
    dut.clk = 1;
    dut.eval();
}

void dut_rst() {
    dut.rst = 1;
    dut_cycle();
    dut.rst = 0;
}

int main() {
    dut_rst();
    printf("RST_PC = 0x%08x\n", dut.PC);
    while(1) {
        printf("PC = 0x%08x, Instruction = 0x%08x\n", dut.PC, dut._inst);
        dut_cycle();
        printf("RegisterFile: \n");
        for (int i = 0; i < 32; i++) {
            printf("R%2d = 0x%08x\n", i, dut.rf[i]);
        }

        puts("\n");

        if (dut._inst == 0x00100083) {
            if (dut.rf[1] == 0) exit(0);
            else exit(-1);
        }
    }
}
