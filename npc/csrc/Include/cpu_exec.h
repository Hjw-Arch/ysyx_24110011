#ifndef CPU_EXEC_H
#define CPU_EXEC_H

#include <stdint.h>
#include "ram.h"
#include "config.h"

typedef struct _cpu
{
    word_t registerFile[32];
    word_t pc;
}cpu_t;

extern cpu_t cpu;   // CPU Info

void cpu_exec(uint32_t n);


#endif

