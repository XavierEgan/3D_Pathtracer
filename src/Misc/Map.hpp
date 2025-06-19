#pragma once

#include <type_traits>

#include "../Ext/stb_image.h"
#define STB_IMAGE_IMPLEMENTATION

struct Map {
    unsigned char* data; // plays nicer with stbi and cuda
    int width;
    int height;
    int channels;

    Map(char* fileLoc) {
        data = stbi_load(fileLoc, &width, &height, &channels, 0);
    }
    
    Vec3 sample(float u, float v) {
        size_t ui = (int)(u * width);
        size_t vi = (int)(v * height);

        return Vec3(
            data[vi * height * 3 + ui * 3],
            data[vi * height * 3 + ui * 3 + 1],
            data[vi * height * 3 + ui * 3 + 2]
        ) / 255;
    }
};