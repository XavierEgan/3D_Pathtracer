#pragma once

/*  
    Written by Xavier Egan 2025
*/

#include <cmath>
#include <iostream>
#include <type_traits>

#include "Vec3.cuh"
#include "..\Misc\MaterialID.hpp"

struct AABB {
    Vec3 min;
    Vec3 max;
    AABB() {}
    AABB(Vec3 min, Vec3 max) : min(min), max(max) {}
};

struct CoreTri {
    Vec3 v0, v1, v2;

    __host__ __device__ CoreTri() {}
    __host__ __device__ CoreTri(Vec3 v0, Vec3 v1, Vec3 v2) : v0(v0), v1(v1), v2(v2) {}
};

struct Tri {
    CoreTri coreTri;

    Vec3 v0uv, v1uv, v2uv;

    Vec3 normal;

    MaterialID materialID;

    __host__ __device__ Tri() : materialID(MaterialID(99999)) {};

    __host__ __device__ Tri(Vec3 v0, Vec3 v1, Vec3 v2, MaterialID materialID) : coreTri(CoreTri(v0, v1, v2)), v0uv(Vec3()), v1uv(Vec3()), v2uv(Vec3()), materialID(materialID) {
        Vec3 g_edge1 = v1 - v0;
        Vec3 g_edge2 = v2 - v0;
        normal = (g_edge1).cross(g_edge2).normalized();
    }

    __host__ __device__ Tri(Vec3 v0, Vec3 v1, Vec3 v2, Vec3 v0uv, Vec3 v1uv, Vec3 v2uv, MaterialID materialID) : coreTri(CoreTri(v0, v1, v2)), v0uv(v0uv), v1uv(v1uv), v2uv(v2uv), materialID(materialID) {
        Vec3 g_edge1 = v1 - v0;
        Vec3 g_edge2 = v2 - v0;
        normal = (g_edge1).cross(g_edge2).normalized();
    }

    __host__ __device__ Vec3 getUV(const Vec3& baryCoords) const {
        return v0uv * baryCoords.x + v1uv * baryCoords.y + v2uv * baryCoords.z;
    }

    __host__ __device__ AABB makeAABB() const {
        Vec3 min = Vec3(
            fminf(coreTri.v0.x, fminf(coreTri.v1.x, coreTri.v2.x)),
            fminf(coreTri.v0.y, fminf(coreTri.v1.y, coreTri.v2.y)),
            fminf(coreTri.v0.z, fminf(coreTri.v1.z, coreTri.v2.z))
        );

        Vec3 max = Vec3(
            fmaxf(coreTri.v0.x, fmaxf(coreTri.v1.x, coreTri.v2.x)),
            fmaxf(coreTri.v0.y, fmaxf(coreTri.v1.y, coreTri.v2.y)),
            fmaxf(coreTri.v0.z, fmaxf(coreTri.v1.z, coreTri.v2.z))
        );

        return AABB(min, max);
    }

    // __host__ __device__ Vec3 normal() const {
    //     return (v0 - v1).cross(v0 - v2).normalized();
    // }
};