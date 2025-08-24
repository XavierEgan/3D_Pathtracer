#pragma once

#include <vector>

#include "Math/Tri.cuh"

struct Mesh {
    std::vector<Tri> tris;

    Mesh(std::vector<Tri> tris) : tris(tris) {}
};