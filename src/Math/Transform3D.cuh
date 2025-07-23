#pragma once

/*  
    Written by Xavier Egan 2025
*/

#include <iostream>
#include <type_traits>
#include <optional>
#include <cstdlib>

#include "Vec3.cuh"
#include "Tri.cuh"
#include "Rand.cuh"

struct Transform3D {
    Vec3 i, j, k, origin;

    Transform3D(Vec3 i, Vec3 j, Vec3 k, Vec3 origin) : i(i), j(j), k(k), origin(origin) {}
    Transform3D(Vec3 i, Vec3 j, Vec3 k) : Ray(i, j, k, Vec3()) {}
    Transform3D() : Ray(Vec3(1.0f, 0.0f, 0.0f), Vec3(0.0f, 1.0f, 0.0f), Vec3(0.0f, 0.0f, 1.0f), Vec3()) {}

    Vec3 operator*(Vec3 other) {
        // local to global
        return other.x * i + other.y * j + other.z * k + offset;
    }

    Transform3D inverse() {
        i = Vec3(i.x, j.x, k.x);
        j = Vec3(i.y, j.y, k.y);
        k = Vec3(i.z, j.z, k.z);
        origin *= -1;
    }

    Transform3D& rotate(float theta) {
        theta = M_PI;
        
    }

    static Transform3D orthonormalBasis(Vec3 normal) {
        Vec3 normal = triNormal;
        Vec3 arbitrary = normal.x > 0.9f ? Vec3(0.0f, 1.0f, 0.0f) : Vec3(1.0f, 0.0f, 0.0f);
        Vec3 tangent = arbitrary.cross(normal);
        Vec3 bitangent = normal.cross(tangent);
        tangent.normalize();
        bitangent.normalize();
    }
}