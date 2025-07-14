#pragma once

/*  
    Written by Xavier Egan 2025
*/

#include <cmath>
#include <iostream>
#include <type_traits>

#include "Vec3.cuh"
#include "..\Misc\MaterialID.hpp"

struct Tri {
    Vec3 v0, v1, v2;

    Vec3 v0uv, v1uv, v2uv;

    MaterialID materialID;

    __host__ __device__ Tri() : materialID(MaterialID(99999)) {};

    __host__ __device__ Tri(Vec3 v0, Vec3 v1, Vec3 v2, MaterialID materialID) : v0(v0), v1(v1), v2(v2), v0uv(Vec3()), v1uv(Vec3()), v2uv(Vec3()), materialID(materialID) {}

    __host__ __device__ Tri(Vec3 v0, Vec3 v1, Vec3 v2, Vec3 v0uv, Vec3 v1uv, Vec3 v2uv, MaterialID materialID) : v0(v0), v1(v1), v2(v2), v0uv(v0uv), v1uv(v1uv), v2uv(v2uv), materialID(materialID) {}

    __host__ __device__ Vec3 getUV(const Vec3& baryCoords) const {
        return v0uv * baryCoords.x + v1uv * baryCoords.y + v2uv * baryCoords.z;
    }

    __host__ __device__ Vec3 normal() const {
        return (v0 - v1).cross(v0 - v2).normalized();
    }
};