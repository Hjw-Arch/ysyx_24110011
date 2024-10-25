#ifndef CONFIG_H
#define CONFIG_H

#define ISA32             1
#define PC_RST_OFFSET     0x0

#define __GUEST_ISA__     RISCV32
#define RV32
#define CONFIG_RVE
// #define RV64

#define CONFIG_WATCHPOINT

// trace
#define CONFIG_TRACE
#define CONFIG_MTRACE
#define CONFIG_FTRACE


#endif
