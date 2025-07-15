#pragma once

#include <vector>
#include "HostMesh.hpp"

class HostMeshManager {
    std::vector<HostMesh> meshs;

public:  
    HostMeshManager() = default;

    void registerMesh(const HostMesh& hostMesh) {
        meshs.push_back(hostMesh);
    }

    std::vector<HostMesh> getMeshs() const {
        return meshs;
    }
};