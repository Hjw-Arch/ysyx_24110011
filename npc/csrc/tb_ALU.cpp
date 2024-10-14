#include <stdio.h>
#include <assert.h>
#include <stdint.h>
#include "VALU.h"

VALU dut;

int a[3] = {1, 5, 13};

// 1, 5, 13
int main()
{
    // 测试移位
    for (uint32_t i = 0x7ff00000; i < 0x80000fff; i++) {
        for (int j = 0; j < 32; j++) {
            for (int k = 0; k < 3; k++) {
                dut.ctrl = a[k];
                dut.input1 = i;
                dut.input2 = j;
                dut.eval();
                if (k == 0) {
                    assert(dut.result == (i << j));
                    break;
                }

                if (k == 1) {
                    assert(dut.result == (i >> j));
                    break;
                }

                if (k == 2) {
                    assert(dut.result == (int(i) >> j));
                    break;
                }
            }
        }
    }

    // for (uint32_t i = 0xffffff00; i < 0xffffffff; i++)
    // {
    //     for (uint32_t j = 0xffffff00; j < 0xffffffff; j++)
    //     {
    //         for (int k = 0; k < 16; k++)
    //         {
    //             dut.input1 = i;
    //             dut.input2 = j;
    //             dut.ctrl = k;
    //             dut.eval();


    //             if (k == 0)
    //             {
    //                 assert(dut.result == (dut.input1 + dut.input2));
    //                 break;
    //             }

    //             if (k == 2)
    //             {
    //                 assert(dut.result == ((int)dut.input1 < (int)dut.input2));
    //                 break;
    //             }

    //             if (k == 3)
    //             {
    //                 assert(dut.result == (dut.input2));
    //                 break;
    //             }

    //             if (k == 4)
    //             {
    //                 assert(dut.result == (dut.input1 ^ dut.input2));
    //                 break;
    //             }

    //             if (k == 6)
    //             {
    //                 assert(dut.result == (dut.input1 | dut.input2));
    //                 break;
    //             }

    //             if (k == 7)
    //             {
    //                 assert(dut.result == (dut.input1 & dut.input2));
    //                 break;
    //             }

    //             if (k == 8)
    //             {
    //                 assert(dut.result == ((int)dut.input1 - (int)dut.input2));
    //                 break;
    //             }

    //             if (k == 10)
    //             {
    //                 assert(dut.result == (dut.input1 < dut.input2));
    //                 break;
    //             }

    //             if (k == 1 || k == 5 || k == 13)
    //                 break;

    //             assert(dut.result == 0);
    //         }
    //     }
    // }
}