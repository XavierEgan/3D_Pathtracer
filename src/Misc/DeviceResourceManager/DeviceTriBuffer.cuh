#pragma once

#include <vector>
#include "../Math/Tri.cuh"
#include "../HostResourceManager/HostMeshManager.hpp"

class DeviceTriBuffer {
    Tri* tris;
    size_t numTris;

public:  
    DeviceTriBuffer() = delete;
    DeviceTriBuffer(const HostMeshManager hostMeshManager) {
        std::vector<Tri> hostTris;

        for (HostMesh hm : hostMeshManager.getMeshs()) {
            hostTris.insert(hostTris.end(), hm.getTris().begin(), hm.getTris().end());
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
    ~DeviceTriBuffer() {
        cudaFree(tris);
    }
    DeviceTriBuffer(const DeviceTriBuffer& deviceTriBuffer) = delete;
    DeviceTriBuffer(DeviceTriBuffer&& deviceTriBuffer) = delete;
    DeviceTriBuffer& operator=(const DeviceTriBuffer& deviceTriBuffer) = delete;
    DeviceTriBuffer& operator=(DeviceTriBuffer&& deviceTriBuffer) = delete;
};