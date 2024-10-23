#include <stdio.h>
#include "VRegisterFile.h"
#include <assert.h>

VRegisterFile dut;

void dut_cycle() {
    dut.clk = 0;
    dut.eval();
    dut.clk = 1;
    dut.eval();
}

int main() {
    dut.writeEnable = 1;
    for (int i = 0; i < 32; i++) {
        dut.rdAddr = i;
        dut.rdData = 0xffffffff;
        dut_cycle();
    }

    for (int i = 0; i < 32; i++) {
        dut.rs1Addr = i;
        dut.rs2Addr = i;
        dut_cycle();
        printf("rs1 = 0x%x   rs2 = 0x%x\n", dut.rs1Data, dut.rs2Data);
    }
}