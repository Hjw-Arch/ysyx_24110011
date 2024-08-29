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

#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <assert.h>
#include <string.h>

// this should be enough
static char buf[65536] = {};
static char code_buf[65536 + 128] = {}; // a little larger than `buf`
static char *code_format =
    "#include <stdio.h>\n"
    "int main() { "
    "  unsigned long long int result = %s; "
    "  printf(\"%%ulld\", result); "
    "  return 0; "
    "}";

static uint32_t choose(uint32_t n) {
    return (uint32_t)(rand() % n);
}

uint32_t pos_buf = 0;

static int countBits(uint32_t num) {
    int count = 0;

    while (num > 0)
    {
        num /= 10;
        count++;
    }

    return count;
    
}

static void gen_num() {
    uint32_t rand32 = (uint32_t)(rand() << 16 | rand());
    sprintf(buf + pos_buf, "%u", rand32);

    int rand_blank = choose(3);
    int count_bits = countBits(rand32);

    pos_buf += count_bits;

    sprintf(buf+pos_buf, "%*s", rand_blank, "");
    pos_buf += rand_blank;
}

static void gen(const char str) {
    sprintf(buf + pos_buf, "%c", str);
    pos_buf++;
    int rand_blank = choose(3);
    sprintf(buf+pos_buf, "%*s", rand_blank, "");
    pos_buf += rand_blank;
}

static void gen_rand_op() {
    switch (choose(4))
    {
    case 0:
        gen('+');
        break;
    
    case 1:
        gen('-');
        break;

    case 2:
        gen('*');
        break;

    case 3:
        gen('/');
        break;

    default:
        printf("error!\n");
        break;
    }
}

static void gen_rand_expr(int n)
{
    if (n >= 100) {
        gen_num();
        return;
    }

    switch (choose(3))
    {
    case 0:
        gen_num();
        break;

    case 1:
        gen('(');
        gen_rand_expr(++n);
        gen(')');
        break;

    default:
        gen_rand_expr(++n);
        gen_rand_op();
        gen_rand_expr(++n);
        break;
    }

}

int main(int argc, char *argv[])
{
    int seed = time(0);
    srand(seed);
    int loop = 1;
    if (argc > 1)
    {
        sscanf(argv[1], "%d", &loop);
    }
    int i;
    for (i = 0; i < loop; i++)
    {
        pos_buf = 0;

        gen_rand_expr(1);

        sprintf(code_buf, code_format, buf);

        FILE *fp = fopen("/tmp/.code.c", "w");
        assert(fp != NULL);
        fputs(code_buf, fp);
        fclose(fp);

        int ret = system("gcc -w /tmp/.code.c -o /tmp/.expr");
        if (ret != 0)
            continue;

        fp = popen("/tmp/.expr", "r");
        assert(fp != NULL);

        uint32_t result;
        ret = fscanf(fp, "%u", &result);
        uint64_t result_ll;
        fscanf(fp, "%ulld", &result_ll);
        int status = pclose(fp);

        if (result_ll > 4294967296) {
            continue;
        }

        if (status != 0) {
            continue;
        }

        printf("%u %s\n", result, buf);
    }
    return 0;
}