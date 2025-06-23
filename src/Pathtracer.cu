#pragma once
#include <vector>
#include <cstdlib>

#include <cuda_runtime.h>
#include <device_launch_parameters.h>

#include "Misc/Scene.cuh"
#include "Misc/ScreenBuffer.hpp"
#include "Misc/TriBuffer.hpp"
#include "Math/Ray.cuh"
#include "Math/Rand.cuh"

struct Pathtracer;

__global__ void getPixelColorKernal(ScreenBuffer screenBuffer, Scene scene, Pathtracer pathtracer);

struct Pathtracer {
    Scene scene;

    TriBuffer tris; // to store all tris

    Pathtracer(Scene scene) : scene(scene) {}

    void render(char* outFile) {
        // make a buffer to write to
        ScreenBuffer buffer = ScreenBuffer(scene.camera.screenParams);

        /* Get all the data together (usefull for when i rewrite this on cuda) */
        TriBuffer tris = scene.getTris();
        (void) scene.materials;

        const int BLOCK_DIM = 32;

        dim3 blockSize(BLOCK_DIM, BLOCK_DIM);
        dim3 gridSize((scene.camera.screenParams.width + BLOCK_DIM-1) / BLOCK_DIM, (scene.camera.screenParams.height + BLOCK_DIM-1) / BLOCK_DIM);

        buffer.allocData(); // this makes the buffer on the gpu

        getPixelColorKernal<<<gridSize, blockSize>>>(buffer, scene, *this);

        buffer.writeImage("test_image");
    }
};

__global__ void getPixelColorKernal(ScreenBuffer screenBuffer, Scene scene, Pathtracer pathtracer) {
    int x = blockIdx.x * blockDim.x + threadIdx.x;
    int y = blockIdx.y * blockDim.y + threadIdx.y;
    
    if (x >= pathtracer.scene.camera.screenParams.width || y >= pathtracer.scene.camera.screenParams.height) return;

    unsigned int seed = 12345 * x * y;

    Vec3 runningPixelColor = Vec3(0.0f, 0.0f, 0.0f);

        for (size_t r = 0; r < scene.camera.screenParams.rayPerPixel; r++) {
            Vec3 runningAlbedo = Vec3(1.0f, 1.0f, 1.0f);
            Vec3 runningEmission = Vec3(0.0f, 0.0f, 0.0f);

            // get the ray from the camera but slightly nudged
            Ray activeRay = Ray(x, y, scene, seed);

            for (size_t i = 0; i < scene.camera.screenParams.maxBounces; i++) {
                // check if the ray hits any triangles
                TriHit triHit = activeRay.getTriIntersection(pathtracer.tris);

                if (!triHit.hit) {
                    // we didnt hit anything which means we are done
                    break;
                }

                // we have a hit!
                // get the tris material
                Material& triMaterial = scene.getMaterial(triHit.tri.materialID);

                // reflect the ray and update runningAlbedo and runningEmission
                activeRay.bsdfReflect(triMaterial, triHit, seed, runningAlbedo, runningEmission);
            }

            Vec3 finalColor = runningAlbedo + runningEmission;
            runningPixelColor += finalColor;
        }

    screenBuffer.write(runningPixelColor / scene.camera.screenParams.maxBounces, x, y);
}

int main(void) {
    Camera camera = Camera(Vec3(), Vec3(0,1,0), ScreenParams(128, 128, 128, 16, 3.1415f/2, 3.1415f, 1.0f));



    Mesh mesh1 = Mesh(
        
    )

    return 0;
}