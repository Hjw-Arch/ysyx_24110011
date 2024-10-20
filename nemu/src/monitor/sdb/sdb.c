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
#include <cpu/cpu.h>
#include <readline/readline.h>
#include <readline/history.h>
#include "../include/memory/vaddr.h"
#include "../include/memory/paddr.h"
#include "sdb.h"

static int is_batch_mode = false;

void init_regex();
void init_wp_pool();

/* We use the `readline' library to provide more flexibility to read from stdin. */
static char *rl_gets() {
    static char *line_read = NULL;

    if (line_read) {
        free(line_read);
        line_read = NULL;
    }

    line_read = readline("(nemu) ");

    if (line_read && *line_read) {
        add_history(line_read);
    }

    return line_read;
}

// ringbuffer
typedef struct _ringbuf
{
    MUXDEF(CONFIG_RV64, uint64_t addr[16], uint32_t addr[16]);
    uint32_t inst[16];
}ringbuf;
static ringbuf iringbuf;
static uint32_t iringbuf_index = 0;

void iringbuf_load(MUXDEF(CONFIG_RV64, uint64_t addr, uint32_t addr), uint32_t inst) {
    if (iringbuf_index > 15) iringbuf_index = 0;
    iringbuf.addr[iringbuf_index] = addr;
    iringbuf.inst[iringbuf_index++] = inst;
}

void iringbuf_display() {
    uint32_t start_index = iringbuf_index;
    uint32_t end_index = iringbuf_index - 1;
    uint32_t index = start_index;
    puts("\n");
    while(1) {
        if (index > 15) index = 0;
        if (iringbuf.addr[index] == 0) {
            index++;
            continue;
        }

        printf("0x%08x: ", iringbuf.addr[index]);

        printf("%02x ", (iringbuf.inst[index] & 0xff000000) >> 24);
        printf("%02x ", (iringbuf.inst[index] & 0x00ff0000) >> 16);
        printf("%02x ", (iringbuf.inst[index] & 0x0000ff00) >> 8);
        printf("%02x       ",  (uint8_t)iringbuf.inst[index]);

#ifndef CONFIG_ISA_loongarch32r
        char disasm_buf[64];
        void disassemble(char *str, int size, uint64_t pc, uint8_t *code, int nbyte);
        disassemble(disasm_buf, 64, iringbuf.addr[index], (uint8_t *)&iringbuf.inst[index], 4);
        printf("%s\n", disasm_buf);
#else
        p[0] = '\0'; // the upstream llvm does not support loongarch32r
#endif
        
        if(index == end_index) break;
        index++;
    }
    puts("\n");
}

static int cmd_c(char *args) {
    cpu_exec(-1);
    return 0;
}

static int cmd_q(char *args) {
    nemu_state.state = NEMU_QUIT; // 8.19凌晨改动
    return -1;
}

// 实现单步运行
static int cmd_si(char *args) {
    char *num_p = strtok(args, " ");
    int num = (num_p == NULL) ? 1 : atoi(num_p);
    if (num > (0x7fffffff) || num < 0) {
        printf("The \"N\" is out of range, N ranges from 0 to 2,147,483,647\n");
        return 0;
    }

    for (int i = 0; i < num; ++i) {
        cpu_exec(1);
    }

    return 0;
}

// 实现打印寄存器/监视点
static int cmd_info(char *args) {
    char *next_arg = strtok(args, " ");
    if (next_arg == NULL) {
        printf("Missing parameter\n");
        return 0;
    }

    if (*next_arg == 'r') {
        isa_reg_display();
        return 0;
    }

    if (*next_arg == 'w') {
#ifdef CONFIG_WATCHPOINT
        diaplay_wp();
#endif
        return 0;
    }

    else {
        printf("Error parameter\n");
        return 0;
    }
    
    return 0;
}

// 实现内存扫描
static int cmd_x(char *args) {
    char *N = strtok(args, " ");
    if (N == NULL) {
        printf("Missing parameter\n");
        return 0;
    }

    char *EXPR = strtok(NULL, " ");
    if (EXPR == NULL) {
        printf("Missing parameter\n");
        return 0;
    }

    int expr_result;
    sscanf(EXPR + 2, "%x", &expr_result);

    if (expr_result > PMEM_RIGHT || expr_result < PMEM_LEFT) {
        printf("Start address is out of range of memory size!\n");
        return 0;
    }

    for (int i = 0; i < atoi(N); i++) {
        printf("0x%-10x", vaddr_read(expr_result, 4));
        if ((i + 1) % 11 == 0)
            printf("\n");
        expr_result += 4;
        if (expr_result > PMEM_RIGHT)
            return 0;
    }

    printf("\n");
    return 0;
}

static int cmd_w(char *args) {
#ifdef CONFIG_WATCHPOINT
    if (args == NULL) {
        printf("Missing parameter\n");
        return 0;
    }

    new_wp(args);
#else
    printf("Function \"Watchpoint\" is not enabled\n");
#endif
    return 0;
}

static int cmd_d(char *args) {
#ifdef CONFIG_WATCHPOINT
    if (args == NULL) {
        printf("Missing parameter\n");
        return 0;
    }

    int i = atoi(args);

    if (i < 0 || i > 32) {
        printf("%s is out of range from 0 to 32\n", args);
        printf(ANSI_FG_RED "^\n" ANSI_NONE);
        return 0;
    }

    free_wp(i);
#else
    printf("Function \"Watchpoint\" is not enabled\n");
#endif

    return 0;
}

char buf[100010];

