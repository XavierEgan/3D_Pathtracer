#pragma once

#include <vector>
#include "../Math/Tri.cuh"
#include "../HostResourceManager/HostResourceManager.hpp"
#include "../Camera.hpp"

#include "DeviceMaterialManager.cuh"
#include "DeviceTriBuffer.cuh"
#include "DeviceScreenBuffer.cuh"

class DeviceResourceManager {
public:
    DeviceMaterialManager deviceMaterialManager;
    DeviceTriBuffer deviceTriBuffer;
    DeviceScreenBuffer deviceScreenBuffer;

    __host__ DeviceResourceManager() = delete;
    __host__ DeviceResourceManager(const HostResourceManager& hostResourceManager, const ScreenParams& screenParams) : 
        deviceMaterialManager(DeviceMaterialManager(hostResourceManager.hostMaterialManager)),
        deviceTriBuffer(DeviceTriBuffer(hostResourceManager.hostMeshManager)),
        deviceScreenBuffer(DeviceScreenBuffer(screenParams))
    {}
};