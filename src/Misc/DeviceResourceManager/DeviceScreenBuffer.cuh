#pragma once

#define STB_IMAGE_WRITE_IMPLEMENTATION
#include "../../Ext/stb_image_write.h"
#include "../../Math/Vec3.cuh"
#include "../Camera.hpp"

class DeviceScreenBuffer {
    unsigned char* data;

    unsigned int width;
    unsigned int height;
    unsigned int channels {3};

public:
    __host__ DeviceScreenBuffer(const ScreenParams& screenParams) : width(screenParams.width), height(screenParams.height)  {
        size_t size = width * height * 3 * sizeof(char);
        cudaError_t err = cudaMalloc(&data, size);
        if (err != cudaSuccess) {
            printf("error cudaMalloc in DeviceScreenBuffer");
        }
    }

    __device__ void write(Vec3 data, unsigned int x, unsigned int y) {
        #ifdef DEBUG
        if (x >= width) {
            printf("Out of range write (width)\n");
            return;
        }
        if (y >= height) {
            printf("Out of range write (height)\n");
            return;
        }
        if (data.x > 1.0f || data.y > 1.0f || data.z > 1.0f) {
            data.print("data to write too big: ");
            return;
        }

        #endif

        this->data[y * width * 3 + x * 3] = (char)(data.x * 255);
        this->data[y * width * 3 + x * 3 + 1] = (char)(data.y * 255);
        this->data[y * width * 3 + x * 3 + 2] = (char)(data.z * 255);
    }

    __host__ void writeImage(char* fileLoc) {
        size_t size = width * height * channels * sizeof(unsigned char);
        unsigned char* hostData = (unsigned char*)malloc(size);

        cudaMemcpy(hostData, data, size, cudaMemcpyDeviceToHost);

        std::cout << "Writing Image" << std::endl;
        const int maxQuality = 100;
        stbi_write_jpg(fileLoc, width, height, channels, hostData, maxQuality);
        std::cout << "Image Written To " << fileLoc << std::endl;
    }
};