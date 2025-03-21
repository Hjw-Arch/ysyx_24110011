#include "../Include/device.h"

#define SCREEN_W (MUXDEF(CONFIG_VGA_SIZE_800x600, 800, 400))
#define SCREEN_H (MUXDEF(CONFIG_VGA_SIZE_800x600, 600, 300))

static uint32_t screen_size()
{
    return SCREEN_W * SCREEN_H * sizeof(uint32_t);
}

static void *vmem = NULL;
static uint32_t *vgactl_port_base = NULL;

#ifdef CONFIG_VGA_SHOW_SCREEN
#include <SDL2/SDL.h>

static SDL_Renderer *renderer = NULL;
static SDL_Texture *texture = NULL;

static void init_screen()
{
    SDL_Window *window = NULL;
    char title[128];
    sprintf(title, "%s-NPC", "riscv32e");
    SDL_Init(SDL_INIT_VIDEO);
    SDL_CreateWindowAndRenderer(
        SCREEN_W * (MUXDEF(CONFIG_VGA_SIZE_400x300, 2, 1)),
        SCREEN_H * (MUXDEF(CONFIG_VGA_SIZE_400x300, 2, 1)),
        0, &window, &renderer);
    SDL_SetWindowTitle(window, title);
    texture = SDL_CreateTexture(renderer, SDL_PIXELFORMAT_ARGB8888,
                                SDL_TEXTUREACCESS_STATIC, SCREEN_W, SCREEN_H);
    SDL_RenderPresent(renderer);
}

static inline void update_screen()
{
    SDL_UpdateTexture(texture, NULL, vmem, SCREEN_W * sizeof(uint32_t));
    SDL_RenderClear(renderer);
    SDL_RenderCopy(renderer, texture, NULL, NULL);
    SDL_RenderPresent(renderer);
}

#endif

void vga_update_screen()
{
    if (vgactl_port_base[1])
    {
        update_screen();
        vgactl_port_base[1] = 0;
    }
}

void init_vga()
{
    vgactl_port_base = (uint32_t *)new_space(8);
    vgactl_port_base[0] = (SCREEN_W << 16) | SCREEN_H;

    add_mmio_map("vgactl", CONFIG_VGA_CTL_MMIO, vgactl_port_base, 8, NULL);

    vmem = new_space(screen_size());
    add_mmio_map("vmem", CONFIG_FB_ADDR, vmem, screen_size(), NULL);
    IFDEF(CONFIG_VGA_SHOW_SCREEN, init_screen());
    IFDEF(CONFIG_VGA_SHOW_SCREEN, memset(vmem, 0, screen_size()));
}