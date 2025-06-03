#pragma once

#include <iostream>
#include <cmath>
#include <array>
#include <vector>

#define STB_IMAGE_IMPLEMENTATION
#include "../ext/stb_image.h"
#include "../Math/MyMath.hpp"

/*
What we need:

*/
struct BSDF {
    float metallic;      // 0 = dielectric, 1 = metal
    float roughness;     // 0 = mirror, 1 = completely rough
    float transmission;   // 0 = opaque, 1 = glass
    float ior;

    BSDF(float metallic, float roughness, float transmission, float ior) : metallic(metallic), roughness(roughness), transmission(transmission), ior(ior) {}
};

struct Material {
    BSDF bsdf;

    Vec3 baseColor;
    Vec3 emission;

    uint8_t* textureMap;
    uint8_t* normalMap;

    bool hasTextureMap, hasNormalMap;

    Material(BSDF bsdf, Vec3 base_color, Vec3 emission) : bsdf(bsdf) {

    }
};