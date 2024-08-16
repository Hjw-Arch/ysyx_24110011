#include <stdio.h>
#include <stdlib.h>
#include <memory.h>
#include <assert.h>
#include "verilated_vcd_c.h"
#include "Vtop.h"
#include "verilated.h"

int main (int argc, char **argv) {
    if (false && argc && argv) {}
    const std::unique_ptr<VerilatedContext> contextp{new VerilatedContext};
    std::unique_ptr<Vtop> top{new Vtop{contextp.get()}};
    contextp->commandArgs(argc, argv);
    contextp->traceEverOn(true);
    VerilatedVcdC* ftp = new VerilatedVcdC;
    top->trace(ftp, 0);
    ftp->open("wave.vcd");

    int flag = 0;

    while (!contextp->gotFinish() && ++flag < 20) {
        int a = rand() & 1;
        int b = rand() & 1;
        top->a = a;
        top->b = b;
        top->eval();
        printf("a = %d, b = %d, f = %d\n", a, b, top->f);
        assert(top->f == (a ^ b));

        contextp->timeInc(1);

        ftp->dump(contextp->time()); 
    }

    top->final();

    ftp->close();

    return 0;
}