#include <klib.h>
#include <klib-macros.h>
#include <stdint.h>

#if !defined(__ISA_NATIVE__) || defined(__NATIVE_USE_KLIB__)

size_t strlen(const char *s) {
    uint32_t num = 0;
    while(*(s++) != '\0') {
        num++;
    }
    return num;
}

char *strcpy(char *dst, const char *src) {
    char *ret = dst;
    while(*src != '\0') {
        *(dst++) = *(src++);
    }
    *dst = '\0';
    return ret;
}

char *strncpy(char *dst, const char *src, size_t n) {
    char *ret = dst;

    uint32_t i = 0;

    while(i++ < n && *src != '\0') {
        *(dst++) = *(src++);
    }

    if (i >= n) {
        return ret;
    }

    *dst = '\0';

    return ret;
}

char *strcat(char *dst, const char *src) {
    char *ret = dst;
    while(*dst != '\0') dst++;
    while(*src != '\0') *(dst++) = *(src++);
    *dst = '\0';        // 有安全漏洞
    return ret;
}

int strcmp(const char *s1, const char *s2) {
    while(*s1 - *s2 == 0 && *s1 != '\0') s1++, s2++;
    return *s1 - *s2;
}

int strncmp(const char *s1, const char *s2, size_t n) {
    uint32_t i = 0;
    while (i < n) {
        if (s1[i] == s2[i] && s1[i] != '\0') {
            i++;
            continue;
        } else {
            return s1[i] - s2[i];
        }
    }

    return 0;
    
}

void *memset(void *s, int c, size_t n) {
    for (uint8_t *ptr = (uint8_t *)s; ptr < (uint8_t *)s + n; ptr++) {
        *ptr = (uint8_t)c;
    }

    return s;
}

void *memmove(void *dst, const void *src, size_t n) {
    uint8_t *d = dst, *s = (uint8_t *)src;
    if (d < s) {
        for (int i = 0; i < n; ++i) d[i] = s[i];
    } else {
        for (int i = n - 1; i >= 0; --i) d[i] = s[i];
    }

    return dst;
}

void *memcpy(void *out, const void *in, size_t n) {
    uint8_t *o = out, *i = (uint8_t *)in;
    for (int k = 0; k < n; ++k) o[k] = i[k];

    return out;
}

int memcmp(const void *s1, const void *s2, size_t n) {
    uint8_t *str1 = (uint8_t *)s1, *str2 = (uint8_t *)s2;
    for (int i = 0; i < n; ++i) {
        if (str1[i] != str2[i]) return str1[i] - str2[i];
    }

    return 0;
}

#endif
