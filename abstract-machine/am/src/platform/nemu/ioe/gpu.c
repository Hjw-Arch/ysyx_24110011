#include <am.h>
#include <nemu.h>
#include <stdio.h>

#define SYNC_ADDR (VGACTL_ADDR + 4)

void __am_gpu_init() {
    // int i;
    // int w = io_read(AM_GPU_CONFIG).width;
    // int h = io_read(AM_GPU_CONFIG).height;
    // uint32_t *fb = (uint32_t *)(uintptr_t)FB_ADDR;
    // for (i = 0; i < w * h; i++) fb[i] = i;
    // outl(SYNC_ADDR, 1);
}

void __am_gpu_config(AM_GPU_CONFIG_T *cfg) {
    uint32_t width_higth = inl(VGACTL_ADDR);
    *cfg = (AM_GPU_CONFIG_T){
        .present = true, .has_accel = false,
        .width = width_higth >> 16, .height = width_higth & 0x0000ffff,
        .vmemsz = (width_higth >> 16) * (width_higth & 0x0000ffff) * 4
    };
}

// AM_DEVREG(11, GPU_FBDRAW,   WR, int x, y; void *pixels; int w, h; bool sync);

void __am_gpu_fbdraw(AM_GPU_FBDRAW_T *ctl) {
    if (ctl->h == 0 || ctl->y == 0) return;
    printf("111");
    AM_GPU_CONFIG_T cfg;
    __am_gpu_config(&cfg);
    // uint32_t *fb = (uint32_t *)(uintptr_t)FB_ADDR;
    for (uint32_t i = ctl->y; i < ctl->y + ctl->h; i++) {
        for (uint32_t j = ctl->x; j < ctl->x + ctl->w; j++) {
            outl(FB_ADDR + (i * cfg.width + j) * 4, *((uint32_t *)ctl->pixels + ((i - ctl->y) * cfg.width + (j - ctl->x))));
        }
    }

    if (ctl->sync) {
        outl(SYNC_ADDR, 1);
    }
}

void __am_gpu_status(AM_GPU_STATUS_T *status) {
    status->ready = true;
}
