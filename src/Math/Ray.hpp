#pragma once

#include <iostream>
#include <optional>

#include "Vec3.hpp"
#include "Tri.hpp"

static constexpr float EPSILON = 1e-4f;

struct RayHit {
    Vec3 point;
    float distance;

    Vec3 baryCoords;

    RayHit() : point(Vec3()), distance(0.0f), baryCoords{Vec3()} {}
    RayHit(const Vec3& point, float distance, const Vec3& baryCoords) : point(point), distance(distance), baryCoords(baryCoords) {}
};

struct Ray {
    Vec3 direction;
    Vec3 origin;

    Ray() : direction(Vec3()), origin(Vec3()) {}
    Ray(Vec3 direction, Vec3 origin) : direction(direction), origin(origin) {}

    // tri verts should be in GLOBAL space
    std::optional<RayHit> rayTriIntercept(Tri tri) const {
        //Möller–Trumbore intersection algorithm
        Vec3 edge1 = tri.p2 - tri.p1;
        Vec3 edge2 = tri.p3 - tri.p1;
        Vec3 rayCrossEdge2 = direction.cross(edge2);
        float det = edge1.dot(rayCrossEdge2);

        if (det > -EPSILON && det < EPSILON) {
            return {};
        }

        float inv_det = 1.0 / det;
        Vec3 s = origin - tri.p1;
        float u = inv_det * s.dot(rayCrossEdge2);

        if (u < 0.0f || u > 1.0f) {
            return {};
        }

        Vec3 sCrossEdge1 = s.cross(edge1);
        float v = inv_det * direction.dot(sCrossEdge1);

        if (v < 0.0f || u + v > 1.0f) {
            return {};
        }

        float t = inv_det * edge2.dot(sCrossEdge1);

        if (t > EPSILON) {
            return RayHit(origin + direction * t, t, Vec3(1.0f - (u + v), u, v));
        } else {
            return {};
        }
    }
};