#include "../Include/ram.h"
#include "../Include/log.h"
#include "Vysyx.h"

Vysyx dut;

void cycle() {
    dut.clk = 0;
    dut.eval();
    dut.clk = 1;
    dut.eval();
}

void rst() {
    dut.rst = 1;
    cycle();
    dut.rst = 0;
}

void display_npc() {
    for (int i = 0; i < 32; i++) {
        printf("R%d = 0x%x\n", i, dut.rf[i]);
    }
}

extern int end_flag;

int main(int argc, char *argv[]) {
//    Assert(argc == 2, "Error parameter.");
    // load image
    load_img(argv[1]);

    // reset
    rst();
    printf("111\n");
    int i = 0;
    while(i++<10) {
        printf("A = %x, B = %x\n", dut._pc_adderA_sel, dut._pc_adderB_sel);
        printf("PC = 0x%08x, instruction = 0x%08x\n", dut.PC, dut._inst);
        // printf("ALUCTRL = %x\n", dut._ALUCtrl);
        cycle();
        display_npc();
        puts("\n");
    }
}
