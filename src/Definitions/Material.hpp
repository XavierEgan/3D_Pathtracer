#pragma once

#include <iostream>

#define STB_IMAGE_IMPLEMENTATION
#include "../util/Image.hpp"
#include "../Math/MyMath.hpp"

struct Map {
    int x, y, channels;
    uint8_t* data;

    Map() {}
    Map(char* fileLoc) {
        Image::get_image_data(fileLoc, x, y, channels, 3);
    }
};

struct BSDF {
    float metallic;      // 0 = dielectric, 1 = metal
    float roughness;     // 0 = mirror, 1 = completely rough
    float transmission;   // 0 = opaque, 1 = glass
    float IOR;

    BSDF(float metallic, float roughness, float transmission, float IOR) : 
    metallic(metallic), roughness(roughness), transmission(transmission), IOR(IOR) {}
};

struct Material {
    BSDF bsdf;

    Map textureMap, normalMap;
    bool hasTextureMap, hasNormalMap;

    Vec3 baseColor, albedo, emission;

    Material(BSDF bsdf, Vec3 emission, Vec3 baseColor) : 
    bsdf(bsdf), baseColor(baseColor), emission(emission), hasTextureMap(false), hasNormalMap(false) {
        albedo = 1.0f/baseColor;
    }

    Material(BSDF bsdf, Vec3 emission, Vec3 baseColor, char* normalMapPath) : 
    bsdf(bsdf), baseColor(baseColor), emission(emission), hasTextureMap(false), hasNormalMap(true) {
        albedo = 1.0f/baseColor;
        normalMap = Map(normalMapPath);
    }

    Material(BSDF bsdf, Vec3 emission, char* textureMapPath) : 
    bsdf(bsdf), baseColor(baseColor), emission(emission), hasTextureMap(true), hasNormalMap(false) {
        albedo = 1.0f/baseColor;
        textureMap = Map(textureMapPath);
    }

    Material(BSDF bsdf, Vec3 emission, char* textureMapPath, char* normalMapPath) : 
    bsdf(bsdf), baseColor(baseColor), emission(emission), hasTextureMap(true), hasNormalMap(true) {
        albedo = 1.0f/baseColor;
        textureMap = Map(textureMapPath);
        textureMap = Map(normalMapPath);
    }

    
};

/*
GGX/Trowbridge-Reitz Specular NDF
struct Material {
    // No texture map - No normal map
    Material(BSDF bsdf, Vec3 emission, Vec3 baseColor) : bsdf(bsdf), baseColor(baseColor), emission(emission), hasTexture(false), hasNormal(false) {}
    // No texture map - Yes normal map
    Material(BSDF bsdf, Vec3 emission, Vec3 baseColor, char* normalMapLoc) : bsdf(bsdf), baseColor(baseColor), emission(emission) {}
    // Yes texture map - No normal map
    Material(BSDF bsdf, Vec3 emission, char* textureMapLoc) : bsdf(bsdf), baseColor(baseColor), emission(emission) {}


    private:
    
};

float schlickSpecularReflectionCoefficient(float IOR, float cosAOI) {
        // source: https://en.wikipedia.org/wiki/Schlick%27s_approximation
        float R0 = pow((IOR - 1.0f) / (IOR + 1.0f), 2.0f);

        float R = R0 + (1 - R0) * pow(1 - std::fabs(cosAOI), 5.0f);

        return R;
    }

*/