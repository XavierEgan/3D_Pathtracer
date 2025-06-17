#pragma once

/*  
    Written by Xavier Egan 2025
*/

#include <cmath>
#include <iostream>
#include <type_traits>
#include <optional>

#include "src\Math\Vec3.hpp"
#include "src\Math\Tri.hpp"

struct RayHit {
    Vec3 intersecPoint;
    float dist;
    Vec3 baryCoords;

    RayHit(Vec3 intersecPoint, float dist, Vec3 baryCoords) : intersecPoint(intersecPoint), dist(dist), baryCoords(baryCoords) {}
};

struct Ray {
    Vec3 direction;
    Vec3 origin;

    Ray(Vec3 direction, Vec3 origin) : direction(direction), origin(origin) {}
    Ray(Vec3 direction) : direction(direction), origin(Vec3()) {}

    std::optional<RayHit> rayTriIntercept(Tri& tri) const {
        //Möller–Trumbore intersection algorithm
        Vec3 edge1 = tri.v1 - tri.v0;
        Vec3 edge2 = tri.v2 - tri.v0;
        Vec3 rayCrossEdge2 = direction.cross(edge2);
        float det = edge1.dot(rayCrossEdge2);

        if (det > -1e-4f && det < 1e-4f) {
            return {};
        }

        float inv_det = 1.0 / det;
        Vec3 s = origin - tri.v0;
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

        if (t > 1e-4f) {
            return RayHit(origin + direction * t, t, Vec3(1.0f - (u + v), u, v));
        } else {
            return {};
        }
    }
};