static int cmd_test_expr(char *args) {
    if (args == NULL) {
        printf("Missing parameter\n");
        return 0;
    }

    FILE *fp = fopen("/home/hjw-arch/input.txt", "r");
    if (fp == NULL) {
        printf("Can not open the file\n");
        return 0;
    }

    int count = 0;

    while (fgets(buf, sizeof(buf), fp) != NULL) {

        char *result_str = strtok(buf, " ");
        uint32_t result = (uint32_t)atoll(result_str);
        char *expr_str = strtok(NULL, "\n");
        bool is_success = true;
        uint32_t result_test = expr(expr_str, &is_success);
        // if (result_test == result) {
        //     printf("test right\n");
        // }
        // else {
        //     printf("test error!\n");
        //     count++;
        //     printf("result:%s ", result_str);
        //     printf("result of turn: %u", result);
        //     printf("  result of sdb: %u", result_test);
        //     printf("\n\nexpr:\n%s\n\n\n\n\n\n\n\n", expr_str);
        //     FILE *fp = fopen("/home/hjw-arch/output1.txt", "a");
        //     if (fp == NULL) {
        //         assert(0);
        //     }
        //     fprintf(fp, "test_result: %u, sdb_result: %u\nexpr:\n%s\n\n", result, result_test, expr_str);
        //     fclose(fp);
        // }

        if (is_success)
        {
            if (result_test == result)
            {
                printf("test right\n");
            }
            else
            {
                printf("test error!\n");
                count++;
                printf("result:%s ", result_str);
                printf("result of turn: %u", result);
                printf("  result of sdb: %u", result_test);
                printf("\n\nexpr:\n%s\n\n\n\n\n\n\n\n", expr_str);
            }
        }
        else
        {
            printf("Bad expr or ZeroDivError\n");
            printf("result:%s ", result_str);
            printf("result of turn: %u", result);
            printf("  result of sdb: %u", result_test);
            printf("\n\nexpr:\n%s\n\n\n\n\n\n\n\n", expr_str);
            count++;
        }
    }
    printf("error times: %d\n", count);
    

    fclose(fp);

    return 0;
}

static int cmd_p(char *args) {
    if (args == NULL) {
        printf("Missing parameter\n");
        return 0;
    }

    uint32_t print_format = 0;
    char *expr_str = args;
    if ((*args == 'd' || *args == 'x' || *args == 'D' || *args == 'X')) {
        print_format = *args;
        strtok(NULL, " ");
        expr_str = strtok(NULL, "");
        if (expr_str == NULL) {
            printf("Missing parameter\n");
            return 0;
        }
    }

    bool is_success = true;
    uint32_t result = expr(expr_str, &is_success);

    if (is_success) {
        (print_format == 'x' || print_format == 'X') ? printf("0x%x\n", result) : printf("%d\n", result);
    }
    else {
        printf("Bad expression\n");
    }

    return 0;
}

static int cmd_help(char *args);

static struct {
    const char *name;
    const char *description;
    int (*handler)(char *);
} cmd_table[] = {
    {"help", "Display information about all supported commands", cmd_help},
    {"c", "Continue the execution of the program", cmd_c},
    {"q", "Exit NEMU", cmd_q},
    {"si", "si [N] | Let the program step through N instructions, the default N is 1", cmd_si},
    {"info", "info r/w | Print registers/watchpoints status", cmd_info},
    {"x", "x N EXPR | Evaluate the expression EXPR and use the result as the starting memory, output N consecutive 4 bytes in hexadecimal form", cmd_x},
    {"p", "p [d/x] EXPR | Evaluate the expression EXPR", cmd_p},
    {"w", "w EXPR | When the value of the expression EXPR changes, program execution is stopped", cmd_w},
    {"d", "d NO | Delete a watchpoint with serial number N", cmd_d},
    {"test_expr", "test expr", cmd_test_expr},
    /* TODO: Add more commands */

};

#define NR_CMD ARRLEN(cmd_table)

static int cmd_help(char *args) {
    /* extract the first argument */
    char *arg = strtok(NULL, " ");
    int i;

    if (arg == NULL) {
        /* no argument given */
        for (i = 0; i < NR_CMD; i++)
        {
            printf("%s - %s\n", cmd_table[i].name, cmd_table[i].description);
        }
    } else {
        for (i = 0; i < NR_CMD; i++) {
            if (strcmp(arg, cmd_table[i].name) == 0) {
                printf("%s - %s\n", cmd_table[i].name, cmd_table[i].description);
                return 0;
            }
        }
        printf("Unknown command '%s'\n", arg);
    }
    return 0;
}

void sdb_set_batch_mode() {
    is_batch_mode = true;
}

void sdb_mainloop() {
    if (is_batch_mode) {
        cmd_c(NULL);
        return;
    }

    for (char *str; (str = rl_gets()) != NULL;) {
        char *str_end = str + strlen(str);

        /* extract the first token as the command */
        char *cmd = strtok(str, " ");
        if (cmd == NULL) {
            continue;
        }

        /* treat the remaining string as the arguments,
         * which may need further parsing
         */
        char *args = cmd + strlen(cmd) + 1;
        if (args >= str_end) {
            args = NULL;
        }

#ifdef CONFIG_DEVICE
        extern void sdl_clear_event_queue();
        sdl_clear_event_queue();
#endif

        int i;
        for (i = 0; i < NR_CMD; i++) {
            if (strcmp(cmd, cmd_table[i].name) == 0) {
                if (cmd_table[i].handler(args) < 0) {
                    return;
                }
                break;
            }
        }

        if (i == NR_CMD) {
            printf("Unknown command '%s'\n", cmd);
        }
    }
}

void init_sdb()
{
    /* Compile the regular expressions. */
    init_regex();

    /* Initialize the watchpoint pool. */
    init_wp_pool();
}
