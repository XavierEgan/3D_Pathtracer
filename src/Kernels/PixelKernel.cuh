#pragma once

#include "../Misc/DeviceResourceManager/DeviceMaterialManager.cuh"
#include "../Misc/DeviceResourceManager/DeviceScreenBuffer.cuh"
#include "../Misc/DeviceResourceManager/DeviceTriBuffer.cuh"
#include "../Misc/DeviceResourceManager/DevicePerformance.cuh"
#include "../Misc/HostResourceManager/HostResourceManager.hpp"
#include "../Misc/PixelOptimisationReport.cuh"

__global__ void getPixelColorKernal(
    DeviceMaterialManager* deviceMaterialManagerPointer, 
    DeviceTriBuffer* deviceTriBufferPointer, 
    DeviceScreenBuffer* deviceScreenBufferPointer,
    Camera camera
    #ifdef REPORT_PERFORMANCE
    , DevicePerformance devicePerformance
    #endif
) {
    const DeviceMaterialManager& deviceMaterialManager = *deviceMaterialManagerPointer;
    const DeviceTriBuffer& deviceTriBuffer = *deviceTriBufferPointer;
    DeviceScreenBuffer& deviceScreenBuffer = *deviceScreenBufferPointer;
    
    //printf("textureMap: %p\n", scene.deviceMaterials[1].textureMap.data);
    unsigned int x = blockIdx.x * blockDim.x + threadIdx.x;
    unsigned int y = blockIdx.y * blockDim.y + threadIdx.y;

    if (x >= camera.screenParams.width || y >= camera.screenParams.height) {
        //printf("early return, %d, %d\n", x, y);
        return;
    }

    #ifdef REPORT_PERFORMANCE
        devicePerformance.setXY(x, y);
    #endif
    
    unsigned int seed = 12345 * x * y;

    Vec3 runningPixelColor = Vec3::BLACK;
    #ifdef UNROLL_RAYPPLOOP
        #pragma unroll UNROLL_RAYPPLOOP
    #endif
    for (size_t r = 0; r < camera.screenParams.rayPerPixel; r++) {
        // get the ray from the camera but slightly nudged
        Ray activeRay = Ray(x, y, camera, seed);
        
        size_t numBounces = 0;

        Vec3 accumulatedRayColor = Vec3::BLACK;
        Vec3 runningAlbedo = Vec3::WHITE;

        while (true) {
            // check if the ray hits any triangles
            TriHit triHit = activeRay.getTriIntersection(
                deviceTriBuffer
                #ifdef REPORT_PERFORMANCE
                , devicePerformance
                #endif
            );
            
            if (!triHit.hit) {
                break;
            }

            // we have a hit!
            // get the tris material

            DeviceMaterial& triMaterial = deviceMaterialManager.getMaterial(triHit.tri->materialID);

            Vec3 triUV = triHit.tri->getUV(triHit.baryCoords);
            Vec3 triAlbedo = triMaterial.getAlbedo(triUV.x, triUV.y);

            runningAlbedo *= triAlbedo;
            accumulatedRayColor += runningAlbedo * triMaterial.emission;

            if (triMaterial.emission > 0) break;
            
            // reflect the ray and update
            activeRay.bsdfReflect(triMaterial, triHit, seed);

            numBounces++;
            
            if (numBounces > camera.screenParams.maxBounces) {
                break;
            }
        }

        #ifdef REPORT_PERFORMANCE
        devicePerformance.incrimentRayTraces();
        #endif

        runningPixelColor += accumulatedRayColor;
    }
    
    Vec3 color = (runningPixelColor / camera.screenParams.rayPerPixel);
    #ifdef GAMMA_CORRECTION
    color = Vec3(powf(color.x, 1/2.2), powf(color.y, 1/2.2), powf(color.z, 1/2.2));
    #endif

    color.clamp(0.0f, 1.0f);

    deviceScreenBuffer.write(color, x, y);
}