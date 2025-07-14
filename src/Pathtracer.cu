#pragma once
#include <vector>
#include <cstdlib>
#include <iostream>

#include <cuda_runtime.h>
#include <device_launch_parameters.h>

#include "Math/Ray.cuh"
#include "Math/Rand.cuh"
#include "DeviceResourceManager/DeviceResourceManager.cuh"
#include "Kernels/PixelKernel.cuh"

struct Pathtracer {
    DeviceResourceManager& deviceResourceManager;
    Camera& camera;

    Pathtracer() = delete;
    Pathtracer(DeviceResourceManager& deviceResourceManager, Camera& camera) : deviceResourceManager(deviceResourceManager), camera(camera) {}

    void render(char* outFile) {
        std::cout << "Rendering Image Now" << std::endl;

        const int BLOCK_DIM = 16;

        dim3 blockSize = dim3(BLOCK_DIM, BLOCK_DIM);

        size_t gridWidth = (camera.screenParams.width + BLOCK_DIM-1) / BLOCK_DIM;
        size_t gridHeight = (camera.screenParams.height + BLOCK_DIM-1) / BLOCK_DIM;
        dim3 gridSize = dim3(gridWidth, gridHeight);

        cudaDeviceSynchronize();

        getPixelColorKernal<<<gridSize, blockSize>>>(deviceResourceManager, camera);

        cudaError_t err = cudaGetLastError();
        if (err != cudaSuccess) {
            printf("Kernel launch failed: %s\n", cudaGetErrorString(err));
        }

        cudaDeviceSynchronize();

        deviceResourceManager.deviceScreenBuffer.writeImage(outFile);
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

    ScreenParams screenParams = ScreenParams(width, height, verticalFov, horizontalFov, focalLength, rayPerPixel, maxBounces);

    Vec3 camOrigin = Vec3(-2, 0, 0);
    Vec3 camForward = Vec3(1,0,0);
    Camera camera = Camera(
        camOrigin,
        camForward,
        screenParams
    );

    HostResourceManager hostResourceManager = HostResourceManager();
    
    HostMaterial leftWallMaterial = HostMaterial(
        0.0f, 1.0f, 1.0f, false, HostMap(Vec3(1.0f, 0.0f, 0.0f)), HostMap(Vec3(0.0f, 0.0f, 0.0f))
    );
    MaterialID leftWallMaterialID = hostResourceManager.hostMaterialManager.registerMaterial(leftWallMaterial);

    std::vector<Tri> leftWallTris = {
        Tri(tlb, blf, blb, leftWallMaterialID), 
        Tri(tlb, tlf, blf, leftWallMaterialID)
    };
    HostMesh leftWallMesh = HostMesh(leftWallTris);
    hostResourceManager.hostMeshManager.registerMesh(leftWallMesh);

    HostMaterial backWallMaterial = HostMaterial(
        0.0f, 1.0f, 1.0f, false, HostMap(Vec3(1.0f, 0.0f, 0.0f)), HostMap(Vec3(0.0f, 0.0f, 0.0f))
    );

    MaterialID backWallMaterialID = hostResourceManager.hostMaterialManager.registerMaterial(backWallMaterial);

    std::vector<Tri> backWallTris = {
        Tri(tlb, brb, trb, backWallMaterialID), 
        Tri(tlb, blb, brb, backWallMaterialID)
    };
    HostMesh backWall = HostMesh(backWallTris);
    hostResourceManager.hostMeshManager.registerMesh(backWall);
    
    Pathtracer pathtracer = Pathtracer(DeviceResourceManager(hostResourceManager, screenParams), camera);
    pathtracer.render((char*)"test.jpg");

    return 0;
}