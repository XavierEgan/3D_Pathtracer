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
#include "rand.cuh"

#include "../Misc/Camera.hpp"

#include "../Misc/DeviceResourceManager/DeviceMaterialManager.cuh"
#include "../Misc/DeviceResourceManager/DeviceScreenBuffer.cuh"
#include "../Misc/DeviceResourceManager/DeviceTriBuffer.cuh"
#include "../Misc/HostResourceManager/HostResourceManager.hpp"
#include "../Misc/PixelOptimisationReport.cuh"

struct TriHit {
    Vec3 intersecPoint;
    float dist;
    Vec3 baryCoords;
    const Tri* tri;
    bool hit;

    __host__ __device__ TriHit() : dist(-1), tri(nullptr), hit(false) {}
    __host__ __device__ TriHit(const Vec3& intersecPoint, float dist, const Vec3& baryCoords, const Tri* tri, bool hit) : intersecPoint(intersecPoint), dist(dist), baryCoords(baryCoords), tri(tri), hit(hit) {}
};

__host__ __device__ static Vec3 getNormalFromOffset(const Vec3& normal, const Vec3& edge1, const Vec3& offset) {
    // since normal is orthogonal to edge1 we can construct a full orthonormal basis from just crossing normal and edge1
    Vec3 tangent = edge1;
    Vec3 bitangent = normal.cross(tangent).normalized();

    Vec3 localVecWithOffset = Vec3(0,0,1) + offset;

    return localVecWithOffset.x * tangent + localVecWithOffset.y * bitangent + localVecWithOffset.z * normal;
}

struct Ray {
    Vec3 direction;
    Vec3 origin;

    __device__ Ray(Vec3 direction, Vec3 origin) : direction(direction), origin(origin) {}
    __device__ Ray(Vec3 direction) : direction(direction), origin(Vec3()) {}
    __device__ Ray(int planeX, int planeY, const Camera& camera, unsigned int& seed) : Ray(planeX, planeY, randUniform(seed), randUniform(seed), camera) {}

    __device__ Ray(int planeX, int planeY, float subPixelOffsetX, float subPixelOffsetY, const Camera& camera) {
        Vec3 forwardComponent = camera.precomputedForwardComponent;
        Vec3 upComponent = camera.up * ((camera.screenParams.heightOnTwo - planeY) + subPixelOffsetY) * camera.screenParams.pxHeight;
        Vec3 rightComponent = camera.right * ((planeX - camera.screenParams.widthOnTwo) + subPixelOffsetX) * camera.screenParams.pxWidth;

        direction = (forwardComponent + upComponent + rightComponent).normalized();
        origin = camera.pos;
    }

    __device__ float getTriHitDist(const CoreTri& tri) const {
        Vec3 edge1 = tri.v1 - tri.v0;
        Vec3 edge2 = tri.v2 - tri.v0;
        Vec3 rayCrossEdge2 = direction.cross(edge2);
        float det = edge1.dot(rayCrossEdge2);

        float inv_det = 1.0 / det;
        Vec3 s = origin - tri.v0;
        float u = inv_det * s.dot(rayCrossEdge2);

        Vec3 sCrossEdge1 = s.cross(edge1);
        float v = inv_det * direction.dot(sCrossEdge1);

        float t = inv_det * edge2.dot(sCrossEdge1);

        bool hit = !(det > -1e-4f && det < 1e-4f) && 
            u >= 0.0f && u <= 1.0f && 
            v >= 0.0f && u + v <= 1.0f && 
            t > 1e-4f;

        return hit ? t : -1.0f;

    }

    __device__ TriHit getTriHit(const Tri& tri) const {
        Vec3 edge1 = tri.coreTri.v1 - tri.coreTri.v0;
        Vec3 edge2 = tri.coreTri.v2 - tri.coreTri.v0;
        Vec3 rayCrossEdge2 = direction.cross(edge2);
        float det = edge1.dot(rayCrossEdge2);

        float inv_det = 1.0 / det;
        Vec3 s = origin - tri.coreTri.v0;
        float u = inv_det * s.dot(rayCrossEdge2);

        Vec3 sCrossEdge1 = s.cross(edge1);
        float v = inv_det * direction.dot(sCrossEdge1);

        float t = inv_det * edge2.dot(sCrossEdge1);

        bool hit = !(det > -1e-4f && det < 1e-4f) && 
            u >= 0.0f && u <= 1.0f && 
            v >= 0.0f && u + v <= 1.0f && 
            t > 1e-4f;
        
        return TriHit(origin + direction * t, t, Vec3(u, v, 1 - u - v), &tri, hit);
    }

