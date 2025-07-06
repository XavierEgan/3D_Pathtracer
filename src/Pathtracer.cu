#pragma once
#include <vector>
#include <cstdlib>
#include <iostream>

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
        std::cout << "Rendering Image Now" << std::endl;
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

        buffer.writeImage(outFile);
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
    std::cout << "main" << std::endl;
    Vec3 
    tlf, blf,
    tlb, blb,
    trf, brf,
    trb, brb;
    tlf = Vec3(-1.0f, 1.0f, -1.0f); // top left front corner
    blf = Vec3(-1.0f, -1.0f, -1.0f); // bottom left front corner

    tlb = Vec3(1.0f, 1.0f, -1.0f); // top left back corner
    blb = Vec3(1.0f, -1.0f, -1.0f); // bottom left back corner

    trf = Vec3(-1.0f, 1.0f, 1.0f); // top right front corner
    brf = Vec3(-1.0f, -1.0f, 1.0f); // bottom right front corner

    trb = Vec3(1.0f, 1.0f, 1.0f); // top right back corner
    brb = Vec3(1.0f, -1.0f, 1.0f); // bottom right back corner

    const unsigned int width = 128;
    const unsigned int height = 128;
    const float verticalFov = (3.1415/180);
    const float horizontalFov = (3.1415/180);
    const float focalLength = 1.0f;
    const unsigned int rayPerPixel = 128;
    const unsigned int maxBounces = 8;

    std::cout << "cam" << std::endl;

    Camera camera = Camera(
        Vec3(),
        Vec3(0,1,0),
        ScreenParams(
            width, height, verticalFov, horizontalFov, focalLength, rayPerPixel, maxBounces
        )
    );

    Environment environment = Environment(Vec3(0x82 / 255.0f, 0xC8 / 255.0f, 0xE5 / 255.0f));
    Scene scene = Scene(camera, environment);

    std::cout << "foo" << std::endl;

    scene.allocMaterials(100); // we can have up to 100 materials

    std::cout << "bar" << std::endl;

    unsigned int leftWallMatID = scene.registerMaterial(
        Material(
            0, 1, 1, 0, Map(Vec3(1, 0, 0))
        )
    );
    std::cout << "bash" << std::endl;
    std::vector<Tri> leftWallTris = {
        Tri(tlb, blf, blb, leftWallMatID), 
        Tri(tlb, tlf, blf, leftWallMatID)
    };
    Mesh leftWall = Mesh(leftWallTris);

    unsigned int backWallMatID = scene.registerMaterial(
        Material(
            0, 1, 1, 0, Map(Vec3(0, 1, 0))
        )
    );
    std::vector<Tri> backWallTris = {
        Tri(tlb,brb, trb, backWallMatID), 
        Tri(tlb, blb, brb, backWallMatID)
    };
    Mesh backWall = Mesh(leftWallTris);
    
    Pathtracer pathtracer = Pathtracer(scene);
    pathtracer.render((char*)"test");

    return 0;
}