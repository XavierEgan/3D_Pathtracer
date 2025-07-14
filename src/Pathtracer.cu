#pragma once
#include <vector>
#include <cstdlib>
#include <iostream>

#include <cuda_runtime.h>
#include <device_launch_parameters.h>

#include "Math/Ray.cuh"
#include "Math/Rand.cuh"


__global__ void getPixelColorKernal(ScreenBuffer screenBuffer, Scene scene, TriBuffer tris) {
    //printf("textureMap: %p\n", scene.deviceMaterials[1].textureMap.data);

    int x = blockIdx.x * blockDim.x + threadIdx.x;
    int y = blockIdx.y * blockDim.y + threadIdx.y;
    
    if (x >= scene.camera.screenParams.width || y >= scene.camera.screenParams.height) {
        //printf("early return, %d, %d", x, y);
        return;
    }

    unsigned int seed = 12345 * x * y;

    Vec3 runningPixelColor = Vec3(0.0f, 0.0f, 0.0f);

        for (size_t r = 0; r < scene.camera.screenParams.rayPerPixel; r++) {
            Vec3 runningAlbedo = Vec3(1.0f, 1.0f, 1.0f);

            // get the ray from the camera but slightly nudged
            Ray activeRay = Ray(x, y, scene, seed);
            
            size_t numBounces = 0;

            Vec3 lightSource = scene.environment.skyColor;
            
            for (size_t i = 0; i < scene.camera.screenParams.maxBounces; i++) {
                // check if the ray hits any triangles
                TriHit triHit = activeRay.getTriIntersection(tris);

                if (!triHit.hit) {
                    // we didnt hit anything which means we are done
                    //printf("No Hit\n");
                    break;
                }

                // we have a hit!
                // get the tris material
                Material& triMaterial = scene.getMaterial(triHit.tri.materialID);

                //printf("textureMap: %p\n", triMaterial.textureMap.data);

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

    screenBuffer.write(runningPixelColor / scene.camera.screenParams.rayPerPixel, x, y);
}

struct Pathtracer {
    Scene scene;

    TriBuffer tris; // to store all tris

    Pathtracer(Scene scene) : scene(scene) {}

    void render(char* outFile) {
        std::cout << "Rendering Image Now" << std::endl;
        // make a buffer to write to
        ScreenBuffer buffer = ScreenBuffer(scene.camera.screenParams);
        buffer.deviceMalloc();

        this->tris = scene.getTrisOnDevice();
        scene.materialsToDevice();

        const int BLOCK_DIM = 16;

        dim3 blockSize = dim3(BLOCK_DIM, BLOCK_DIM);

        size_t gridWidth = (scene.camera.screenParams.width + BLOCK_DIM-1) / BLOCK_DIM;
        size_t gridHeight = (scene.camera.screenParams.height + BLOCK_DIM-1) / BLOCK_DIM;
        dim3 gridSize = dim3(gridWidth, gridHeight);

        cudaDeviceSynchronize();

        getPixelColorKernal<<<gridSize, blockSize>>>(buffer, scene, this->tris);

        cudaError_t err = cudaGetLastError();
        if (err != cudaSuccess) {
            printf("Kernel launch failed: %s\n", cudaGetErrorString(err));
        }

        cudaDeviceSynchronize();

        buffer.transferDeviceHost();

        buffer.writeImage(outFile);
    }
};

int main(void) {
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
    const float verticalFov = 120 * (3.1415f/180);
    const float horizontalFov = 120 * (3.1415f/180);
    const float focalLength = 1.0f;
    const unsigned int rayPerPixel = 128;
    const unsigned int maxBounces = 8;

    Camera camera = Camera(
        Vec3(-2, 0, 0),
        Vec3(1,0,0),
        ScreenParams(
            width, height, verticalFov, horizontalFov, focalLength, rayPerPixel, maxBounces
        )
    );

    Environment environment = Environment(Vec3(0x82 / 255.0f, 0xC8 / 255.0f, 0xE5 / 255.0f)); // temp magic numbers for testing
    Scene scene = Scene(camera, environment);

    unsigned int leftWallMatID = scene.registerMaterial(
        Material(
            0, 1, 1, true, Map(Vec3(1, 0, 0)) // temp magic numbers for testing
        )
    );

    std::vector<Tri> leftWallTris = {
        Tri(tlb, blf, blb, leftWallMatID), 
        Tri(tlb, tlf, blf, leftWallMatID)
    };
    Mesh leftWall = Mesh(leftWallTris);
    scene.registerMesh(leftWall);

    unsigned int backWallMatID = scene.registerMaterial(
        Material(
            0, 1, 1, true, Map(Vec3(0, 1, 0)) // temp magic numbers for testing
        )
    );
    std::vector<Tri> backWallTris = {
        Tri(tlb, brb, trb, backWallMatID), 
        Tri(tlb, blb, brb, backWallMatID)
    };
    Mesh backWall = Mesh(backWallTris);
    scene.registerMesh(backWall);
    
    Pathtracer pathtracer = Pathtracer(scene);
    pathtracer.render((char*)"test.jpg");

    return 0;
}