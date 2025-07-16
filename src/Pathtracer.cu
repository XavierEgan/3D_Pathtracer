#pragma once
#include <vector>
#include <array>
#include <cstdlib>
#include <iostream>
#include <chrono>

#include <cuda_runtime.h>
#include <device_launch_parameters.h>

#include "Math/Ray.cuh"
#include "Math/Rand.cuh"
#include "HostResourceManager/HostMaterialManager.hpp"
#include "Camera.hpp"
#include "Kernels/PixelKernel.cuh"

struct Pathtracer {
    HostResourceManager hostResourceManager;
    Camera& camera;

    Pathtracer() = delete;
    Pathtracer(HostResourceManager hostResourceManager, Camera& camera) : hostResourceManager(hostResourceManager), camera(camera) {}

    void render(char* outFile) {
        std::cout << "Rendering Image Now" << std::endl;

        const int BLOCK_DIM = 16;

        dim3 blockSize = dim3(BLOCK_DIM, BLOCK_DIM);

        size_t gridWidth = (camera.screenParams.width + BLOCK_DIM-1) / BLOCK_DIM;
        size_t gridHeight = (camera.screenParams.height + BLOCK_DIM-1) / BLOCK_DIM;
        dim3 gridSize = dim3(gridWidth, gridHeight);

        cudaDeviceSynchronize();

        DeviceScreenBuffer deviceScreenBuffer = DeviceScreenBuffer(camera.screenParams);
        DeviceMaterialManager deviceMaterialManager = DeviceMaterialManager(hostResourceManager.hostMaterialManager);
        DeviceTriBuffer deviceTriBuffer = DeviceTriBuffer(hostResourceManager.hostMeshManager);

        DeviceScreenBuffer* deviceScreenBufferPointer;
        DeviceMaterialManager* deviceMaterialManagerPointer;
        DeviceTriBuffer* deviceTriBufferPointer;

        std::array<cudaError_t, 6> errs = std::array<cudaError_t, 6>();

        errs[0] = cudaMalloc(&deviceScreenBufferPointer, sizeof(DeviceScreenBuffer));
        errs[1] = cudaMalloc(&deviceMaterialManagerPointer, sizeof(DeviceMaterialManager));
        errs[2] = cudaMalloc(&deviceTriBufferPointer, sizeof(DeviceTriBuffer));

        errs[3] = cudaMemcpy(deviceScreenBufferPointer, &deviceScreenBuffer, sizeof(DeviceScreenBuffer), cudaMemcpyHostToDevice);
        errs[4] = cudaMemcpy(deviceMaterialManagerPointer, &deviceMaterialManager, sizeof(DeviceMaterialManager), cudaMemcpyHostToDevice);
        errs[5] = cudaMemcpy(deviceTriBufferPointer, &deviceTriBuffer, sizeof(DeviceTriBuffer), cudaMemcpyHostToDevice);

        for (cudaError_t err : errs) {
            if (err != cudaSuccess) {
                printf("[HOST] Something Failed in render: %s", cudaGetErrorString(err));
            }
        }

        auto start = std::chrono::high_resolution_clock::now();

        getPixelColorKernal<<<gridSize, blockSize>>>(deviceMaterialManagerPointer, deviceTriBufferPointer, deviceScreenBufferPointer, camera);
        cudaError_t err = cudaGetLastError();
        if (err != cudaSuccess) {
            printf("Kernel launch failed: %s\n", cudaGetErrorString(err));
        }

        cudaDeviceSynchronize();

        auto end = std::chrono::high_resolution_clock::now();
        auto duration = std::chrono::duration_cast<std::chrono::milliseconds>(end-start);
        printf("Rendering took: %fs", duration.count()/1000.0f);

        err = cudaGetLastError();
        if (err != cudaSuccess) {
            printf("Kernel launch failed: %s\n", cudaGetErrorString(err));
        }

        deviceScreenBuffer.writeImage(outFile);
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

    const unsigned int width = 2048;//4096
    const unsigned int height = 2048;
    const float verticalFov = 90 * (3.1415f/180);
    const float horizontalFov = 90 * (3.1415f/180);
    const float focalLength = 1.0f;
    const unsigned int rayPerPixel = 128 * 64;
    const unsigned int maxBounces = 32;

    ScreenParams screenParams = ScreenParams(width, height, verticalFov, horizontalFov, focalLength, rayPerPixel, maxBounces);

    Vec3 camOrigin = Vec3(-2.,0,.75);
    Vec3 camForward = Vec3(1,0,-.5);

    Camera camera = Camera(
        camOrigin,
        camForward,
        screenParams
    );

    HostResourceManager hostResourceManager = HostResourceManager();
    
    HostMaterial leftWallMaterial = HostMaterial(
        0.0f, 1.0f, 0.7f, false, HostMap(Vec3(1.0f, 1.0f, 1.0f)), HostMap(Vec3(0.0f, 0.0f, 0.0f))
    );
    MaterialID leftWallMaterialID = hostResourceManager.hostMaterialManager.registerMaterial(leftWallMaterial);

    HostMaterial backWallMaterial = HostMaterial(
        0.0f, 1.0f, 1.0f, true, HostMap(Vec3(1.0f, 1.0f, 1.0f)), HostMap(Vec3(0.0f, 0.0f, 0.0f))
    );
    MaterialID backWallMaterialID = hostResourceManager.hostMaterialManager.registerMaterial(backWallMaterial);

    HostMaterial rightWallMaterial = HostMaterial(
        0.0f, 1.0f, 1.0f, false, HostMap(Vec3(1.0f, 0.0f, 0.0f)), HostMap(Vec3(0.0f, 0.0f, 0.0f))
    );
    MaterialID rightWallMaterialID = hostResourceManager.hostMaterialManager.registerMaterial(rightWallMaterial);

    HostMaterial roofMaterial = HostMaterial(
        0.0f, 1.0f, 1.0f, false, HostMap(Vec3(1.0f, 0.0f, 1.0f)), HostMap(Vec3(0.0f, 0.0f, 0.0f))
    );
    MaterialID roofMaterialID = hostResourceManager.hostMaterialManager.registerMaterial(roofMaterial);

    HostMaterial floorMaterial = HostMaterial(
        0.0f, 1.0f, 1.0f, false, HostMap(Vec3(1.0f, 1.0f, 0.0f)), HostMap(Vec3(0.0f, 0.0f, 0.0f))
    );
    MaterialID floorMaterialID = hostResourceManager.hostMaterialManager.registerMaterial(floorMaterial);

    HostMaterial randMaterial = HostMaterial(
        0.0f, 1.0f, 1.0f, false, HostMap(Vec3(1.0f, 1.0f, 1.0f)), HostMap(Vec3(0.0f, 0.0f, 0.0f))
    );
    MaterialID randMaterialID = hostResourceManager.hostMaterialManager.registerMaterial(randMaterial);

    // printf("leftWallMaterialID: %d\n", leftWallMaterialID.materialID);

    HostMesh leftWallMesh = HostMesh::plane(tlb, tlf, blf, blb, leftWallMaterialID);
    hostResourceManager.hostMeshManager.registerMesh(leftWallMesh);

    HostMesh backWallMesh = HostMesh::plane(brb, blb, tlb, trb, backWallMaterialID);
    hostResourceManager.hostMeshManager.registerMesh(backWallMesh);

    HostMesh rightWallMesh = HostMesh::plane(trb, trf, brf, brb, rightWallMaterialID);
    hostResourceManager.hostMeshManager.registerMesh(rightWallMesh);

    HostMesh roofMesh = HostMesh::plane(trf, tlf, tlb, trb, roofMaterialID);
    hostResourceManager.hostMeshManager.registerMesh(roofMesh);

    HostMesh floorMesh = HostMesh::plane(brb, blb, blf, brf, floorMaterialID);
    hostResourceManager.hostMeshManager.registerMesh(floorMesh);

    unsigned int seed = 0;

    HostMesh randMesh = HostMesh::randomMesh(-.5, .5, 20, seed, randMaterialID);
    hostResourceManager.hostMeshManager.registerMesh(randMesh);
    
    auto v = hostResourceManager.hostMeshManager.getMeshs()[0].getTris()[0].v0;

    Pathtracer pathtracer = Pathtracer(hostResourceManager, camera);
    pathtracer.render((char*)"test.jpg");

    return 0;
}