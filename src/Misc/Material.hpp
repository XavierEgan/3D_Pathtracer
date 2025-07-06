#pragma once

#include <type_traits>

#include "../Math/Vec3.cuh"
#include "Map.hpp"

struct Material {
    float transmission;
    float IOR;
    float roughness;

    float emission;

    Map textureMap;
    Map normalMap;

    Material(float transmission, float IOR, float roughness, float emission, Map textureMap, Map normalMap) : transmission(transmission), IOR(IOR), roughness(roughness), emission(emission), textureMap(textureMap), normalMap(normalMap) {}

    Material(float transmission, float IOR, float roughness, float emission, Map textureMap) : transmission(transmission), IOR(IOR), roughness(roughness), emission(emission), textureMap(textureMap), normalMap(Map()) {}

    __host__ __device__ Vec3 getAlbedo(float u, float v) const {
        return textureMap.sample(u, v);
    }

    __host__ __device__ Vec3 getNormalOffset(float u, float v) const {
        return normalMap.sample(u, v);
    }
};