/***************************************************************************************
* Copyright (c) 2014-2022 Zihao Yu, Nanjing University
*
* NEMU is licensed under Mulan PSL v2.
* You can use this software according to the terms and conditions of the Mulan PSL v2.
* You may obtain a copy of Mulan PSL v2 at:
*          http://license.coscl.org.cn/MulanPSL2
*
* THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
* EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
* MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
*
* See the Mulan PSL v2 for more details.
***************************************************************************************/

#include <isa.h>
#include <cpu/difftest.h>
#include "../local-include/reg.h"

bool flag = true;

bool isa_difftest_checkregs(CPU_state *ref_r, vaddr_t pc) {
  for (int i = 0; i < 32; i++) {
    if (ref_r->gpr[i] != cpu.gpr[i]) {
      printf("ref->reg[%d] = 0x%08x---------nemu->reg[%d] = 0x%08x\n", i, ref_r->gpr[i], i, cpu.gpr[i]);
      flag = false;
    }
  }
  if (cpu.pc != ref_r->pc) {
    printf("ref->pc = 0x%08x---------nemu->pc = 0x%08x\n", ref_r->pc, cpu.pc);
    flag = false;
  }

  if (!flag) nemu_state.halt_pc = pc, nemu_state.state = NEMU_ABORT;
  return flag;
}

void isa_difftest_attach() {
}
