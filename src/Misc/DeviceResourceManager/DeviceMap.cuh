#pragma once

#include <vector>
#include "../Math/Tri.cuh"
#include "../HostResourceManager/HostMap.hpp"

class DeviceMap {
    unsigned char* mapData;
    unsigned int mapWidth;
    unsigned int mapHeight;
    unsigned int channels;

public:
    DeviceMap() = delete;
    DeviceMap(const HostMap& hostMap) {
        mapWidth = hostMap.getWidth();
        mapHeight = hostMap.getHeight();
        channels = hostMap.getChannels();

        size_t size = mapWidth * mapHeight * channels * sizeof(unsigned char);
        cudaError_t err = cudaMalloc(&mapData, size);
        if (err != cudaSuccess) {
            printf("Error in DeviceMap cudaMalloc");
        }

        unsigned char* hostDataPointer = hostMap.getData().data();

        err = cudaMemcpy((void*)mapData, (void*)hostDataPointer, size, cudaMemcpyHostToDevice);
        if (err != cudaSuccess) {
            printf("Error in DeviceMap cudaMemcpy");
        }
    }
    ~DeviceMap() {
        cudaFree(mapData);
    }
    DeviceMap(const DeviceMap& deviceMap) = delete;
    DeviceMap(DeviceMap&& deviceMap) = delete;
    DeviceMap& operator=(const DeviceMap& deviceMap) = delete;
    DeviceMap& operator=(DeviceMap&& deviceMap) = delete;

    Vec3 sample(float u, float v) {
        int x = static_cast<int>(u * mapWidth);
        int y = static_cast<int>(v * mapHeight);
        int index = (y * mapWidth + x) * channels;

        return Vec3(
            mapData[index] / 255.0f,
            mapData[index + 1] / 255.0f,
            mapData[index + 2] / 255.0f
        );
    }
};

/*
Copy constructor, copy assignment, move constructor and move assignment archive
DeviceMap(const DeviceMap& deviceMap) {
        mapWidth = deviceMap.mapWidth;
        mapHeight = deviceMap.mapHeight;
        channels = deviceMap.channels;

        size_t size = mapWidth * mapHeight * channels * sizeof(unsigned char);
        cudaError_t err = cudaMalloc(&mapData, size);
        if (err != cudaSuccess) {
            printf("Error in DeviceMap cudaMalloc");
        }

        err = cudaMemcpy((void*)mapData, (void*)deviceMap.mapData, size, cudaMemcpyDeviceToDevice);
        if (err != cudaSuccess) {
            printf("Error in DeviceMap cudaMemcpy");
        }
    }
    DeviceMap(DeviceMap&& deviceMap) {
        mapWidth = deviceMap.mapWidth;
        mapHeight = deviceMap.mapHeight;
        channels = deviceMap.channels;
        mapData = deviceMap.mapData;
        deviceMap.mapData = nullptr; // to avoid making a dangling pointer and also double freeing
    }
    DeviceMap& operator=(const DeviceMap& deviceMap) {
        if (this == &deviceMap) {
            return *this;
        }

        cudaFree(mapData);
        mapWidth = deviceMap.mapWidth;
        mapHeight = deviceMap.mapHeight;
        channels = deviceMap.channels;

        size_t size = mapWidth * mapHeight * channels * sizeof(unsigned char);
        cudaError_t err = cudaMalloc(&mapData, size);
        if (err != cudaSuccess) {
            printf("Error in DeviceMap cudaMalloc");
        }

        err = cudaMemcpy((void*)mapData, (void*)deviceMap.mapData, size, cudaMemcpyDeviceToDevice);
        if (err != cudaSuccess) {
            printf("Error in DeviceMap cudaMemcpy");
        }
        return *this;
    }
    DeviceMap& operator=(DeviceMap&& deviceMap) {
        if (this == &deviceMap) {
            return *this;
        }
        
        cudaFree(mapData);
        mapWidth = deviceMap.mapWidth;
        mapHeight = deviceMap.mapHeight;
        channels = deviceMap.channels;
        mapData = deviceMap.mapData;
        deviceMap.mapData = nullptr; // to avoid making a dangling pointer and also double freeing
        return *this;
    }
*/