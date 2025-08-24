#pragma once

#include <vector>
#include "Misc/HostResourceManager/HostMap.hpp"

/*
Contains data of material properties and color
*/
class HostMaterial {
    float transmission;
    float IOR;
    float roughness;
    float emission;

    HostMap textureMap;
    HostMap normalMap;

public:
    HostMaterial() = delete;
    HostMaterial(
        float transmission,
        float IOR,
        float roughness,
        float emission,

        HostMap textureMap,
        HostMap normalMap
    ) : 
        transmission(transmission),
        IOR(IOR),
        roughness(roughness),
        emission(emission),

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

    float getEmission() const {
        return emission;
    }

    const HostMap& getTextureMap() const {
        return textureMap;
    }
    const HostMap& getNormalMap() const {
        return normalMap;
    }

    void print() {
        /*
        printf("[Host] transmission: %.1f, IOR: %.1f, roughness: %.1f, lightSource: %d, textureMap[0]: %.2f, textureMap[1]: %.2f, textureMap[2]: %.2f\n",
        transmission, IOR, roughness, lightSource, 
        textureMap.getData()[0]/255.0f, textureMap.getData()[1]/255.0f, textureMap.getData()[2]/255.0f);
        */

        printf("[Host] textureMap[0]: %.2f, textureMap[1]: %.2f, textureMap[2]: %.2f\n",
        textureMap.getData()[0]/255.0f, textureMap.getData()[1]/255.0f, textureMap.getData()[2]/255.0f);
    }
};