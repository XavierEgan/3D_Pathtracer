#pragma once

/*  
    Written by Xavier Egan 2025
*/

#include <cmath>
#include <iostream>
#include <type_traits>
#include <optional>
#include <cstdlib>

#include "Vec3.hpp"
#include "Tri.hpp"
#include "rand.hpp"
#include "../Misc/Scene.hpp"

struct TriHit {
    Vec3 intersecPoint;
    float dist;
    Vec3 baryCoords;
    Tri tri;

    TriHit(Vec3 intersecPoint, float dist, Vec3 baryCoords, Tri tri) : intersecPoint(intersecPoint), dist(dist), baryCoords(baryCoords), tri(tri) {}
};

struct Ray {
    Vec3 direction;
    Vec3 origin;

    Ray(Vec3 direction, Vec3 origin) : direction(direction), origin(origin) {}
    Ray(Vec3 direction) : direction(direction), origin(Vec3()) {}
    Ray(float planeX, float planeY, const Scene& scene) {
        float u1 = rand() / (float) RAND_MAX;
        float u2 = rand() / (float) RAND_MAX;

        direction = scene.camera.forward * scene.camera.screenParams.focalLength 
            + scene.camera.up * (planeY + u1 * scene.camera.screenParams.pxHeight) 
            + scene.camera.right * (planeX + u2 * scene.camera.screenParams.pxWidth);
        origin = scene.camera.pos;
    }

    std::optional<TriHit> rayTriIntercept(const Tri& tri) const {
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
            return TriHit(origin + direction * t, t, Vec3(1.0f - (u + v), u, v), tri);
        } else {
            return {};
        }
    }

    std::optional<TriHit> getTriIntersection(const std::vector<Tri> tris) const {
        // store the closest hit so far
        TriHit closestHit = TriHit(Vec3(), 999999999.0f, Vec3(), Tri(Vec3(), Vec3(), Vec3(), 0));
        bool hitFlag = false;

        for (const Tri& tri : tris) {
            std::optional<TriHit> triHit = this->rayTriIntercept(tri);

            if (triHit.has_value()) {
                // we have a hit!
                if (triHit.value().dist < closestHit.dist) {
                    // its the closest one so far!
                    closestHit = triHit.value();
                    hitFlag = true;
                }
            }
        }
        
        if (hitFlag) {
            return closestHit;
        } else {
            // no hit
            return {};
        }
    }

    void bsdfReflect(const Material& material, const TriHit& triHit, unsigned int& localSeed, Vec3& runningAlbedo, Vec3& runningEmission) {
        // get the uv coords of the intersection
        Vec3 triUV = triHit.tri.getUV(triHit.baryCoords);

        Vec3 triAlbedo = material.getAlbedo(triUV.x,triUV.y);
        runningAlbedo *= triAlbedo;

        Vec3 triEmission = triAlbedo * material.emission;
        runningEmission += triEmission;

        // get tri normal
        Vec3 edge1 = triHit.tri.v0 - triHit.tri.v1;
        Vec3 edge2 = triHit.tri.v0 - triHit.tri.v1;
        Vec3 triNormal = (edge1).cross(edge2).normalized();

        // TODO: Normal maps
        Vec3 normalOffset = Vec3(); //material.getNormalOffset(triUV.x,triUV.y);
        Vec3 normal = (triNormal + normalOffset).normalized();

        // create orthonormal basis fro the normal
        Vec3 arbitrary = normal.x < .9 ? Vec3(1,0,0) : Vec3(0,1,0);
        Vec3 tangent = normal.cross(arbitrary).normalized();
        Vec3 bitangent = normal.cross(tangent).normalized();

        // rewrite the ray in terms of the orthonormal basis
        Vec3 tangentRayDirection = (direction.x * tangent + direction.y * normal + direction.z * bitangent).normalized();

        float u1 = randUniform(localSeed);
        float u2 = randUniform(localSeed);

        if (u1 < material.transmission) {
            // we need to refract
            // snels law: ni*sin(thetai) = nr*sin(thetar)
            // thetar = arcsin(ni*sin(thetai)/nr)
            float ni = 1.0f; // air
            
            // apply snels law in i direction
            float iThetaI = std::acos(Vec3(0,1,0).dot(tangentRayDirection));
            float iThetaR = std::asin(ni*std::sin(iThetaI)/material.IOR);
        } else {
            // we need to reflect
            if (u2 < material.roughness) {
                // diffuse reflect
            } else {
                // mirror reflect
            }
        }
    }

};