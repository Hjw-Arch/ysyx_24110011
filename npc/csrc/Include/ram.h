#ifndef RAM_H
#define RAM_H

#include "config.h"
#include "common.h"
#include "macro.h"
#include <stdint.h>
#include "Vysyx.h"
#include "Vysyx__Dpi.h"

#define RAM_START_ADDR  0x80000000
#define RAM_SIZE        0x8000000
#define RAM_END_ADDR    RAM_START_ADDR + RAM_SIZE - 1

#define RESET_VECTOR    RAM_START_ADDR + PC_RST_OFFSET

typedef word_t  vaddr_t;
typedef uint64_t  paddr_t;

void *guset_to_host(uint32_t addr);
int pmem_read(int addr, int len);
void pmem_write(int addr, int data, int len);

// For DPI-C
int fetch_inst(int pc);

#endif
