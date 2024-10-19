#include <am.h>
#include <klib.h>
#include <klib-macros.h>
#include <stdarg.h>

#if !defined(__ISA_NATIVE__) || defined(__NATIVE_USE_KLIB__)

static int num2string(char **out, int num, int base) {
    int ret = 0;
    // process negative number
    if (num < 0) {
        *((*out)++) = '-';
        num = -num;
        ret++;
    }

    // process zero
    if (num == 0) {
        *((*out)++) = '0';
        return 1;
    }


    int a[20];
    int i = 0;
    while(num != 0) {
        a[i++] = num % base;
        num /= base;
    }

    while(i > 0) {
        *((*out)++) = (char)(a[--i] + '0');
        ret++;
    }

    return ret;
}

int printf(const char *fmt, ...) {
    panic("Not implemented");
}

int vsprintf(char *out, const char *fmt, va_list ap) {
    panic("Not implemented");
}

int sprintf(char *out, const char *fmt, ...) {
    va_list list;
    va_start(list, fmt);
    int ret = 0;
    for (int i = 0; i < strlen(fmt); ++i) {
        if (fmt[i] != '%') {
            *(out++) = fmt[i];
            ret++;
        }
        else {
            switch (fmt[i + 1])
            {
            case 'd':
                int num = va_arg(list, int);
                ret += num2string(&out, num, 10);
                break;
            
            case 's':
                char *str = va_arg(list, char*);
                while(*str != '\0') {
                    *(out++) = *(str++);
                    ret++;
                }
                break;
            default:
                break;
            }
        }
    }
    return ret;
}

int snprintf(char *out, size_t n, const char *fmt, ...) {
    panic("Not implemented");
}

int vsnprintf(char *out, size_t n, const char *fmt, va_list ap) {
    panic("Not implemented");
}

#endif
