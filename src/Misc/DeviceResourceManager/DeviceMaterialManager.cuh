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
    DeviceMaterialManager() = delete;
    DeviceMaterialManager(const HostMaterialManager& hostMaterialManager) {
        const std::vector<HostMaterial> hostMaterials = hostMaterialManager.getMaterials();
        numMaterials = hostMaterials.size();

        std::vector<DeviceMaterial> deviceMaterials;

        for (HostMaterial hm : hostMaterials) {
            deviceMaterials.emplace_back(hm);
        }

        size_t size = deviceMaterials.size() * sizeof(DeviceMaterial);
        cudaError_t err = cudaMalloc(&materials, size);
        if (err != cudaSuccess) {
            printf("ERROR in cudaMalloc in DeviceMaterialManager");
        }

        cudaError_t err = cudaMemcpy(materials, deviceMaterials.data(), size, cudaMemcpyHostToDevice);
        if (err != cudaSuccess) {
            printf("ERROR in cudaMemcpy in DeviceMaterialManager");
        }
    }
    ~DeviceMaterialManager() {
        cudaFree(materials);
    }
    DeviceMaterialManager(const DeviceMaterialManager& deviceMaterialManager) = delete;
    DeviceMaterialManager(DeviceMaterialManager&& deviceMaterialManager) = delete;
    DeviceMaterialManager& operator=(const DeviceMaterialManager& deviceMaterialManager) = delete;
    DeviceMaterialManager& operator=(DeviceMaterialManager&& deviceMaterialManager) = delete;
};