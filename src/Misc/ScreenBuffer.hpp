#pragma once

#include "Camera.hpp"
#define STB_IMAGE_WRITE_IMPLEMENTATION
#include "../Ext/stb_image_write.h"

struct ScreenBuffer {
    char* data;

    unsigned int width;
    unsigned int height;

    ScreenBuffer(ScreenParams screenParams) : data(nullptr), width(screenParams.width), height(screenParams.height) {}

    void allocData() {
        size_t size = width * height * 3 * sizeof(char);
        cudaMalloc(&data, size);
    }

    void free() {
        if (data) {
            cudaFree(data);
            data = nullptr;
        }
    }

    __host__ __device__ void write(Vec3 data, unsigned int x, unsigned int y) {
        this->data[y * width * 3 + x * 3] = (char)(data.x * 255);
        this->data[y * width * 3 + x * 3 + 1] = (char)(data.y * 255);
        this->data[y * width * 3 + x * 3 + 2] = (char)(data.z * 255);
    }

    void writeImage(char* fileLoc) {
        std::cout << "Writing Image" << std::endl;
        const int maxQuality = 100;
        stbi_write_jpg(fileLoc, width, height, 3, data, maxQuality);
        std::cout << "Image Written To " << fileLoc << std::endl;
    }
};
