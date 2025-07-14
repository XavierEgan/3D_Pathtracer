#pragma once

#include <vector>
#include "HostMaterialManager.hpp"
#include "HostMeshManager.hpp"

class HostResourceManager {
public:
    HostMaterialManager hostMaterialManager;
    HostMeshManager hostMeshManager;
    HostResourceManager() = default;
};