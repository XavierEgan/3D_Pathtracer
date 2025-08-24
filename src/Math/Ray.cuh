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

#include "Misc/Camera.hpp"

#include "Misc/DeviceResourceManager/DeviceMaterialManager.cuh"
#include "Misc/DeviceResourceManager/DeviceScreenBuffer.cuh"
#include "Misc/DeviceResourceManager/DeviceTriBuffer.cuh"
#include "Misc/DeviceResourceManager/DevicePerformance.cuh"
#include "Misc/HostResourceManager/HostResourceManager.hpp"
#include "Misc/PixelOptimisationReport.cuh"

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

__device__ __forceinline__ void swap(float& a, float& b) {
    float t = a;
    a = b;
    b = t;
}

__host__ __device__ static Vec3 getNormalFromOffset(const Vec3& triNormal, const Vec3& edge1, const Vec3& offset) {
    //https://en.wikipedia.org/wiki/Normal_mapping
    // since normal is orthogonal to edge1 we can construct a full orthonormal basis from just crossing normal and edge1
    Vec3 normal = triNormal;
    Vec3 absn = Vec3(fabs(normal.x), fabs(normal.y), fabs(normal.z));
    Vec3 ref = (absn.x <= absn.y && absn.x <= absn.z) ? Vec3(1,0,0)
    : (absn.y <= absn.z) ? Vec3(0,1,0)
    : Vec3(0,0,1);
    Vec3 tangent = ref.cross(normal);
    Vec3 bitangent = normal.cross(tangent);
    tangent.normalize();
    bitangent.normalize();

    Vec3 localVecWithOffset = Vec3(0,0,1) + offset;

    return localVecWithOffset.x * tangent + localVecWithOffset.y * bitangent + localVecWithOffset.z * normal;
}

class Ray {
    Vec3 direction;
    Vec3 origin;

public:
    __device__ Ray(Vec3 direction, Vec3 origin) : origin(origin) {setDirection(direction);}
    __device__ Ray(Vec3 direction) : origin(Vec3()) {setDirection(direction);}
    __device__ Ray(int planeX, int planeY, const Camera& camera, unsigned int& seed) : Ray(planeX, planeY, randUniform(seed), randUniform(seed), camera) {}
    __device__ Ray(int planeX, int planeY, float subPixelOffsetX, float subPixelOffsetY, const Camera& camera) {
        Vec3 forwardComponent = camera.precomputedForwardComponent;
        Vec3 upComponent = camera.up * ((camera.screenParams.heightOnTwo - planeY) + subPixelOffsetY) * camera.screenParams.pxHeight;
        Vec3 rightComponent = camera.right * ((planeX - camera.screenParams.widthOnTwo) + subPixelOffsetX) * camera.screenParams.pxWidth;

        setDirection((forwardComponent + upComponent + rightComponent).normalized());
        origin = camera.pos;
    }

    __device__ __forceinline__ void setDirection(Vec3 dir) {
        direction = dir;
    }

    __device__ __forceinline__ bool intersectsAABB(const AABB& aabb, float closestIntercept) const {
        //https://www.scratchapixel.com/lessons/3d-basic-rendering/minimal-ray-tracer-rendering-simple-shapes/ray-box-intersection.html
        Vec3 invDir = 1.0f/direction;
        Vec3 t1 = (aabb.min - origin) * invDir;
        Vec3 t2 = (aabb.max - origin) * invDir;

        Vec3 tmin_vec = min(t1, t2);
        Vec3 tmax_vec = max(t1, t2);

        float tmin = max(max(tmin_vec.x, tmin_vec.y), tmin_vec.z);
        float tmax = min(min(tmax_vec.x, tmax_vec.y), tmax_vec.z);

        return tmin <= tmax && (tmin <= closestIntercept);
    }

    __device__ __forceinline__ bool getTriHit(const CoreTri& tri, _TriDist& triDist) const {
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

        triDist.dist = t;
        triDist.u = u;
        triDist.v = v;

        bool hit = !(det > -EPSILON && det < EPSILON) && 
            u >= 0.0f && u <= 1.0f && 
            v >= 0.0f && u + v <= 1.0f && 
            t > EPSILON;

        return hit;
    }

    __device__ __forceinline__ TriHit getTriIntersection(
        const DeviceTriBuffer& deviceTriBuffer
        #ifdef REPORT_PERFORMANCE
        , DevicePerformance& devicePerformance
        #endif
    ) const {
        _TriDist closestDist = _TriDist();
        int closestTriIndex =  -1;

        for (int i = 0; i < deviceTriBuffer.getNumTris(); i++) {
            const AABB& aabb = deviceTriBuffer.getAABB(i);

            #ifdef REPORT_PERFORMANCE
            devicePerformance.incrimentAABBIntersecs();
            #endif

            if (!intersectsAABB(aabb, closestDist.dist)) {
                continue;
            }

            const CoreTri& tri = deviceTriBuffer.getCoreTri(i);

            _TriDist dist;
            
            #ifdef REPORT_PERFORMANCE
            devicePerformance.incrimentRayTriIntersecs();
            #endif

            if (this->getTriHit(tri, dist) && dist.dist < closestDist.dist) {
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

        if (discriminant < EPSILON) {
            // TIR
            setDirection((direction - 2 * shiftedTriNormal.dot(direction) * shiftedTriNormal).normalized());
            
        } else {
            // refraction
            setDirection((n * direction + ((n * cosThetaI) - sqrtf(discriminant)) * shiftedTriNormal).normalized());
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

        setDirection(localRay.x * tangent + localRay.y * bitangent + localRay.z * shiftedTriNormal);
    }

    __device__ void mirrorReflect(Vec3& shiftedTriNormal) {
        setDirection((direction - 2*(direction.dot(shiftedTriNormal))*shiftedTriNormal).normalized());
    }

    __device__ void bsdfReflect(const DeviceMaterial& material, const TriHit& triHit, unsigned int& localSeed) {
        Vec3 UV = triHit.tri->getUV(triHit.baryCoords);

        Vec3 edge1 = (triHit.tri->coreTri.v1 - triHit.tri->coreTri.v0).normalized();
        Vec3 normalOffset = material.getNormalOffset(UV.x, UV.y);
        Vec3 shiftedTriNormal = getNormalFromOffset(triHit.tri->normal, edge1, normalOffset);
        
        float u1 = randUniform(localSeed);
        float u2 = randUniform(localSeed);

        bool refract = u1 < material.transmission;
        bool diffuse = u2 < powf(material.roughness, 1.0f/5.0f); // ^1/5 is just a function that makes it look somewhat correct

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