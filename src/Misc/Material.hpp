#pragma once

#include <type_traits>

#include "../Math/Vec3.hpp"
#include "Map.hpp"

struct Material {
    float transmission;
    float IOR;
    float roughness;
    float metallic;

    float emission;

    Map texture;

    Vec3 getAlbedo(float u, float v) const {
        return texture.sample(u, v);
    }
};