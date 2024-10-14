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
    for (int i = 0; i < 5; i++) {
        printf("PC = 0x%x, instruction = 0x%08x\nregister:\n", dut.pc, dut._inst);
        dut_cycle();

        for (int k = 0; k < 32; k++) {
            printf("R%2d: 0x%08x\n", k, dut.rf[k]);
        }

        puts("");
        puts("");
    }
}