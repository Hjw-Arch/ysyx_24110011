#include <stdio.h>
#include <assert.h>
#include "VALUMux11_1.h"

VALUMux11_1 dut;

int main() {
    for (int i = 0; i < 8; i++) {
        dut.inData[i] = i + 1;
    }

    for (int i = 0; i < 16; i++) {
        dut.sel = i;
        dut.eval();
        if (i <= 4) {
            assert(dut.result == i + 1);
            break;
        }

        if (i == 5) {
            assert(dut.result == 2);
            break;
        }

        if (i == 6) {
            assert(dut.result == 6);
            break;
        }

        if (i == 7) {
            assert(dut.result == 7);
            break;
        }

        if (i == 8) {
            assert(dut.result == 1);
            break;
        }

        if (i == 10) {
            assert(dut.result == 8);
            break;
        }

        if (i == 13) {
            assert(dut.result == 2);
            break;
        }

        assert(dut.result == 0);
    } 
}