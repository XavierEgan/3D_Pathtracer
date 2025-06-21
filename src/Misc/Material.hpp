#pragma once

#include <type_traits>

#include "../Math/Vec3.hpp"
#include "Map.hpp"

struct Material {
    float transmission;
    float IOR;
    float roughness;

    float emission;

    Map textureMap;
    Map normalMap;

    Vec3 getAlbedo(float u, float v) const {
        return textureMap.sample(u, v);
    }

    Vec3 getNormalOffset(float u, float v) const {
        return normalMap.sample(u, v);
    }
};