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
#include "../Misc/DeviceResourceManager/DevicePerformance.cuh"
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

struct _TriDist {
    float dist;
    float u;
    float v;
    __device__ _TriDist() : dist(999999999.0f) {};
    __device__ _TriDist(float dist, float u, float v) : dist(dist), u(u), v(v) {}
};

__device__ void swap(float& a, float& b) {
    float t = a;
    a = b;
    b = t;
}

__host__ __device__ static Vec3 getNormalFromOffset(const Vec3& triNormal, const Vec3& edge1, const Vec3& offset) {
    // since normal is orthogonal to edge1 we can construct a full orthonormal basis from just crossing normal and edge1
    Vec3 normal = triNormal;
    Vec3 absn = Vec3(fabs(normal.x), fabs(normal.y), fabs(normal.z));
    Vec3 ref = (absn.x <= absn.y && absn.x <= absn.z) ? Vec3(1,0,0)
    : (absn.y <= absn.z) ? Vec3(0,1,0)
    : Vec3(0,0,1);
    Vec3 tangent = ref.cross(normal);
    Vec3 bitangent = normal.cross(tangent);

    Vec3 localVecWithOffset = Vec3(0,0,1) + offset;

    return localVecWithOffset.x * tangent + localVecWithOffset.y * bitangent + localVecWithOffset.z * normal;
}

struct Ray {
    Vec3 direction;
    Vec3 origin;
    Vec3 invDir;
    int3 sign;

    __device__ void _precomputeStuff() {
        invDir = 1/direction;
        sign.x = invDir.x < 0;
        sign.y = invDir.y < 0;
        sign.z = invDir.z < 0;
    }

    __device__ Ray(Vec3 direction, Vec3 origin) : direction(direction), origin(origin) {_precomputeStuff();}
    __device__ Ray(Vec3 direction) : direction(direction), origin(Vec3()) {_precomputeStuff();}
    __device__ Ray(int planeX, int planeY, const Camera& camera, unsigned int& seed) : Ray(planeX, planeY, randUniform(seed), randUniform(seed), camera) {_precomputeStuff();}

    __device__ Ray(int planeX, int planeY, float subPixelOffsetX, float subPixelOffsetY, const Camera& camera) {
        Vec3 forwardComponent = camera.precomputedForwardComponent;
        Vec3 upComponent = camera.up * ((camera.screenParams.heightOnTwo - planeY) + subPixelOffsetY) * camera.screenParams.pxHeight;
        Vec3 rightComponent = camera.right * ((planeX - camera.screenParams.widthOnTwo) + subPixelOffsetX) * camera.screenParams.pxWidth;

        direction = (forwardComponent + upComponent + rightComponent).normalized();
        origin = camera.pos;
        _precomputeStuff();
    }

    __device__ __forceinline__ bool intersectsAABB(const AABB& aabb) const {
        //https://www.scratchapixel.com/lessons/3d-basic-rendering/minimal-ray-tracer-rendering-simple-shapes/ray-box-intersection.html

        float tmin = (aabb.min.x - origin.x) / direction.x;
        float tmax = (aabb.max.x - origin.x) / direction.x;

        if (tmin > tmax) swap(tmin, tmax);

        float tymin = (aabb.min.y - origin.y) / direction.y;
        float tymax = (aabb.max.y - origin.y) / direction.y;

        if (tymin > tymax) swap(tymin, tymax);

        if ((tmin > tymax) || (tymin > tmax))
            return false;

        if (tymin > tmin) tmin = tymin;
        if (tymax < tmax) tmax = tymax;

        float tzmin = (aabb.min.z - origin.z) / direction.z;
        float tzmax = (aabb.max.z - origin.z) / direction.z;

        if (tzmin > tzmax) swap(tzmin, tzmax); 

        if ((tmin > tzmax) || (tzmin > tmax)) 
            return false; 

        if (tzmin > tmin) tmin = tzmin; 
        if (tzmax < tmax) tmax = tzmax; 

        return true;
    }

    __device__ __forceinline__ _TriDist getTriHitDist(const CoreTri& tri) const {
        Vec3 edge1 = tri.v1 - tri.v0;
        Vec3 edge2 = tri.v2 - tri.v0;
        Vec3 rayCrossEdge2 = direction.cross(edge2);
        float det = edge1.dot(rayCrossEdge2);

        float inv_det = 1.0f / det;
        Vec3 s = origin - tri.v0;
        float u = inv_det * s.dot(rayCrossEdge2);

        Vec3 sCrossEdge1 = s.cross(edge1);
        float v = inv_det * direction.dot(sCrossEdge1);

        float t = inv_det * edge2.dot(sCrossEdge1);

        bool hit = !(det > -1e-4f && det < 1e-4f) && 
            u >= 0.0f && u <= 1.0f && 
            v >= 0.0f && u + v <= 1.0f && 
            t > 1e-4f;

        t = hit ? t : -1.0f;

        return _TriDist(t, u, v);
    }

