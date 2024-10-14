#include <stdio.h>
#include <stdint.h>
#include <assert.h>
#include "Vmux32_3_1.h"

Vmux32_3_1 dut;

int main() {
    for (uint32_t i = 0x80000000; i < 0x80000000 + 100; i++) {
        dut.input1 = i;
        dut.input2 = i + 100;
        dut.input3 = i + 200;
        for (int j = 0; j < 4; j++) {
            dut.s = j;
            dut.eval();
            assert(dut.result == ((j == 0) ? dut.input1 : (j == 1) ? dut.input2 : (j == 2) ? dut.input3 : 0));
        }
    }
}
