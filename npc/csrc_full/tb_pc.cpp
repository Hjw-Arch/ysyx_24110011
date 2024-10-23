#include <stdio.h>
#include <stdint.h>
#include <assert.h>
#include <Vpc.h>

static Vpc dut;

void eval_dut() {
    dut.clk = 0;
    dut.eval();
    dut.clk = 1;
    dut.eval();
}

int main() {
    dut.rst = 1;
    dut.adderASel = 1;
    dut.adderBSel = 1;
    dut.rs1Data = 0x80000008;
    dut.imm = 0x8;
    eval_dut();
    printf("rstValue: 0x%x\n", dut.PC);
    dut.rst = 0;

    int i = 0;
    
    uint32_t pc = 0x80000010;
    while(++i <= 20) {
        eval_dut();
        printf("newPC: 0x%x\n", dut.PC);
        assert(dut.PC == pc);
    }

    return 0;
}