    __device__ __forceinline__ TriHit getTriHit(const Tri& tri) const {
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

    __device__ TriHit getTriIntersection(
        const DeviceTriBuffer& deviceTriBuffer, 
        const PixelOptimisationReport& pixelOptimisationReport, 
        bool cameraRay
        #ifdef REPORT_PERFORMANCE
        , DevicePerformance& devicePerformance
        #endif
    ) const {
        if (cameraRay && pixelOptimisationReport.isCoherentPixel) {
            #ifdef REPORT_PERFORMANCE
            devicePerformance.incrimentRayTriIntersecs();
            #endif
            return getTriHit(pixelOptimisationReport.coherentTri);
        }

        _TriDist closestDist = _TriDist();
        int closestTriIndex =  -1;

        for (int i = 0; i < deviceTriBuffer.getNumTris(); i++) {
            const AABB& aabb = deviceTriBuffer.getAABB(i);

            if (!intersectsAABB(aabb)) {
                continue;
            }

            const CoreTri& tri = deviceTriBuffer.getCoreTri(i);

            _TriDist dist = this->getTriHitDist(tri);
            #ifdef REPORT_PERFORMANCE
            devicePerformance.incrimentRayTriIntersecs();
            #endif

            if (dist.dist > 0.0f && dist.dist < closestDist.dist) {
                closestDist = dist;
                closestTriIndex = i;
            }
        }
        
        if (closestTriIndex == -1) {
            return TriHit();
        } else {
            return TriHit(
                origin + direction * closestDist.dist, 
                closestDist.dist, 
                Vec3(closestDist.u, closestDist.v, 1 - closestDist.u - closestDist.v),
                &deviceTriBuffer.getTri(closestTriIndex),
                true
            );
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
        bool facingFront = direction.dot(shiftedTriNormal) < 0;

        ni = facingFront ? 1.0f : material.IOR;
        nr = facingFront ? material.IOR : 1.0f;

        shiftedTriNormal *= facingFront ? 1 : -1;

        // remembering that a.b = |a||b|*cos(theta)
        float cosThetaI = -shiftedTriNormal.dot(direction); // |normal| = 1 and |incident| = 1

        float n = ni/nr;
        float discriminant = 1 - n * n * (1 - cosThetaI * cosThetaI);

        if (discriminant < 1e-4f) {
            // TIR
            direction = (direction - 2 * shiftedTriNormal.dot(direction) * shiftedTriNormal).normalized();
            
        } else {
            // refraction
            direction = (n * direction + ((n * cosThetaI) - sqrtf(discriminant)) * shiftedTriNormal).normalized();
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
        Vec3 normal = shiftedTriNormal;
        Vec3 absn = Vec3(fabs(normal.x), fabs(normal.y), fabs(normal.z));
        Vec3 ref = (absn.x <= absn.y && absn.x <= absn.z) ? Vec3(1,0,0)
        : (absn.y <= absn.z) ? Vec3(0,1,0)
        : Vec3(0,0,1);
        Vec3 tangent = ref.cross(normal);
        Vec3 bitangent = normal.cross(tangent);

        direction = localRay.x * tangent + localRay.y * bitangent + localRay.z * shiftedTriNormal;
    }

    __device__ void mirrorReflect(Vec3& shiftedTriNormal) {
        direction = (direction - 2*(direction.dot(shiftedTriNormal))*shiftedTriNormal).normalized();
    }

    __device__ void bsdfReflect(const DeviceMaterial& material, const TriHit& triHit, unsigned int& localSeed, Vec3& runningAlbedo) {
        Vec3 UV = triHit.tri->getUV(triHit.baryCoords);

        Vec3 edge1 = (triHit.tri->coreTri.v1 - triHit.tri->coreTri.v0).normalized();
        Vec3 normalOffset = material.getNormalOffset(UV.x, UV.y);
        Vec3 shiftedTriNormal = getNormalFromOffset(triHit.tri->normal, edge1, normalOffset);
        
        runningAlbedo *= material.getAlbedo(UV.x, UV.y);

        float u1 = randUniform(localSeed);
        float u2 = randUniform(localSeed);

        bool refract = u1 < material.transmission;
        bool diffuse = u2 < powf(material.roughness, 1.0f/5.0f);

        bool facingBack = direction.dot(shiftedTriNormal) > 0;

        int type = refract || facingBack ? 0 : diffuse ? 2 : 1; // if we are facing the back, then assume we are inside a material refracting out

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