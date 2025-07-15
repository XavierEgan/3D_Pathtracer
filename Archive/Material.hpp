#pragma once

#include <type_traits>

#include "../Math/Vec3.cuh"
#include "Map.cuh"

struct Material {
    float transmission;
    float IOR;
    float roughness;

    bool lightSource;

    Map textureMap;
    Map normalMap;

    Material(float transmission, float IOR, float roughness, bool lightSource, Map textureMap, Map normalMap) : transmission(transmission), IOR(IOR), roughness(roughness), lightSource(lightSource), textureMap(textureMap), normalMap(normalMap) {}

    Material(float transmission, float IOR, float roughness, bool lightSource, Map textureMap) : transmission(transmission), IOR(IOR), roughness(roughness), lightSource(lightSource), textureMap(textureMap), normalMap(Map()) {}

    __host__ void mapsToDevice() {
        textureMap.toDevice();
        normalMap.toDevice();
    }

    __device__ Vec3 getAlbedo(float u, float v) const {
        // printf("u: %f\nv: %f", u, v);
        return textureMap.sample(u, v);
    }

    __device__ Vec3 getNormalOffset(float u, float v) const {
        return normalMap.sample(u, v);
    }

    __host__ __device__ void print() const {
        // printf("Hit\n");
        //printf("transmission: %f\nIOR: %f\nroughness: %f\nlightSource: %d", transmission, IOR, roughness, lightSource);
        printf("transmission: %f\n", transmission);
        printf("IOR: %f\n", IOR);
        printf("roughness: %f\n", roughness);
        printf("lightSource: %d\n", lightSource);
        printf("Hit\n");
    }
};