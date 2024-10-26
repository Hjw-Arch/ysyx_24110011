#ifndef DIFFTEST_H
#define DIFFTEST_H

#include "config.h"
#include "log.h"
#include "macro.h"
#include "ram.h"

enum { DIFFTEST_TO_DUT, DIFFTEST_TO_REF };

void init_difftest(char *ref_so_file, long img_size, int port);
void difftest_step(vaddr_t pc);


#endif
