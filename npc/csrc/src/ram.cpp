#include "../Include/ram.h"
#include "../Include/log.h"
#include "Vtop.h"
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

uint8_t pmem[RAM_SIZE];

extern Vtop dut;

static void *guset_to_host(uint32_t addr) {
    return ((uint8_t *)pmem + addr - RAM_START_ADDR);
}

static uint8_t test_img[] = {
    0x13, 0x00, 0xf0, 0xff,
    0x93, 0x00, 0xf0, 0xff,
    0x13, 0x01, 0xf0, 0xff,
    0x93, 0x01, 0xf0, 0xff,
    0x73, 0x00, 0x10, 0x00
};

void load_img(char *img_file) {
    if (img_file == NULL) {
        Log("No image is given. Use default image.");
        memcpy(guset_to_host(RESET_VECTOR), test_img, sizeof(test_img));
        return;
    }

    FILE *fp = fopen(img_file, "rb");
    Assert(fp, "Can not open '%s'.", img_file);

    fseek(fp, 0, SEEK_END);

    long size = ftell(fp);

    Log("The image is %s, size = %ld", img_file, size);

    rewind(fp);

    int ret = fread((uint8_t *)guset_to_host(RESET_VECTOR), size, 1, fp);
    Assert(ret == 1, "Read image file failed.");

    fclose(fp);
}

int flag_read = 1;
int pmem_read(int addr, int len) {
    if (addr < RAM_START_ADDR || addr > RAM_END_ADDR) return 0;
    switch (len) {
        case 0: // 1
            return *(uint8_t *)guset_to_host(addr);
        case 1: // 2
            return *(uint16_t *)guset_to_host(addr);
        case 2: // 4
            return *(uint32_t *)guset_to_host(addr);
        
        default:
            return 0;
    }
}

int flag_write = 1;
void pmem_write(int addr, int data, int len) {
    printf("333\n");
    if (flag_write == 1) {
        flag_write = 0;
        return;
    }
    Assert((addr <= RAM_END_ADDR) && (addr >= RAM_START_ADDR), "Addr 0x%08x transbordered the boundary.", addr);
    switch (len) {
        case 0: // 1
            *(uint8_t *)guset_to_host(addr) = data;
            return;
        case 1: // 2
            *(uint16_t *)guset_to_host(addr) = data;
            return;
        case 2: // 4
            *(uint32_t *)guset_to_host(addr) = data;
            return;
        
        default:
            Assert(0, "pmem_write error, input 'len' is %d", len);
            return;
    }
}

void halt() {
    if (dut.rf[10] != 0) {
        printf(ANSI_FG_RED "Hit bad trap" ANSI_NONE " at pc = 0x%08x\n", dut.pc);
        exit(-1);
    } else {
        printf(ANSI_FG_GREEN "Hit good trap" ANSI_NONE " at pc = 0x%08x\n", dut.pc);
        exit(0);
    }
}

// For DPI-C
static int flag = 1;
int fetch_inst(int pc) {
    if (flag == 1) {
        flag = 0;
        return 0;
    }
    uint32_t inst = pmem_read(pc, 2);
    if (inst == 0x00100073) {

        for (int i = 0; i < 32; i++) {
            printf("R%d = 0x%x\n", i, dut.rf[i]);
        }

        Log("Get 'ebreak' instruction, program over.");
        halt();
    }
    return inst;
}
