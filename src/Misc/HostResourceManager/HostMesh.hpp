#pragma once

#include <vector>
#include "../../Math/Tri.cuh"

class HostMesh {
    std::vector<Tri> tris;

public:  
    HostMesh() : tris(std::vector<Tri>()) {}
    HostMesh(std::vector<Tri> tris) : tris(tris) {}

    std::vector<Tri> getTris() {
        return tris;
    }

    Tri* getTrisPointer() {
        return tris.data();
    }
};