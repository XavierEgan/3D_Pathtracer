#pragma once

#include <vector>

#include "../Math/Tri.cuh"

struct Mesh {
    std::vector<Tri> tris;
    unsigned int materialId;

    Mesh(std::vector<Tri> tris, unsigned int materialId) : tris(tris), materialId(materialId) {}
};