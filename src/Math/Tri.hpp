#pragma once

/*  
    Written by Xavier Egan 2025
*/

#include <cmath>
#include <iostream>
#include <type_traits>

#include "Vec3.hpp"

struct Tri {
    Vec3 v0, v1, v2;

    Vec3 v0uv, v1uv, v2uv;

    uint16_t materialID;

    Tri(Vec3 v0, Vec3 v1, Vec3 v2, uint16_t materialID) : v0(v0), v1(v1), v2(v2), v0uv(Vec3()), v1uv(Vec3()), v2uv(Vec3()), materialID(materialID) {}

    Tri(Vec3 v0, Vec3 v1, Vec3 v2, Vec3 v0uv, Vec3 v1uv, Vec3 v2uv, uint16_t materialID) : v0(v0), v1(v1), v2(v2), v0uv(v0uv), v1uv(v1uv), v2uv(v2uv), materialID(materialID) {}

    Vec3 getUV(Vec3 baryCoords) {
        return v0uv * baryCoords.x + v1uv * baryCoords.y + v2uv * baryCoords.z;
    }
};