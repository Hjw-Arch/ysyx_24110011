#include <stdio.h>
#include <stdint.h>
#include <assert.h>

#include "Vram.h"

Vram dut;

void dut_cycle() {
    dut.clk = 0;
    dut.eval();
    dut.clk = 1;
    dut.eval();
}

int main() {
    dut.we = 1;

    for (uint32_t i = 0x80000000; i < 0x90000000; i = i + 4) {
        dut.in_data = i;
        dut.in_addr = i;
        dut_cycle();

    }

    dut.we = 0;
    dut_cycle();

    for (uint32_t i = 0x80000000; i < 0x90000000; i = i + 4) {
        dut.out_inst_addr = i;
        dut.out_data_addr = i;
        dut.eval();
        printf("inst = 0x%x, data = 0x%x\n", dut.out_inst, dut.out_data);
        assert(dut.out_inst == dut.out_data && dut.out_data == i);
    }
}