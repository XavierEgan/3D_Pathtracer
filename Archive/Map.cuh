#pragma once

#include <type_traits>
#include "../Math/Vec3.cuh"

#include "../Ext/stb_image.h"
#define STB_IMAGE_IMPLEMENTATION

struct Map {
    unsigned char* data;
    int width;
    int height;
    int channels;

    Map() : width(1), height(1), channels(3) {
        data = (unsigned char*)malloc(sizeof(char) * 3);
        data[0] = (char)(0);
        data[1] = (char)(0);
        data[2] = (char)(0);
    }

    Map(const Vec3& vec) : width(1), height(1), channels(3) {
        // should just be a 1x1 of a single color
        data = (unsigned char*)malloc(sizeof(char) * 3);
        data[0] = (char)(vec.x * 255);
        data[1] = (char)(vec.y * 255);
        data[2] = (char)(vec.z * 255);
    }

    void toDevice() {
        unsigned char* hostData = data;
        size_t size = width * height * channels * sizeof(char);
        cudaError_t err = cudaMalloc(&data, size);
        if (err != cudaSuccess) {
            printf("cudaMalloc failed: %s\n", cudaGetErrorString(err));
            return;
        }
        printf("size: %d", size);
        err = cudaMemcpy(data, hostData, size, cudaMemcpyHostToDevice);
        if (err != cudaSuccess) {
            printf("cudaMemcpy failed: %s\n", cudaGetErrorString(err));
            return;
        }
        free(hostData);
        //printf("data: %p", data);
    }
    
    void getDataFromFile(char* fileLoc) {
        unsigned char* fileData = stbi_load(fileLoc, &width, &height, &channels, 0);

        size_t size = width * height * channels * sizeof(char);
        cudaMalloc(&data, size);
        cudaMemcpy(data, fileData, size, cudaMemcpyHostToDevice);
    }
    
    __device__ Vec3 sample(float u, float v) const {
        size_t ui = (int)(u * width);
        size_t vi = (int)(v * height);

        //return(Vec3(1,0,0));
        //printf("textureMap: %p\n", data);
        int xi = vi * width * channels + ui * channels;
        int yi = xi + 1;
        int zi = xi + 2;

        char x = data[xi];
        char y = data[yi];
        char z = data[zi];
        Vec3 ret = Vec3(x, y, z) / 255;

        return ret;
    }
};