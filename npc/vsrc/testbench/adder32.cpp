#include <stdio.h>
#include <Vadder32.h>
#include <Vadder32___024root.h>
#include <assert.h>
#include <stdint.h>

Vadder32 dut;

int main() {
    for (uint32_t i = 0xffffffff; i > 0xfffff000; i--) {
        for (uint32_t j = 0xffffffff; j > 0xfffff000; j--) {
            dut.a = i;
            dut.b = j;
            dut.cin = 0;
            dut.eval();
            assert(dut.result == i + j);
        }
    }

    return 0;
}