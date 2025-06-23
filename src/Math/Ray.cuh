#pragma once

/*  
    Written by Xavier Egan 2025
*/

#include <cuda_runtime.h>
#include <iostream>
#include <type_traits>
#include <optional>
#include <cstdlib>

#include "Vec3.cuh"
#include "Tri.cuh"
#include "rand.cuh"
#include "../Misc/Scene.cuh"

struct TriHit {
    Vec3 intersecPoint;
    float dist;
    Vec3 baryCoords;
    Tri tri;
    bool hit;

    __host__ __device__ TriHit() : hit(false) {}
    __host__ __device__ TriHit(Vec3 intersecPoint, float dist, Vec3 baryCoords, Tri tri) : intersecPoint(intersecPoint), dist(dist), baryCoords(baryCoords), tri(tri), hit(true) {}
};

struct Ray {
    Vec3 direction;
    Vec3 origin;

    __host__ __device__ Ray(Vec3 direction, Vec3 origin) : direction(direction), origin(origin) {}
    __host__ __device__ Ray(Vec3 direction) : direction(direction), origin(Vec3()) {}
    __host__ __device__ Ray(float planeX, float planeY, const Scene& scene, unsigned int& seed) {
        float u1 = randUniform(seed);
        float u2 = randUniform(seed);

        direction = scene.camera.forward * scene.camera.screenParams.focalLength 
            + scene.camera.up * (planeY + u1 * scene.camera.screenParams.pxHeight) 
            + scene.camera.right * (planeX + u2 * scene.camera.screenParams.pxWidth);
        origin = scene.camera.pos;
    }

    __host__ __device__ TriHit rayTriIntercept(const Tri& tri) const {
        //Möller–Trumbore intersection algorithm
        Vec3 edge1 = tri.v1 - tri.v0;
        Vec3 edge2 = tri.v2 - tri.v0;
        Vec3 rayCrossEdge2 = direction.cross(edge2);
        float det = edge1.dot(rayCrossEdge2);

        if (det > -1e-4f && det < 1e-4f) {
            return TriHit();
        }

        float inv_det = 1.0 / det;
        Vec3 s = origin - tri.v0;
        float u = inv_det * s.dot(rayCrossEdge2);

        if (u < 0.0f || u > 1.0f) {
            return TriHit();
        }

        Vec3 sCrossEdge1 = s.cross(edge1);
        float v = inv_det * direction.dot(sCrossEdge1);

        if (v < 0.0f || u + v > 1.0f) {
            return TriHit();
        }

        float t = inv_det * edge2.dot(sCrossEdge1);

        if (t > 1e-4f) {
            return TriHit(origin + direction * t, t, Vec3(1.0f - (u + v), u, v), tri);
        } else {
            return TriHit();
        }
    }

    __host__ __device__ TriHit getTriIntersection(TriBuffer tris) const {
        // store the closest hit so far
        TriHit closestHit = TriHit(Vec3(), 999999999.0f, Vec3(), Tri(Vec3(), Vec3(), Vec3(), 0));
        bool hitFlag = false;

        for (int i = 0; i < tris.size; i++) {
            const Tri tri = tris[i];

            TriHit triHit = this->rayTriIntercept(tri);

            if (triHit.hit) {
                // we have a hit!
                if (triHit.dist < closestHit.dist) {
                    // its the closest one so far!
                    closestHit = triHit;
                    hitFlag = true;
                }
            }
        }
        
        if (hitFlag) {
            return closestHit;
        } else {
            // no hit
            return TriHit();
        }
    }

    __host__ __device__ void bsdfReflect(const Material& material, const TriHit& triHit, unsigned int& localSeed, Vec3& runningAlbedo, Vec3& runningEmission) {
        /*
            normal is up because it was easier to derrive the math
        */

        // set origin of the ray to the intersection point
        origin = triHit.intersecPoint;

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

        // transpose the basis so it works idk
        Vec3 invTangent = Vec3(tangent.x, normal.x, bitangent.x);
        Vec3 invNormal = Vec3(tangent.y, normal.y, bitangent.y);
        Vec3 invBitangent = Vec3(tangent.z, normal.z, bitangent.z);

        // rewrite the ray in terms of the orthonormal basis 
        Vec3 tangentRayDirection = (direction.x * invTangent + direction.y * invNormal + direction.z * invBitangent).normalized();

        float u1 = randUniform(localSeed);
        float u2 = randUniform(localSeed);

        if (u1 < material.transmission) {
            // we need to refract
            // snels law: ni*sin(thetai) = nr*sin(thetar)
            // thetar = arcsin(ni*sin(thetai)/nr)
            float ni = 1.0f; // air
            
            // apply snels law in i direction
            Vec3 tangentRayDirectionIJ = Vec3(tangentRayDirection.x, tangentRayDirection.y, 0.0f);
            Vec3 tangentRayDirectionKJ = Vec3(0.0f, tangentRayDirection.y, tangentRayDirection.z);

            float iThetaI = acosf(Vec3(0,1,0).dot(tangentRayDirectionIJ));
            float iThetaR = asinf(ni*sinf(iThetaI)/material.IOR);
            int iThetaRSin = tangentRayDirection.x > 0 ? 1 : -1; // if its +ve in the direction of i then  its +ve, otherwise -ve

            // apply snells law in the k direction
            float kThetaI = acosf(Vec3(0,1,0).dot(tangentRayDirectionKJ));
            float kThetaR = asinf(ni*sinf(kThetaI)/material.IOR);
            int kThetaRSin = tangentRayDirection.z > 0 ? 1 : -1; // if its +ve in the direction of i then  its +ve, otherwise -ve

            float theta = (1 - iThetaR) * iThetaRSin;
            float alpha = (1 - kThetaR) * kThetaRSin;
            float sinAlpha = sinf(alpha);

            Vec3 refractedRayDirection = Vec3(
                sinAlpha * cosf(theta),
                sinAlpha * sinf(theta),
                cosf(alpha)
            ).normalized();

            direction = refractedRayDirection.epsilonShift();
        } else {
            // we need to reflect
            if (u2 < material.roughness) {
                // diffuse reflect
                // cosine weighted sampling
                float r = sqrtf(u1);
                float phi = 2.0f * 3.1415926 * u2;

                Vec3 localRay = Vec3(
                    r * cosf(phi),
                    r * sinf(phi),
                    sqrt(1.0f - u1)
                );

                direction = (localRay.x * tangent + localRay.y * normal + localRay.z * bitangent).normalized();
            } else {
                // mirror reflect
                // R = I - 2(ProjN(I))
                direction = (direction - 2*(direction.dot(normal))).normalized();
            }
        }
    }
};