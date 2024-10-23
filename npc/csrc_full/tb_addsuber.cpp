#include <stdio.h>
#include <stdint.h>
#include <assert.h>
#include "Vaddsuber.h"

Vaddsuber dut;

int main() {
    for (uint32_t i = 0; i < 0xf0000000; i++) {
        for (uint32_t j = 0; j < 0xf0000000; j++) {
            for (int k = 0; k < 2; k++) {
                dut.input1 = i;
                dut.input2 = j;
                dut.add_or_sub = k;
                dut.eval();
                if (k) assert(dut.result == (i - j));
                else assert(dut.result == (i + j));
            }
        }
    }
}