#pragma once

#include <iostream>

#define STB_IMAGE_IMPLEMENTATION
#include "../ext/stb_image.h"
#include "../Math/MyMath.hpp"

/*
we will be using BSDF
https://www.synopsys.com/glossary/what-is-bidirectional-scattering-distribution-function.html

*/
struct Material {
    Vec3 baseColor;
    float metalic;
    float roughness;
    float transmission;
    float IOR;

    Ray reflectRay(Ray& ray, const Vec3& normal) const {
        // should we do specular or lambert reflection
        if (roughness == 0.0f) {
            
        }
    }
};