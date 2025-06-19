#pragma once

#include <type_traits>

#include "../Ext/stb_image.h"
#define STB_IMAGE_IMPLEMENTATION

struct Map {
    unsigned char* data;
    int width;
    int height;
    int channels;

    Map(char* fileLoc) {
        data = stbi_load(fileLoc, &width, &height, &channels, 0);
    }
    
    char sample(float u, float v) {
        size_t ui = (int)(u * width);
        size_t vi = (int)(v * height);

        return data[vi * height + ui];
    }
};