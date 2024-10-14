#include <stdio.h>
#include <stdint.h>
#include <assert.h>
#include "Vtop.h"

Vtop dut;

void dut_cycle() {
    dut.clk = 0;
    dut.eval();
    dut.clk = 1;
    dut.eval();
}

void rst() {
    dut.rst = 1;
    dut_cycle();
    printf("RST PC = 0x%x\n", dut.pc);
    dut.rst = 0;
    dut.eval();
}

int main() {
    rst();
    for (int i = 0; i < 130; i++) {
        printf("PC = 0x%x, instruction = 0x%08x\nregister:\n", dut.pc, dut._inst);
        printf("InputA = 0x%08x, InputB = 0x%08x, extOP = %d, imm = 0x%08x, aluresult = 0x%08x\n", dut._inputA, dut._inputB, dut._extOP, dut._imm, dut._aluresult);
        printf("pcASel = %d, pcBsel = %d\n", dut._pcASel, dut._pcBSel);
        printf("ALUSel = 0x%x, rdaddr = %d, rddata = 0x%08x\n", dut._ALUCtrl, dut._rdaddr, dut._rddata);
        printf("ALUAsel = %d, ALUBSel = %d\n", dut._ALUASel, dut._ALUBSel);

        if (dut._inst == 0x00100073) return 0;

        dut_cycle();

        for (int k = 0; k < 32; k++) {
            printf("R%2d: 0x%08x\n", k, dut.rf[k]);
        }

        puts("");
        puts("");
    }
}