#include <am.h>
#include <nemu.h>
#include <stdio.h>

#define KEYDOWN_MASK 0x8000

void __am_input_keybrd(AM_INPUT_KEYBRD_T *kbd) {
    kbd->keycode = inl(KBD_ADDR);
    if (kbd->keycode != 0) printf("%x\n", kbd->keycode);
    kbd->keydown = (kbd->keycode & KEYDOWN_MASK) >> 15;
    kbd->keycode = kbd->keycode & (~KEYDOWN_MASK);
}


