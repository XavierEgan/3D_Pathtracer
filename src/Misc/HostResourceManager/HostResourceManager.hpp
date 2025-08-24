#pragma once

#include <vector>
#include "Misc/HostResourceManager/HostMaterialManager.hpp"
#include "Misc/HostResourceManager/HostMeshManager.hpp"

class HostResourceManager {
public:
    HostMaterialManager hostMaterialManager;
    HostMeshManager hostMeshManager;
    HostResourceManager() = default;
};