    __device__ TriHit getTriIntersection(const DeviceTriBuffer& deviceTriBuffer, const PixelOptimisationReport& pixelOptimisationReport, bool cameraRay) const {
        if (cameraRay && pixelOptimisationReport.isCoherentPixel) {
            return getTriHit(pixelOptimisationReport.coherentTri);
        }

        float closestDist = 999999.0f;
        int closestTriIndex =  -1;

        for (int i = 0; i < deviceTriBuffer.getNumTris(); i++) {
            const CoreTri& tri = deviceTriBuffer.getCoreTri(i);

            float dist = this->getTriHitDist(tri);

            if (dist > 0.0f && dist < closestDist) {
                closestDist = dist;
                closestTriIndex = i;
            }
        }
        
        if (closestTriIndex == -1) {
            return TriHit();
        } else {
            return this->getTriHit(deviceTriBuffer.getTri(closestTriIndex));
        }
    }

    __device__ void refractReflect(Vec3& shiftedTriNormal, unsigned int& localSeed, const TriHit& triHit, const DeviceMaterial& material) {
        // we need to refract
        /*
        source:
            - https://shaderbits.com/blog/optimized-snell-s-law-refraction
            - https://www.cse.chalmers.se/edu/year/2013/course/TDA361/refractionvector.pdf
        */
        float ni, nr;
        Vec3 refractionNormal;
        bool facingFront = direction.dot(shiftedTriNormal) < 0;

        ni = 1.0f * facingFront + material.IOR * !facingFront;
        nr = 1.0f * !facingFront + material.IOR * facingFront;

        shiftedTriNormal *= 1 - (2 * !facingFront);

        // remembering that a.b = |a||b|*cos(theta)
        float cosThetaI = -refractionNormal.dot(direction); // |normal| = 1 and |incident| = 1

        float n = ni/nr;
        float discriminant = 1 - n * n * (1 - cosThetaI * cosThetaI);

        if (discriminant < 1e-4f) {
            // TIR
            direction= (direction - 2 * refractionNormal.dot(direction) * refractionNormal).normalized();
            
        } else {
            // refraction
            direction = (n * direction + ((n * cosThetaI) - sqrtf(discriminant)) * refractionNormal).normalized();
        }
    }

    __device__ void diffuseReflect(Vec3& shiftedTriNormal, unsigned int& localSeed, const TriHit& triHit) {
        float u1 = randUniform(localSeed);
        float u2 = randUniform(localSeed);

        float r = sqrtf(u1);
        float phi = 2.0f * 3.1415926 * u2;

        Vec3 localRay = Vec3(
            r * cosf(phi),
            r * sinf(phi),
            sqrt(1.0f - u1)
        );

        // create an orthonormal basis
        Vec3 arbitrary = shiftedTriNormal + Vec3(.1, .1, .1);
        Vec3 tangent = shiftedTriNormal.cross(arbitrary).normalized();
        Vec3 bitangent = shiftedTriNormal.cross(tangent).normalized();

        direction = localRay.x * tangent + localRay.y * bitangent + localRay.z * shiftedTriNormal;
    }

    __device__ void mirrorReflect(Vec3& shiftedTriNormal) {
        direction = (direction - 2*(direction.dot(shiftedTriNormal))*shiftedTriNormal).normalized();
    }

    __device__ void bsdfReflect(const DeviceMaterial& material, const TriHit& triHit, unsigned int& localSeed, Vec3& runningAlbedo) {
        float u1 = randUniform(localSeed);
        float u2 = randUniform(localSeed);

        bool refract = u1 < material.transmission;
        bool diffuse = u2 < powf(material.roughness, 1.0f/5.0f);

        int type = !refract * (diffuse + 1); // get the type in a branchless way

        Vec3 UV = triHit.tri->getUV(triHit.baryCoords);

        Vec3 edge1 = (triHit.tri->coreTri.v1 - triHit.tri->coreTri.v0).normalized();
        Vec3 normalOffset = material.getNormalOffset(UV.x, UV.y);
        Vec3 shiftedTriNormal = getNormalFromOffset(triHit.tri->normal, edge1, normalOffset);
        
        runningAlbedo *= material.getAlbedo(UV.x, UV.y);

        switch (type) {
            case 0:
                refractReflect( shiftedTriNormal, localSeed, triHit, material );
                break;
            case 1:
                mirrorReflect( shiftedTriNormal );
                break;
            case 2:
                diffuseReflect( shiftedTriNormal, localSeed, triHit );
                break;
        }

        // set origin after direction so we can epsilon shift to avoid intersecting the same triangle again
        origin = (triHit.intersecPoint).epsilonShift(direction);
    }
};