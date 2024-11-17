#include <am.h>
#include <riscv/riscv.h>
#include <klib.h>

static Context* (*user_handler)(Event, Context*) = NULL;

Context* __am_irq_handle(Context *c) {
  if (user_handler) {
    Event ev = {0};
    switch (c->mcause) {
      case 11:
        ev.event = EVENT_YIELD; break;
      default: ev.event = EVENT_ERROR; break;
    }

    c = user_handler(ev, c);
    assert(c != NULL);
  }

  return c;
}

extern void __am_asm_trap(void);

bool cte_init(Context*(*handler)(Event, Context*)) {
  // initialize exception entry
  asm volatile("csrw mtvec, %0" : : "r"(__am_asm_trap));

  // register event handler
  user_handler = handler;

  return true;
}

// #include "../arch/riscv.h"
#include ARCH_H

#define CONTEXT_SIZE  ((NR_REGS + 3) * 4)

Context *kcontext(Area kstack, void (*entry)(void *), void *arg) {
  // Context *ptr = kstack.start;
  uint8_t *end = kstack.end;
  Context *context = (Context *)(end - sizeof(Context));
  
  for (int i = 0; i < NR_REGS; i++) {
    context->gpr[i] = 0;
  }

  // context->gpr[2] = (uintptr_t)end;    // 栈指针

  context->mepc = (uintptr_t)entry;
  // context_pos->mcause = 0;
  context->mstatus = 0x1800;

  // context->pdir = arg;

  *(uint32_t *)(kstack.start) = (uint32_t)context;

  return context;
}

void yield() {
#ifdef __riscv_e
  asm volatile("li a5, -1; ecall");
#else
  asm volatile("li a7, -1; ecall");
#endif
}

bool ienabled() {
  return false;
}

void iset(bool enable) {
}
