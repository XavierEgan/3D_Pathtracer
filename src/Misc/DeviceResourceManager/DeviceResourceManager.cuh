#pragma once

#include <vector>
#include "../Math/Tri.cuh"
#include "DeviceMaterialManager.cuh"
#include "DeviceTriBuffer.cuh"
#include "HostResourceManager/HostResourceManager.hpp"

class DeviceResourceManager {
public:
    DeviceMaterialManager deviceMaterialManager;
    DeviceTriBuffer deviceMeshManager;
    DeviceResourceManager() = delete;
    DeviceResourceManager(const HostResourceManager& hostResourceManager) : 
        deviceMaterialManager(DeviceMaterialManager(hostResourceManager.hostMaterialManager)),
        deviceMeshManager(DeviceTriBuffer(hostResourceManager.hostMeshManager))
    {}
};