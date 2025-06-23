#pragma once

#include <type_traits>

#include "../Ext/stb_image.h"
#define STB_IMAGE_IMPLEMENTATION

struct Map {
    unsigned char* data;
    int width;
    int height;
    int channels;

    Map() {}

    void getDataFromFile(char* fileLoc) {
        unsigned char* fileData = stbi_load(fileLoc, &width, &height, &channels, 0);

        size_t size = width * height * channels * sizeof(char);
        cudaMalloc(&data, size);
        cudaMemcpy(data, fileData, size, cudaMemcpyHostToDevice);
    }
    
    __host__ __device__ Vec3 sample(float u, float v) const {
        size_t ui = (int)(u * width);
        size_t vi = (int)(v * height);

        return Vec3(
            data[vi * height * channels + ui * channels],
            data[vi * height * channels + ui * channels + 1],
            data[vi * height * channels + ui * channels + 2]
        ) / 255;
    }
};