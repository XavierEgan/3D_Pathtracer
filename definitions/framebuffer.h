#ifndef FRAMEBUFFER_H
#define FRAMEBUFFER_H
#include "color.h"

typedef struct {
    Color* buffer;
    unsigned long long buffer_len;
} Framebuffer;

Framebuffer init_buffer(unsigned long long buffer_len);

void free_buffer(Framebuffer* buffer);

void buffer_write(unsigned int y, unsigned int x, Color data);

#endif