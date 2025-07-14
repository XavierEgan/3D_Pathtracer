#pragma once

#include <vector>
#include "../Math/Tri.cuh"
#include "HostMap.hpp"

/*
Contains data of material properties and color
*/
class HostMaterial {
    float transmission;
    float IOR;
    float roughness;

    bool lightSource;

    HostMap textureMap;
    HostMap normalMap;

public:
    HostMaterial() = delete;
    HostMaterial(
        float transmission,
        float IOR,
        float roughness,

        bool lightSource,

        HostMap textureMap,
        HostMap normalMap
    ) : 
        transmission(transmission),
        IOR(IOR),
        roughness(roughness),

        lightSource(lightSource),

        textureMap(textureMap),
        normalMap(normalMap)
    {}

    float getTransmission() const {
        return transmission;
    }
    float getIOR() const {
        return IOR;
    }
    float getRoughness() const {
        return roughness;
    }

    bool getLightSource() const {
        return lightSource;
    }

    const HostMap& getTextureMap() const {
        return textureMap;
    }
    const HostMap& getNormalMap() const {
        return normalMap;
    }
};