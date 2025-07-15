#pragma once

#include <vector>
#include "../Math/Tri.cuh"
#include "../HostResourceManager/HostMeshManager.hpp"

class DeviceTriBuffer {
    Tri* tris;
    size_t numTris;
public:
    __host__ DeviceTriBuffer() = delete;
    __host__ DeviceTriBuffer(const HostMeshManager& hostMeshManager) {
        std::vector<Tri> hostTris;

        int i=0;
        for (HostMesh hm : hostMeshManager.getMeshs()) {
            for (const Tri& t : hm.getTris()) {
                hostTris.push_back(t);
            }
            i++;
        }

        numTris = hostTris.size();

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
        printf("freeing");
        cudaFree(tris);
    }
    __host__ DeviceTriBuffer(const DeviceTriBuffer& deviceTriBuffer) = delete;
    __host__ DeviceTriBuffer(DeviceTriBuffer&& deviceTriBuffer) = delete;
    __host__ DeviceTriBuffer& operator=(const DeviceTriBuffer& deviceTriBuffer) = delete;
    __host__ DeviceTriBuffer& operator=(DeviceTriBuffer&& deviceTriBuffer) = delete;

    __device__ const Tri& getTri(unsigned int i) const {
        if (i >= numTris) {
            printf("[DEVICE ERROR] in getTri, index out of range");
        }
        return tris[i];
    }
    __device__ size_t getNumTris() const {
        return numTris;
    }
};