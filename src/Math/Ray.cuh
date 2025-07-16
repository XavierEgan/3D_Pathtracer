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
#include "Transform3D.cuh"

#include "../Misc/Camera.hpp"

#include "../Misc/DeviceResourceManager/DeviceMaterialManager.cuh"
#include "../Misc/DeviceResourceManager/DeviceScreenBuffer.cuh"
#include "../Misc/DeviceResourceManager/DeviceTriBuffer.cuh"
#include "../Misc/HostResourceManager/HostResourceManager.hpp"

struct TriHit {
    Vec3 intersecPoint;
    float dist;
    Vec3 baryCoords;
    const Tri* tri;
    bool hit;

    __host__ __device__ TriHit() : dist(-1), tri(nullptr), hit(false) {}
    __host__ __device__ TriHit(const Vec3& intersecPoint, float dist, const Vec3& baryCoords, const Tri& tri) : intersecPoint(intersecPoint), dist(dist), baryCoords(baryCoords), tri(&tri), hit(true) {}
};

__host__ __device__ static Vec3 getNormalFromOffset(const Vec3& normal, const Vec3& edge1, const Vec3& offset) {
    // since normal is orthogonal to edge1 we can construct a full orthonormal basis from just crossing normal and edge1
    Vec3 tangent = edge1.normalized();
    Vec3 bitangent = normal.cross(tangent).normalized();

    Transform3D transform = Transform3D(
        tangent,
        bitangent,
        normal
    );

    return (Vec3(0,0,1) + offset) * transform;
}

struct Ray {
    Vec3 direction;
    Vec3 origin;

    __device__ Ray(Vec3 direction, Vec3 origin) : direction(direction), origin(origin) {}
    __device__ Ray(Vec3 direction) : direction(direction), origin(Vec3()) {}
    __device__ Ray(int planeX, int planeY, const Camera& camera, unsigned int& seed) {
        float u1 = randUniform(seed);
        float u2 = randUniform(seed);

        Vec3 forwardComponent = camera.forward * camera.screenParams.focalLength;
        Vec3 upComponent = camera.up * ((((float)camera.screenParams.height/2) - planeY) + u1) * camera.screenParams.pxHeight;
        Vec3 rightComponent = camera.right * (-(((float)camera.screenParams.width/2) - planeX) + u2) * camera.screenParams.pxWidth;

        direction = (forwardComponent + upComponent + rightComponent).normalized();
        origin = camera.pos;

        // printf("x:%d, y:%d -- Quadrant %d\n\tRayDir:(%.2f, %.2f, %.2f) -- Rayforward:(%.2f, %.2f, %.2f) -- Rayup:(%.2f, %.2f, %.2f) -- Rayright:(%.2f, %.2f, %.2f)\n\tforward:(%.2f, %.2f, %.2f) -- up:(%.2f, %.2f, %.2f) -- right:(%.2f, %.2f, %.2f)\n\tu1:%f, u2:%f\n\tcalcX: %d, calcY: %d\n\tpxHeight:%f, pxWidth:%f\n", 
        //     planeX, planeY,  
        //     planeY<camera.screenParams.height/2 ? (planeX < camera.screenParams.width/2 ? 2 : 1) : (planeX < camera.screenParams.width/2 ? 3 : 4),
        //     direction.x, direction.y, direction.z,

        //     forwardComponent.x, forwardComponent.y, forwardComponent.z, 
        //     upComponent.x, upComponent.y, upComponent.z, 
        //     rightComponent.x, rightComponent.y, rightComponent.z,

        //     camera.forward.x, camera.forward.y, camera.forward.z,
        //     camera.up.x, camera.up.y, camera.up.z,
        //     camera.right.x, camera.right.y, camera.right.z,
            
        //     u1, u2,

        //     ((camera.screenParams.height/2) - planeY),
        //     -((camera.screenParams.width/2) - planeX),

        //     camera.screenParams.pxHeight,
        //     camera.screenParams.pxWidth
        // );
    }

    __device__ Ray(int planeX, int planeY, float subPixelOffsetX, float subPixelOffsetY, const Camera& camera, unsigned int& seed) {
        Vec3 forwardComponent = camera.forward * camera.screenParams.focalLength;
        Vec3 upComponent = camera.up * ((((float)camera.screenParams.height/2) - planeY) + subPixelOffsetY) * camera.screenParams.pxHeight;
        Vec3 rightComponent = camera.right * (-(((float)camera.screenParams.width/2) - planeX) + subPixelOffsetX) * camera.screenParams.pxWidth;

        direction = (forwardComponent + upComponent + rightComponent).normalized();
        origin = camera.pos;
    }

