#pragma once

#include <vector>
#include "../Math/Tri.cuh"
#include "../HostResourceManager/HostMeshManager.hpp"

class DeviceTriBuffer {
public:
    Tri* tris;
    size_t numTris;
    
    __host__ DeviceTriBuffer() = delete;
    __host__ DeviceTriBuffer(const HostMeshManager& hostMeshManager) {
        std::vector<Tri> hostTris;

        for (HostMesh hm : hostMeshManager.getMeshs()) {
            for (const Tri& t : hm.getTris()) {
                hostTris.push_back(t);
            }
        }

        numTris = hostTris.size();
        printf("numTris: %d\n", numTris);

        size_t size = hostTris.size() * sizeof(Tri);
        cudaError_t err = cudaMalloc(&tris, size);
        if (err != cudaSuccess) {
            printf("ERROR cudaMalloc failed in DeviceTriBuffer");
        }

        err = cudaMemcpy(tris, hostTris.data(), size, cudaMemcpyHostToDevice);
        if (err != cudaSuccess) {
            printf("ERROR cudaMemcpy failed in DeviceTriBuffer");
        }
    }
    __host__ ~DeviceTriBuffer() {
        cudaFree(tris);
    }
    __host__ DeviceTriBuffer(const DeviceTriBuffer& deviceTriBuffer) = delete;
    __host__ DeviceTriBuffer(DeviceTriBuffer&& deviceTriBuffer) = delete;
    __host__ DeviceTriBuffer& operator=(const DeviceTriBuffer& deviceTriBuffer) = delete;
    __host__ DeviceTriBuffer& operator=(DeviceTriBuffer&& deviceTriBuffer) = delete;
};