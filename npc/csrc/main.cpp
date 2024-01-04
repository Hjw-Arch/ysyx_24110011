#include <stdio.h>
#include <stdlib.h>
#include <memory>
#include <verilated.h>
#include <assert.h>
#include "Vtop.h"

double sc_time_stamp() { return 0; }

int main(int argc, char **argv) {
    // printf("Hello, ysyx!\n");

    if (false && argc && argv) {}

    Verilated::mkdir("logs");
    
    const std::unique_ptr<VerilatedContext> contextp{ new VerilatedContext };
    contextp->debug(0);
    contextp->randReset(2);
    contextp->traceEverOn(true);
    contextp->commandArgs(argc, argv);

    const std::unique_ptr<Vtop> top{new Vtop{contextp.get(), "TOP"}};
    int flag = 0;
    while (!contextp->gotFinish() && ++flag < 20) {
      contextp->timeInc(1);
      int a = rand() & 1;
      int b = rand() & 1;
      top->a = a;
      top->b = b;
      top->eval();
      //printf("a = %d, b = %d, f = %d\n", a, b, top->f);
      assert(top->f == (a ^ b));
    }
    top->final();

#if VM_COVERAGE
    Verilated::mkdir("logs");
    contextp->coveragep()->write("logs/coverage.dat");
#endif

  return 0;
}