    __device__ TriHit rayTriIntercept(const Tri& tri) const {
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

    __device__ TriHit getTriIntersection(const DeviceTriBuffer& deviceTriBuffer) const {
        // store the closest hit so far
        TriHit closestHit = TriHit(Vec3(), 999999999.0f, Vec3(), Tri(Vec3(), Vec3(), Vec3(), 0));
        bool hitFlag = false;

        for (int i = 0; i < deviceTriBuffer.getNumTris(); i++) {

            const Tri& tri = deviceTriBuffer.getTri(i);

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

    __device__ void bsdfReflect(const DeviceMaterial& material, const TriHit& triHit, unsigned int& localSeed, Vec3& runningAlbedo) {
        /*
            i = tangent
            j = bitangent
            k = normal

            local space = tangent space
            l_ = basis vectors are in local/tangent space
            g_ = basis vectors are in global space
        */
        float u1 = randUniform(localSeed);
        float u2 = randUniform(localSeed);
        bool refract = u1 < material.transmission;
        bool diffuse = u2 < powf(material.roughness, 1.0f/5.0f);

        // for naming convention
        Vec3& g_direction = direction;
        Vec3& g_origin = origin;

        // get uv coords of intersection
        Vec3 triUV = triHit.tri->getUV(triHit.baryCoords);

        // prod the albedo
        Vec3 triAlbedo = material.getAlbedo(triUV.x,triUV.y);
        runningAlbedo *= triAlbedo;

        // get tri normal
        Vec3 g_edge1 = triHit.tri->v1 - triHit.tri->v0;
        Vec3 g_edge2 = triHit.tri->v2 - triHit.tri->v0;
        Vec3 g_triNormal = (g_edge1).cross(g_edge2).normalized();

        // offset the normal
        Vec3 normalOffset = material.getNormalOffset(triUV.x,triUV.y);
        Vec3 g_normal = getNormalFromOffset(g_triNormal, g_edge1, normalOffset);

        bool facingFront = g_direction.dot(g_triNormal) < 0;
        if (!facingFront && !refract) {
            g_normal *= -1;
        }

        // create an orthonormal basis from our new normal
        Vec3 arbitrary = g_normal.x < .9 ? Vec3(1,0,0) : Vec3(0,1,0);
        Vec3 g_tangent = g_normal.cross(arbitrary).normalized();
        Vec3 g_bitangent = g_normal.cross(g_tangent).normalized();
        
        // make transform to take local vects into global space
        Transform3D localToGlobal = Transform3D(
            g_tangent,
            g_bitangent,
            g_normal
        );

        Transform3D globalToLocal = localToGlobal.inverse();

        // get the ray in local space
        Vec3 l_rayDirection = (g_direction * globalToLocal).normalized();

        if (refract) {
            // we need to refract
            /*
            source:
             - https://shaderbits.com/blog/optimized-snell-s-law-refraction
             - https://www.cse.chalmers.se/edu/year/2013/course/TDA361/refractionvector.pdf
            */
            float ni, nr;
            Vec3 refractionNormal;
            if (facingFront) {
                // we are hittign the front of the tri (going in, normal faces toward us)
                ni = 1.0f;
                nr = material.IOR;

                refractionNormal = g_normal;
            } else {
                // we are hitting the back of the tri (going out, normal faces away)
                ni = material.IOR;
                nr = 1.0f;

                refractionNormal = -g_normal;
            }

            // remembering that a.b = |a||b|*cos(theta)
            float cosThetaI = -refractionNormal.dot(g_direction); // |normal| = 1 and |incident| = 1

            float n = ni/nr;
            float discriminant = 1 - n * n * (1 - cosThetaI * cosThetaI);

            if (discriminant < 1e-4f) {
                // TIR
                g_direction = (g_direction - 2 * refractionNormal.dot(g_direction) * refractionNormal).normalized();

                // set the origin of our new ray
                g_origin = (triHit.intersecPoint).epsilonShift(g_direction);
                
            } else {
                // refraction
                g_direction = (n * g_direction + ((n * cosThetaI) - sqrtf(discriminant)) * refractionNormal).normalized();

                // set the origin of our new ray
                g_origin = (triHit.intersecPoint).epsilonShift(g_direction);
            }
        } else {
            // we need to reflect
            if (diffuse) {
                // diffuse reflect
                // cosine weighted sampling
                // get some fresh rand numbs
                u1 = randUniform(localSeed);
                u2 = randUniform(localSeed);

                float r = sqrtf(u1);
                float phi = 2.0f * 3.1415926 * u2;

                Vec3 localRay = Vec3(
                    r * cosf(phi),
                    r * sinf(phi),
                    sqrt(1.0f - u1)
                );

                g_direction = (localRay * localToGlobal).normalized();

                g_origin = (triHit.intersecPoint).epsilonShift(g_direction);
            } else {
                // mirror reflect
                // R = I - 2(ProjN(I))
                g_direction = (g_direction - 2*(g_direction.dot(g_normal))*g_normal).normalized();

                g_origin = (triHit.intersecPoint).epsilonShift(g_direction);
            }
        }
    }
};