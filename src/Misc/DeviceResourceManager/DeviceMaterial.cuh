#pragma once

#include <vector>
#include "../Math/Tri.cuh"
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

    unsigned char* textureMapData;
    unsigned int textureMapWidth;
    unsigned int textureMapHeight;
    unsigned int textureMapChannels;
    
    unsigned char* normalMapData;
    unsigned int normalMapWidth;
    unsigned int normalMapHeight;
    unsigned int normalMapChannels;

    __host__ DeviceMaterial() = delete;
    __host__ DeviceMaterial(const HostMaterial& hostMaterial): 
        transmission(hostMaterial.getTransmission()),
        IOR(hostMaterial.getIOR()),
        roughness(hostMaterial.getRoughness()),
        lightSource(hostMaterial.getLightSource()),
        textureMapData(nullptr),
        textureMapWidth(hostMaterial.getTextureMap().getWidth()),
        textureMapHeight(hostMaterial.getTextureMap().getHeight()),
        textureMapChannels(hostMaterial.getTextureMap().getChannels()),
        normalMapData(nullptr),
        normalMapWidth(hostMaterial.getNormalMap().getWidth()),
        normalMapHeight(hostMaterial.getNormalMap().getHeight()),
        normalMapChannels(hostMaterial.getNormalMap().getChannels())
    {
        size_t textureMapSize = sizeof(unsigned char) * textureMapWidth * textureMapHeight * textureMapChannels;
        size_t normalMapSize = sizeof(unsigned char) * normalMapWidth * normalMapHeight * normalMapChannels;

        cudaMalloc(&textureMapData, textureMapSize);
        cudaMalloc(&normalMapData, normalMapSize);

        auto hostTextureMapData = hostMaterial.getTextureMap().getData();
        auto hostNormalMapData = hostMaterial.getNormalMap().getData();

        unsigned char* hostTextureMapDataPointer = hostTextureMapData.data();
        unsigned char* hostNormalMapDataPointer = hostNormalMapData.data();

        cudaMemcpy(textureMapData, hostTextureMapDataPointer, textureMapSize, cudaMemcpyHostToDevice);
        cudaMemcpy(normalMapData, hostNormalMapDataPointer, normalMapSize, cudaMemcpyHostToDevice);
    }

    __device__ Vec3 getAlbedo(float u, float v) const {
        #ifdef DEBUG
        if (u > 1.0f || v > 1.0f) {
            printf("[DEVICE] getAlbedo u or v is not in range -- u=%d, v=%d\n", u, v);
            return Vec3();
        }
        #endif

        int x = static_cast<int>(u * (textureMapWidth - 1));
        int y = static_cast<int>(v * (textureMapHeight - 1));
        int index = (y * textureMapWidth + x) * textureMapChannels;

        #ifdef DEBUG
        if (x >= textureMapWidth || y >= textureMapHeight) {
            printf("[DEVICE] getAlbedo out of range access -- x=%d, y=%d -- textureMapWidth=%d, textureMapHeight=%d\n", x, y, textureMapWidth, textureMapHeight);
            return Vec3();
        }
        #endif

        Vec3 ret = Vec3(
            textureMapData[index] / 255.0f,
            textureMapData[index + 1] / 255.0f,
            textureMapData[index + 2] / 255.0f
        );

        // if (textureMapData[0] == 255, textureMapData[1] == 255, textureMapData[2] == 229) {
        //     printf("%d, %d, %d\n", textureMapData[0], textureMapData[1], textureMapData[2]);
        // }

        return ret;
    }

    __device__ Vec3 getNormalOffset(float u, float v) const {
        if (normalMapWidth == 0 || normalMapHeight == 0) {
            // no normal map
            return Vec3();
        }

        int x = static_cast<int>(u * (normalMapWidth - 1));
        int y = static_cast<int>(v * (normalMapHeight - 1));
        int index = (y * normalMapWidth + x) * normalMapChannels;

        #ifdef DEBUG
        if (x >= normalMapWidth || y >= normalMapHeight) {
            printf("[DEVICE] getNormalOffset out of range access\n");
            return Vec3();
        }
        #endif

        Vec3 ret = Vec3(
            normalMapData[index] / 255.0f,
            normalMapData[index + 1] / 255.0f,
            normalMapData[index + 2] / 255.0f
        );
        
        return ret;
    }

    __device__ void print() {
        /*
        printf("[DEVICE] transmission: %.1f, IOR: %.1f, roughness: %.1f, lightSource: %d, textureMap[0]: %.2f, textureMap[1]: %.2f, textureMap[2]: %.2f\n",
        transmission, IOR, roughness, lightSource, 
        textureMap.sample(0,0).x, textureMap.sample(0,0).y, textureMap.sample(0,0).z);
        */
        printf("[DEVICE] textureMap[0]: %.2f, textureMap[1]: %.2f, textureMap[2]: %.2f\n",
        getAlbedo(0,0).x, getAlbedo(0,0).y, getAlbedo(0,0).z);
    }
};