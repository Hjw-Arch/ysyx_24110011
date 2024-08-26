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

/* We use the POSIX regex functions to process regular expressions.
 * Type 'man regex' for more information about POSIX regex functions.
 */
#include <regex.h>

enum
{
    TK_NOTYPE = 256,
    TK_EQ,
    TK_NUM,

    /* TODO: Add more token types */

};

static struct rule
{
    const char *regex;
    int token_type;
} rules[] = {

    /* TODO: Add more rules.
     * Pay attention to the precedence level of different rules.
     */

    {" +", TK_NOTYPE}, // spaces
    {"\\+", '+'},      // plus
    {"==", TK_EQ},     // equal
    {"\\-", '-'},      // sub
    {"\\*", '*'},      // mul
    {"/", '/'},        // div
    {"\\(", '('},      // (
    {"\\)", ')'},      // )
    {"[0-9]+", TK_NUM}, // 数字
};

#define NR_REGEX ARRLEN(rules)

static regex_t re[NR_REGEX] = {};

/* Rules are used for many times.
 * Therefore we compile them only once before any usage.
 */
void init_regex()
{
    int i;
    char error_msg[128];
    int ret;

    for (i = 0; i < NR_REGEX; i++)
    {
        ret = regcomp(&re[i], rules[i].regex, REG_EXTENDED); // 编译正则表达式
        if (ret != 0)
        {
            regerror(ret, &re[i], error_msg, 128);
            panic("regex compilation failed: %s\n%s", error_msg, rules[i].regex);
        }
    }
}

typedef struct token
{
    int type;
    char str[32];
} Token;

// static Token tokens[32] __attribute__((used)) = {};
// static int nr_token __attribute__((used)) = 0;
Token tokens[32] __attribute__((used)) = {};
int nr_token __attribute__((used)) = 0;

static bool make_token(char *e)
{
    int position = 0;
    int i;
    regmatch_t pmatch;

    nr_token = 0;

    while (e[position] != '\0')
    {
        /* Try all rules one by one. */
        for (i = 0; i < NR_REGEX; i++)
        {
            if (regexec(&re[i], e + position, 1, &pmatch, 0) == 0 && pmatch.rm_so == 0)
            {
                char *substr_start = e + position;
                int substr_len = pmatch.rm_eo;

                Log("match rules[%d] = \"%s\" at position %d with len %d: %.*s",
                    i, rules[i].regex, position, substr_len, substr_len, substr_start);

                position += substr_len;

                /* TODO: Now a new token is recognized with rules[i]. Add codes
                 * to record the token in the array `tokens'. For certain types
                 * of tokens, some extra actions should be performed.
                 */

                switch (rules[i].token_type)
                {
                case '+':
                case '-':
                case '*':
                case '/':
                case '(':
                case ')':
                    tokens[nr_token++].type = rules[i].token_type;
                    break;
                case TK_NUM:
                    tokens[nr_token].type = TK_NUM;
                    strncpy(tokens[nr_token++].str, substr_start, substr_len > 10 ? 10 : substr_len);
                    if ((substr_len > 10) || (atoll(tokens[nr_token - 1].str) > 4294967296))
                    {
                        printf("Number out of range\n");
                        printf("%-.*s\n", substr_len, substr_start);
                        printf(ANSI_FG_RED "%*.s^\n" ANSI_NONE, substr_len - 1, "");
                        return false;
                    }
                    break;
                case TK_NOTYPE:
                default:
                    break;
                }
                break;
            }
        }

        if (i == NR_REGEX)
        {
            printf("no match at position %d\n%s\n%*.s^\n", position, e, position, "");
            return false;
        }

    }

    return true;
}

// 检查表达式是否被括号包裹
bool check_parentheses(int p, int q) {
    if (!(tokens[p].type == '(' && tokens[q].type == ')')) {
        return false;
    }

    int num_left_parenthese = 0, num_right_parenthese = 0;
    for (int i = p + 1; i < q; i++) {
        if (tokens[i].type == '(') num_left_parenthese++;
        if (tokens[i].type == ')') num_right_parenthese++;
        if (num_right_parenthese > num_left_parenthese) return false;
        if (num_right_parenthese > 0) {
            num_left_parenthese--;
            num_right_parenthese--;
        }
    }
    if (num_left_parenthese != num_right_parenthese) return false;
    return true;
}

// 寻找主运算符
int search_for_main_operator(int p, int q) {
    int temp_op = 0;        // 若主运算符的位置出现在0，则表达式错误

    for (int i = p; i <= q; i++) {
        switch (tokens[i].type)
        {
        case '(':
            int left_parentheses = 1;
            int right_parentheses = 0;
            while(++i) {
                if (i > q) return 0;        // 遍历到末尾还没有找到匹配项，表达式错误！
                if (tokens[i].type == '(') left_parentheses++;  // 遍历到左括号，说明有嵌套括号，都不能要
                if (tokens[i].type == ')') right_parentheses++; // 遍历到右括号，消除与之匹配的左括号
                if (left_parentheses < right_parentheses) return 0; // 不可能出现左括号数量少于右括号，否则表达式错误！
                if (right_parentheses > 0) {    // 如果存在右括号，那么消除此右括号和与之匹配的左括号
                    left_parentheses--;
                    right_parentheses--;
                }
                if (left_parentheses == 0) {        // 如果左括号被消除完毕，说明完成括号匹配，可以退出
                    // ++i;
                    break;
                }
            }
            break;
        
        case ')':       // 先匹配到右括号，说明表达式错误
            return 0;

        case '+':       // + -为低优先级运算符，若发现不在括号中的+ -号可以直接返回这个+ -号
        case '-':
            return i;
        
        case '*':       // * /位高优先级运算符，若发现不在括号中的* /号，需要继续看后面是否还存在更低优先级的运算符
        case '/':
            temp_op = i;

        default:
            break;
        }
    }
    return temp_op;
}

long long int eval_expression(int p, int q, bool *is_bad_expr){
    if (p > q) {
        *is_bad_expr = true;
        return 0;
    } else if (p == q) {
        if (tokens[q].type == TK_NUM) {
            return atoll(tokens[q].str);
        } else {
            *is_bad_expr = true;
            return 0;
        }
    } else if (check_parentheses(p, q) == true) {
        return eval_expression(p + 1, q - 1, is_bad_expr);
    } else {
        int pos_op = search_for_main_operator(p, q);
        if (!pos_op) *is_bad_expr = true;
        long long int val1 = eval_expression(p, pos_op - 1, is_bad_expr);
        long long int val2 = eval_expression(pos_op + 1, q, is_bad_expr);

        switch (tokens[pos_op].type)
        {
        case '+':
            return val1 + val2;
            break;
        
        case '-':
            return val1 - val2;
            break;

        case '*':
            return val1 * val2;
            break;
        
        case '/':
            return val1 / val2;
            break;

        default:
            *is_bad_expr = true;
            return 0;
            break;
        }
    }
    return 0;
}

word_t expr(char *e, bool *success)
{
    if (!make_token(e))
    {
        *success = false;
        return 0;
    }

// 8.21测试代码
    printf("nr_tokens: %d\n", nr_token);
    for(int i = 0; i < nr_token; i++) {
        if (tokens[i].type < 256) {
            printf("%c", tokens[i].type);
        } else {
            printf("%s", tokens[i].str);
        }
        // if ((i + 1) % 11 == 0) puts("");
    }
    puts("");
    *success = true;
    return 0;

//测试代码结束

    /* TODO: Insert codes to evaluate the expression. */
    TODO();

    return 0;
}
