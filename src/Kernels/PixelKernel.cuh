#pragma once

#include "../Misc/DeviceResourceManager/DeviceMaterialManager.cuh"
#include "../Misc/DeviceResourceManager/DeviceScreenBuffer.cuh"
#include "../Misc/DeviceResourceManager/DeviceTriBuffer.cuh"
#include "../Misc/HostResourceManager/HostResourceManager.hpp"

__global__ void getPixelColorKernal(DeviceMaterialManager* deviceMaterialManagerPointer, DeviceTriBuffer* deviceTriBufferPointer, DeviceScreenBuffer* deviceScreenBufferPointer,  Camera camera) {
    DeviceMaterialManager& deviceMaterialManager = *deviceMaterialManagerPointer;
    DeviceTriBuffer& deviceTriBuffer = *deviceTriBufferPointer;
    DeviceScreenBuffer& deviceScreenBuffer = *deviceScreenBufferPointer;
    
    //printf("textureMap: %p\n", scene.deviceMaterials[1].textureMap.data);
    unsigned int x = blockIdx.x * blockDim.x + threadIdx.x;
    unsigned int y = blockIdx.y * blockDim.y + threadIdx.y;

    if (x >= camera.screenParams.width || y >= camera.screenParams.height) {
        printf("early return, %d, %d\n", x, y);
        return;
    }

    if (x == 0 && y == 0) {
        //deviceMaterialManager.print();
    }
 
    unsigned int seed = 12345 * x * y;

    Vec3 runningPixelColor = Vec3(0.0f, 0.0f, 0.0f);
    for (size_t r = 0; r < camera.screenParams.rayPerPixel; r++) {
        Vec3 runningAlbedo = Vec3(1.0f, 1.0f, 1.0f);

        // get the ray from the camera but slightly nudged
        Ray activeRay = Ray(x, y, camera, seed);
        
        size_t numBounces = 0;

        Vec3 lightSource = Vec3();
        
        for (size_t i = 0; i < camera.screenParams.maxBounces; i++) {
            // check if the ray hits any triangles
            TriHit triHit = activeRay.getTriIntersection(deviceTriBuffer);

            if (!triHit.hit) {
                // we didnt hit anything which means we are done
                //printf("No Hit\n");
                break;
            }

            // we have a hit!
            // get the tris material
            DeviceMaterial& triMaterial = deviceMaterialManager.getMaterial(triHit.tri.materialID);

            if (triMaterial.lightSource) {
                Vec3 triUV = triHit.tri.getUV(triHit.baryCoords);
                lightSource = triMaterial.getAlbedo(triUV.x, triUV.y);
                //lightSource.print("lightSource");
                break;
            }

            // reflect the ray and update runningAlbedo and runningEmission
            activeRay.bsdfReflect(triMaterial, triHit, seed, runningAlbedo);
            
            numBounces++;
        }

        Vec3 finalColor = runningAlbedo * lightSource;
        runningPixelColor += finalColor;
    }
    
    Vec3 color = (runningPixelColor / camera.screenParams.rayPerPixel);
    //Vec3 finalColor = Vec3(powf(color.x, 1/2.2), powf(color.y, 1/2.2), powf(color.z, 1/2.2));

    deviceScreenBuffer.write(color, x, y);
}