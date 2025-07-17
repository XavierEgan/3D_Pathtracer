#pragma once

#include "Vec3.cuh"

struct Transform3D {
    Vec3 i, j, k;

    __host__ __device__  Transform3D(const Vec3& i, const Vec3& j, const Vec3& k) : i(i), j(j), k(k) {}

    __host__ __device__ friend Vec3 operator*(const Vec3& other, const Transform3D& transform) {
        // transform from local space to global space
        return other.x * transform.i + other.y * transform.j + other.z * transform.k;
    }

    __host__ __device__  Transform3D inverse() const {
        return Transform3D(
            Vec3(i.x, j.x, k.x),
            Vec3(i.y, j.y, k.y),
            Vec3(i.z, j.z, k.z)
        );
    }
};