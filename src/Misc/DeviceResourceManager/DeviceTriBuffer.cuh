#pragma once

#include <vector>
#include "../Math/Tri.cuh"
#include "../HostResourceManager/HostMeshManager.hpp"

class DeviceTriBuffer {
    Tri* tris;
    CoreTri* coreTris;
    AABB* aabbs;
    size_t numTris;
public:
    __host__ DeviceTriBuffer() = delete;
    __host__ DeviceTriBuffer(const HostMeshManager& hostMeshManager) {
        std::vector<Tri> hostTris;
        std::vector<CoreTri> hostCoreTris;
        std::vector<AABB> hostAABBs;

        int i=0;
        for (HostMesh hm : hostMeshManager.getMeshs()) {
            for (const Tri& t : hm.getTris()) {
                hostTris.push_back(t);
                hostCoreTris.push_back(t.coreTri);
                hostAABBs.emplace_back(t.makeAABB());
            }
            i++;
        }

        numTris = hostTris.size();

        size_t size = hostTris.size() * sizeof(Tri);
        size_t coreSize = hostCoreTris.size() * sizeof(CoreTri);
        size_t aabbSize = hostCoreTris.size() * sizeof(AABB);

        cudaError_t errs[4];

        errs[0] = cudaMalloc(&tris, size);
        errs[1] = cudaMalloc(&coreTris, coreSize);
        errs[2] = cudaMalloc(&aabbs, aabbSize);

        errs[3] = cudaMemcpy(tris, hostTris.data(), size, cudaMemcpyHostToDevice);
        errs[4] = cudaMemcpy(coreTris, hostCoreTris.data(), coreSize, cudaMemcpyHostToDevice);
        errs[5] = cudaMemcpy(aabbs, hostAABBs.data(), aabbSize, cudaMemcpyHostToDevice);
    }
    __host__ ~DeviceTriBuffer() {
        printf("freeing");
        cudaFree(tris);
        cudaFree(coreTris);
        cudaFree(aabbs);
    }
    __host__ DeviceTriBuffer(const DeviceTriBuffer& deviceTriBuffer) = delete;
    __host__ DeviceTriBuffer(DeviceTriBuffer&& deviceTriBuffer) = delete;
    __host__ DeviceTriBuffer& operator=(const DeviceTriBuffer& deviceTriBuffer) = delete;
    __host__ DeviceTriBuffer& operator=(DeviceTriBuffer&& deviceTriBuffer) = delete;

    __device__ const Tri& getTri(unsigned int i) const {
        #ifdef DEBUG
        if (i >= numTris) {
            printf("[DEVICE ERROR] in getTri, index out of range");
        }
        #endif
        return tris[i];
    }

    __device__ const CoreTri& getCoreTri(unsigned int i) const {
        #ifdef DEBUG
        if (i >= numTris) {
            printf("[DEVICE ERROR] in getCoreTri, index out of range");
        }
        #endif
        return coreTris[i];
    }

    __device__ const AABB& getAABB(unsigned int i) const {
        #ifdef DEBUG
        if (i >= numTris) {
            printf("[DEVICE ERROR] in getCoreTri, index out of range");
        }
        #endif
        return aabbs[i];
    }

    __device__ __host__ size_t getNumTris() const {
        return numTris;
    }
};