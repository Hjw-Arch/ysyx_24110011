#include <am.h>
#include <klib.h>
#include <klib-macros.h>
#include <stdarg.h>

#if !defined(__ISA_NATIVE__) || defined(__NATIVE_USE_KLIB__)


enum {
    normal = 0,
    h,
    hh,
    l,
    ll,
    j,
    z,
    t,
    L,
};

static int num2string(char *out, int num, int base) {
    int ret = 0;
    // process negative number
    if (num < 0) {
        *(out++) = '-';
        num = -num;
        ret++;
    }

    // process zero
    if (num == 0) {
        *(out++) = '0';
        return 1;
    }


    int a[20];
    int i = 0;
    while(num != 0) {
        a[i++] = num % base;
        num /= base;
    }

    while(i-- > 0) {
        if (a[i] >= 10) {
            *(out++) = (char)(a[i] - 10 + 'a');
            ret++;
        } else {
            *(out++) = (char)(a[i] + '0');
        }
        ret++;
    }

    return ret;
}

static int simple_pow(int a, int b) {
    int result = 1;
    for (int i = 0; i < b; i++) {
        result *= a;
    }
    return result;
}

static void string2num(int *num, const char *string, int len) {
    *num = 0;
    for (int i = len - 1; i >= 0; i--) {
        if (string[i] > '9' || string[i] < '0') {
            *num = 0;
            return;
        }
        *num += (string[i] - '0') * simple_pow(10, len - i - 1);
    }
}

int printf(const char *fmt, ...) {
    va_list list;
    va_start(list, fmt);
    char out[1024];
    int len = vsprintf(out, fmt, list);
    int i;
    for (i = 0; i < len; i++) {
        putch(out[i]);
    }
    va_end(list);
    return i;
}

int vsprintf(char *out, const char *fmt, va_list ap) {
    int ret = 0;
    for (int i = 0; i < strlen(fmt); ++i) {
        if (fmt[i] != '%') {
            *(out++) = fmt[i];
            ret++;
        }
        else {
            i++;

            bool leftAlign = false;
            bool showSymbol = false;
            bool replaceFormat = false;     // TODO
            bool blankBeforePostiveNum = false;
            bool paddingCharZero = false;
            int width = 0;
            int precision = -1;         // TODO
            int length = normal;        // TODO

            width = length - 1 + length + 1;    // 消除警告
            width = replaceFormat;

            // flags
            while(1) {
                switch (fmt[i]) {
                    case '-': {
                        leftAlign = true;
                        i++;
                        break;
                    }

                    case '+': {
                        showSymbol = true;
                        blankBeforePostiveNum = false;
                        i++;
                        break;
                    }

                    case '0': {
                        paddingCharZero = true;
                        i++;
                        break;
                    }

                    case '#': {     // TODO
                        replaceFormat = true;
                        i++;
                        break;
                    }

                    case ' ': {
                        i++;
                        if (showSymbol) {
                            break;
                        }

                        blankBeforePostiveNum = true;

                        break;
                    }
                    
                    default:
                        goto br;
                }
br:             break;
            }

            // width
            int j;
            for (j = 0; fmt[i + j] <= '9' && fmt[i + j] >= '0'; j++) ;
            string2num(&width, &fmt[i], j);
            i += j;

            // precision
            if (fmt[i] == '.') {
                i++;
                for (j = 0; fmt[i + j] <= '9' && fmt[i + j] >= '0'; j++) ;
                string2num(&precision, &fmt[i], j);
                i += j;
            }

            // length
            switch (fmt[i])
            {
            case 'h': {
                i++;
                if (fmt[i] == 'h') {
                    i++;
                    length = hh;
                    break;
                }
                length = h;
                break;
            }

            case 'l': {
                i++;
                if (fmt[i] == 'l') {
                    i++;
                    length = ll;
                    break;
                }
                length = l;
                break;
            }

            // TODO
            case 'j':
            case 'z':
            case 't':
            case 'L':
                length = normal;    // TODO;
                i++;
            default:
                break;
            }

            switch (fmt[i]) {
                case 'd': {
                    int num = va_arg(ap, int);
                    if (showSymbol && num > 0) *(out++) = '+';
                    if (blankBeforePostiveNum && num > 0) *(out++) = ' ';

                    char temp_str[20];
                    int len = num2string(temp_str, num, 10);

                    bool isRequiredWidth = false;

                    if (width > len) {
                        if (!leftAlign || paddingCharZero) {
                            for (j = 0; j < width - len; j++) {
                                *(out++) = (paddingCharZero ? '0' : ' ');
                            }
                            ret += j;
                            isRequiredWidth = true;
                        }
                    }

                    ret += len;
                    strncpy(out, temp_str, len);
                    out += len;

                    if (width > len && !isRequiredWidth) {
                        for (j = 0; j < width - len; j++) {
                            *(out++) = ' ';
                        }
                        ret += j;
                    }

                    break;
                }

                case 's': {
                    char *str = va_arg(ap, char*);
                    while (*str != '\0') {
                        *(out++) = *(str++);
                        ret++;
                    }
                    break;
                }

                case 'c': {
                    char ch = (char)va_arg(ap, int);
                    *(out++) = ch;
                    ret++;
                    break;
                }

                case '%': {
                    *(out++) = '%';
                    ret++;
                }

                default:
                    break;
            }
        }
    }
    *out = '\0';
    return ret;
}

int sprintf(char *out, const char *fmt, ...) {
    va_list list;
    va_start(list, fmt);
    
    int ret = vsprintf(out, fmt, list);

    va_end(list);
    return ret;
}

int snprintf(char *out, size_t n, const char *fmt, ...) {
    panic("Not implemented");
}

int vsnprintf(char *out, size_t n, const char *fmt, va_list ap) {
    panic("Not implemented");
}

#endif
