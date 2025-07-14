#pragma once

#include <vector>
#include "../Math/Tri.cuh"
#include "DeviceMap.cuh"
#include "../HostResourceManager/HostMaterial.hpp"

/*
Contains data of material properties and color
*/
class DeviceMaterial {
    float transmission;
    float IOR;
    float roughness;

    bool lightSource;

    DeviceMap textureMap;
    DeviceMap normalMap;

public:
    DeviceMaterial() = delete;
    DeviceMaterial(const HostMaterial& hostMaterial): 
        transmission(hostMaterial.getTransmission()),
        IOR(hostMaterial.getIOR()),
        roughness(hostMaterial.getRoughness()),
        lightSource(hostMaterial.getLightSource()),
        textureMap(DeviceMap(hostMaterial.getTextureMap())),
        normalMap(DeviceMap(hostMaterial.getNormalMap()))
    {}
};