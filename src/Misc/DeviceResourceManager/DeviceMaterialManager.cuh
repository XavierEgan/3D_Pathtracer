#pragma once

#include <vector>

#include "../MaterialID.hpp"
#include "../Math/Tri.cuh"
#include "DeviceMaterial.cuh"
#include "../HostResourceManager/HostMaterialManager.hpp"

class DeviceMaterialManager {
    DeviceMaterial* materials;
    size_t numMaterials;

public:
    __host__ DeviceMaterialManager() = delete;
    __host__ DeviceMaterialManager(const HostMaterialManager& hostMaterialManager) {
        const std::vector<HostMaterial> hostMaterials = hostMaterialManager.getMaterials();
        numMaterials = hostMaterials.size();

        //hostMaterialManager.print();

        std::vector<DeviceMaterial> deviceMaterials;

        for (const HostMaterial& hm : hostMaterials) {
            deviceMaterials.emplace_back(hm);
        }

        size_t size = deviceMaterials.size() * sizeof(DeviceMaterial);
        cudaError_t err = cudaMalloc(&materials, size);
        if (err != cudaSuccess) {
            printf("ERROR in cudaMalloc in DeviceMaterialManager");
        }

        err = cudaMemcpy(materials, deviceMaterials.data(), size, cudaMemcpyHostToDevice);
        if (err != cudaSuccess) {
            printf("ERROR in cudaMemcpy in DeviceMaterialManager");
        }
    }
    __host__ ~DeviceMaterialManager() {
        cudaFree(materials);
    }
    __host__ DeviceMaterialManager(const DeviceMaterialManager& deviceMaterialManager) = delete;
    __host__ DeviceMaterialManager(DeviceMaterialManager&& deviceMaterialManager) = delete;
    __host__ DeviceMaterialManager& operator=(const DeviceMaterialManager& deviceMaterialManager) = delete;
    __host__ DeviceMaterialManager& operator=(DeviceMaterialManager&& deviceMaterialManager) = delete;

    __device__ DeviceMaterial& getMaterial(MaterialID materialID) const {
        if (materialID.materialID >= numMaterials) {
            printf("[KERNEL] Error, materialID out of range");
        }
        return materials[materialID.materialID];
    }

    __device__ void print() {
        for (int i=0; i < numMaterials; i++) {
            getMaterial(MaterialID(i)).print();
        }
    }
};