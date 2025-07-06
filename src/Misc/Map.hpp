#pragma once

#include <type_traits>

#include "../Ext/stb_image.h"
#define STB_IMAGE_IMPLEMENTATION

struct Map {
    unsigned char* data;
    int width;
    int height;
    int channels;

    Map() : width(1), height(1) {}

    Map(const Vec3& vec) : width(1), height(1), channels(3) {
        // should just be a 1x1 of a single color
        data = (unsigned char*)malloc(sizeof(char) * 3);
        data[0] = (char)(vec.x * 255);
        data[1] = (char)(vec.y * 255);
        data[2] = (char)(vec.z * 255);
    }

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