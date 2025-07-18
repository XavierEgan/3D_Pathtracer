#pragma once

#include "../Camera.hpp"

struct PixelPerformance {
    long long AABBIntersecs;
    long long rayTriIntersecs;
    long long rayTraces;
    long long reflectedRays;
    long long refractedRays;
    long long diffuseRays;
};

class DevicePerformance {
    PixelPerformance* data;
    int width;
    int height;
    int x;
    int y;
public:
    DevicePerformance(ScreenParams screenParams) : width(screenParams.width), height(screenParams.height) {
        size_t size = screenParams.width * screenParams.height * sizeof(PixelPerformance);
        cudaMalloc(&data, size);
    }

    __device__ void setXY(int x, int y) {
        this->x = x;
        this->y = y;
    }

    __device__ void incrimentAABBIntersecs() {
        data[y * width + x].AABBIntersecs++;
    }

    __device__ void incrimentRayTriIntersecs() {
        data[y * width + x].rayTriIntersecs++;
    }

    __device__ void incrimentRayTraces() {
        data[y * width + x].rayTraces++;
    }

    __device__ void incrimentReflectedRays() {
        data[y * width + x].reflectedRays++;
    }

    __device__ void incrimentRefractedRays() {
        data[y * width + x].refractedRays++;
    }

    __device__ void incrimentDiffuseRays() {
        data[y * width + x].diffuseRays++;
    }

    void printReport() {
        long long aabbIntersecs = 0;
        long long rayTriIntersecs = 0;
        long long rayTraces = 0;
        long long reflectedRays = 0;
        long long refractedRays = 0;
        long long diffuseRays = 0;

        size_t size = width * height * sizeof(PixelPerformance);
        PixelPerformance* hostData = (PixelPerformance*)malloc(size);
        cudaMemcpy(hostData, data, size, cudaMemcpyDeviceToHost);

        for (int y=0; y < height; y++) {
            for (int x=0; x < width; x++) {
                int index = y * width + x;
                aabbIntersecs += hostData[index].AABBIntersecs;
                rayTriIntersecs += hostData[index].rayTriIntersecs;
                rayTraces += hostData[index].rayTraces;
                reflectedRays += hostData[index].reflectedRays;
                refractedRays += hostData[index].refractedRays;
                diffuseRays += hostData[index].diffuseRays;
            }
        }
        printf(
            "Performance Report:\n\tAABB Intersecs = %lld\n\tRay Tri Intersecs = %lld\n\tRay Traces = %lld\n\tReflected Rays = %lld\n\tRefracted Rays = %lld\n\tDiffuse Rays = %lld\n",
            aabbIntersecs,
            rayTriIntersecs,
            rayTraces,
            reflectedRays,
            refractedRays,
            diffuseRays
        );
    }
};