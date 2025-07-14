#pragma once

#include <vector>
#include "../Math/Tri.cuh"
#include "HostMesh.hpp"

class HostMeshManager {
    std::vector<HostMesh> meshs;

public:  
    HostMeshManager() : meshs(std::vector<HostMesh>()) {}
    HostMeshManager(std::vector<HostMesh> meshs) : meshs(meshs) {}

    void registerMesh(const HostMesh& hostMesh) {
        meshs.push_back(hostMesh);
    }

    std::vector<HostMesh> getMeshs() {
        return meshs;
    }
};