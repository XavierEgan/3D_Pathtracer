#pragma once

#include <vector>

#include "../Math/Tri.hpp"

struct Mesh {
    std::vector<Tri> tris;
    unsigned int materialId;

    Mesh(std::vector<Tri> tris, unsigned int materialId) : tris(tris), materialId(materialId) {}
};