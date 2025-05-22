#include "framebuffer.h"
#include <stdio.h>
#include <stdlib.h>

Framebuffer init_buffer(unsigned long buffer_len) {
    Framebuffer frame_buffer = {NULL, buffer_len};

    Color* buffer = malloc(sizeof(Color) * buffer_len);
    if (!buffer) {
        // oh no, probably memory leak
        fprintf(stderr, "FATAL: Cannot allocate frame buffer of size %zu\n", buffer_len);
        abort();
    }

    return frame_buffer;
}

void free_buffer(Framebuffer* buffer) {

}

void buffer_write(unsigned int y, unsigned int x, Color data) {

}
