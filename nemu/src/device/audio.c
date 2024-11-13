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

#include <common.h>
#include <device/map.h>
#include <SDL2/SDL.h>

enum {
  reg_freq,
  reg_channels,
  reg_samples,
  reg_sbuf_size,
  reg_init,
  reg_count,
  nr_reg
};

static uint8_t *sbuf = NULL;
static uint32_t *audio_base = NULL;

static uint8_t *audio_pos = NULL;

SDL_AudioSpec spec;

static void audio_callback(void *userdata, uint8_t *stream, int len) {
    uint32_t len_to_copy;

    if (audio_base[reg_count] == 0) {
        return;
    }

    if (audio_base[reg_count] < len) {
        len_to_copy = audio_base[reg_count];
        memset(stream + len_to_copy, 0, len - len_to_copy);
    } else {
        len_to_copy = len;
    }

    SDL_memcpy(stream, audio_pos, len_to_copy);

    if (audio_pos + len > sbuf + CONFIG_SB_SIZE) audio_pos = sbuf;
    else audio_pos += len_to_copy;
    
    audio_base[reg_count] -= len_to_copy;
}

static void audio_io_handler(uint32_t offset, int len, bool is_write) {
    if (is_write) {
        if (offset == reg_freq * 4) spec.freq = audio_base[reg_freq];
        if (offset == reg_channels * 4) spec.channels = audio_base[reg_channels];
        if (offset == reg_samples * 4) spec.samples = audio_base[reg_samples];
    }

    if (audio_base[reg_init]) {
        audio_pos = sbuf;
        audio_base[reg_sbuf_size] = CONFIG_SB_SIZE;

        SDL_InitSubSystem(SDL_INIT_AUDIO);
        spec.callback = audio_callback;
        spec.format = AUDIO_S16SYS;
        spec.silence = 0;
        SDL_OpenAudio(&spec, 0);
        SDL_PauseAudio(0);

        audio_base[reg_init] = 0;
    }
}

void init_audio() {
    uint32_t space_size = sizeof(uint32_t) * nr_reg;
    audio_base = (uint32_t *)new_space(space_size);
#ifdef CONFIG_HAS_PORT_IO
    add_pio_map ("audio", CONFIG_AUDIO_CTL_PORT, audio_base, space_size, audio_io_handler);
#else
    add_mmio_map("audio", CONFIG_AUDIO_CTL_MMIO, audio_base, space_size, audio_io_handler);
#endif

    sbuf = (uint8_t *)new_space(CONFIG_SB_SIZE);
    add_mmio_map("audio-sbuf", CONFIG_SB_ADDR, sbuf, CONFIG_SB_SIZE, NULL);
}
