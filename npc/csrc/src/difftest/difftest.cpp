#include <stdio.h>
#include <stdint.h>
#include <dlfcn.h>
#include "../Include/common.h"
#include "../Include/cpu_exec.h"
#include "../Include/difftest.h"
#include "../Include/ram.h"
#include "../Include/sdb.h"

void (*difftest_memcpy)(vaddr_t addr, void *buf, size_t n, bool direction) = NULL;
void (*difftest_regcpy)(void *dut, bool direction) = NULL;
void (*difftest_exec)(uint64_t n) = NULL;
void (*difftest_raise_intr)(uint64_t NO) = NULL;

void init_difftest(char *ref_so_file, long img_size, int port) {
  assert(ref_so_file != NULL);

  void *handle;
  handle = dlopen(ref_so_file, RTLD_LAZY);
  assert(handle);

  difftest_memcpy = (void (*)(vaddr_t, void *, size_t, bool))dlsym(handle, "difftest_memcpy");
  assert(difftest_memcpy);

  difftest_regcpy = (void (*)(void *dut, bool direction))dlsym(handle, "difftest_regcpy");
  assert(difftest_regcpy);

  difftest_exec = (void (*)(uint64_t n))dlsym(handle, "difftest_exec");
  assert(difftest_exec);

  difftest_raise_intr = (void (*)(uint64_t NO))dlsym(handle, "difftest_raise_intr");
  assert(difftest_raise_intr);

  void (*difftest_init)(int) = (void (*)(int))dlsym(handle, "difftest_init");
  assert(difftest_init);

  Log("Differential testing: %s", ANSI_FMT("ON", ANSI_FG_GREEN));
  Log("The result of every instruction will be compared with %s. "
      "This will help you a lot for debugging, but also significantly reduce the performance. "
      "If it is not necessary, you can turn it off in menuconfig.", ref_so_file);

  difftest_init(port);
  difftest_memcpy(RESET_VECTOR, guest_to_host(RESET_VECTOR), img_size, DIFFTEST_TO_REF);
  difftest_regcpy(&cpu, DIFFTEST_TO_REF);
}

static bool difftest_checkregs(cpu_t *ref) {
    int flag = 0;
    for (int i = 0; i < 32; i++) {
        if (ref->registerFile[i] != cpu.registerFile[i]) {
            printf("ref->reg[%d] = 0x%08x---------npc->reg[%d] = 0x%08x\n", i, ref->registerFile[i], i, cpu.registerFile[i]);
            flag = 1;
        }
    }

    if (ref->pc != cpu.pc) {
        printf("ref->pc = 0x%08x---------npc->pc = 0x%08x\n", ref->pc, cpu.pc);
        flag = 1;
    }

    return flag == 1 ? false : true;
}


static void checkregs(cpu_t *ref, vaddr_t pc) {
  if (!difftest_checkregs(ref)) {
    cpu_state = IDLE;
    printf("There has different state at pc = 0x%08x\n", pc);
  }
}

void difftest_step(vaddr_t pc) {
    cpu_t ref_info;
    difftest_exec(1);
    difftest_regcpy(&ref_info, DIFFTEST_TO_DUT);
    checkregs(&ref_info, pc);
}

