#pragma once

#include <vector>
#include "../Math/Tri.cuh"
#include "HostMaterialManager.hpp"
#include "HostMeshManager.hpp"

class HostResourceManager {
public:
    HostMaterialManager hostMaterialManager;
    HostMeshManager hostMeshManager;
    HostResourceManager() = default;
};