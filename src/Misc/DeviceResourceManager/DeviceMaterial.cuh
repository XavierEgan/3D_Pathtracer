#pragma once

#include <vector>
#include "../Math/Tri.cuh"
#include "DeviceMap.cuh"
#include "../HostResourceManager/HostMaterial.hpp"

/*
Contains data of material properties and color
*/
class DeviceMaterial {
public:
    float transmission;
    float IOR;
    float roughness;

    bool lightSource;

    DeviceMap textureMap;
    DeviceMap normalMap;

    __host__ DeviceMaterial() = delete;
    __host__ DeviceMaterial(const HostMaterial& hostMaterial): 
        transmission(hostMaterial.getTransmission()),
        IOR(hostMaterial.getIOR()),
        roughness(hostMaterial.getRoughness()),
        lightSource(hostMaterial.getLightSource()),
        textureMap(DeviceMap(hostMaterial.getTextureMap())),
        normalMap(DeviceMap(hostMaterial.getNormalMap()))
    {}

    __device__ Vec3 getAlbedo(float u, float v) const {
        return textureMap.sample(u, v);
    }

    __device__ Vec3 getNormalOffset(float u, float v) const {
        return normalMap.sample(u, v);
    }
};