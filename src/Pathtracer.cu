#pragma once
#include <vector>
#include <cstdlib>
#include <iostream>

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

        cudaMalloc(&deviceScreenBufferPointer, sizeof(DeviceScreenBuffer));
        cudaMalloc(&deviceMaterialManagerPointer, sizeof(DeviceMaterialManager));
        cudaMalloc(&deviceTriBufferPointer, sizeof(DeviceTriBuffer));

        cudaMemcpy(deviceScreenBufferPointer, &deviceScreenBuffer, sizeof(DeviceScreenBuffer), cudaMemcpyHostToDevice);
        cudaMemcpy(deviceMaterialManagerPointer, &deviceMaterialManager, sizeof(DeviceMaterialManager), cudaMemcpyHostToDevice);
        cudaMemcpy(deviceTriBufferPointer, &deviceTriBuffer, sizeof(DeviceTriBuffer), cudaMemcpyHostToDevice);

        getPixelColorKernal<<<gridSize, blockSize>>>(deviceMaterialManagerPointer, deviceTriBufferPointer, deviceScreenBufferPointer, camera);
        cudaError_t err = cudaGetLastError();
        if (err != cudaSuccess) {
            printf("Kernel launch failed: %s\n", cudaGetErrorString(err));
        }

        cudaDeviceSynchronize();

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

    const unsigned int width = 4096;
    const unsigned int height = 4096;
    const float verticalFov = 90 * (3.1415f/180);
    const float horizontalFov = 90 * (3.1415f/180);
    const float focalLength = 1.0f;
    const unsigned int rayPerPixel = 512;
    const unsigned int maxBounces = 8;

    ScreenParams screenParams = ScreenParams(width, height, verticalFov, horizontalFov, focalLength, rayPerPixel, maxBounces);

    Vec3 camOrigin = Vec3(-2.5,0,.75);
    Vec3 camForward = Vec3(1,0,-.5);
    Camera camera = Camera(
        camOrigin,
        camForward,
        screenParams
    );

    HostResourceManager hostResourceManager = HostResourceManager();
    
    HostMaterial leftWallMaterial = HostMaterial(
        0.0f, 1.0f, 1.0f, true, HostMap(Vec3(1.0f, 0.0f, 0.0f)), HostMap(Vec3(0.0f, 0.0f, 0.0f))
    );
    MaterialID leftWallMaterialID = hostResourceManager.hostMaterialManager.registerMaterial(leftWallMaterial);

    HostMaterial backWallMaterial = HostMaterial(
        0.0f, 1.0f, 1.0f, true, HostMap(Vec3(1.0f, 0.0f, 0.0f)), HostMap(Vec3(0.0f, 0.0f, 0.0f))
    );
    MaterialID backWallMaterialID = hostResourceManager.hostMaterialManager.registerMaterial(backWallMaterial);

    HostMaterial rightWallMaterial = HostMaterial(
        0.0f, 1.0f, 1.0f, true, HostMap(Vec3(0.0f, 0.0f, 1.0f)), HostMap(Vec3(0.0f, 0.0f, 0.0f))
    );
    MaterialID rightWallMaterialID = hostResourceManager.hostMaterialManager.registerMaterial(rightWallMaterial);

    HostMaterial roofMaterial = HostMaterial(
        0.0f, 1.0f, 1.0f, true, HostMap(Vec3(1.0f, 0.0f, 1.0f)), HostMap(Vec3(0.0f, 0.0f, 0.0f))
    );
    MaterialID roofMaterialID = hostResourceManager.hostMaterialManager.registerMaterial(roofMaterial);

    HostMaterial floorMaterial = HostMaterial(
        0.0f, 1.0f, 1.0f, true, HostMap(Vec3(1.0f, 1.0f, 0.0f)), HostMap(Vec3(0.0f, 0.0f, 0.0f))
    );
    MaterialID floorMaterialID = hostResourceManager.hostMaterialManager.registerMaterial(floorMaterial);

    // printf("leftWallMaterialID: %d\n", leftWallMaterialID.materialID);

    HostMesh leftWallMesh = HostMesh::plane(tlb, tlf, blf, blb, rightWallMaterialID);
    hostResourceManager.hostMeshManager.registerMesh(leftWallMesh);

    HostMesh backWallMesh = HostMesh::plane(trb, tlb, blb, brb, backWallMaterialID);
    hostResourceManager.hostMeshManager.registerMesh(backWallMesh);

    HostMesh rightWallMesh = HostMesh::plane(trb, trf, brf, brb, rightWallMaterialID);
    hostResourceManager.hostMeshManager.registerMesh(rightWallMesh);

    HostMesh roofMesh = HostMesh::plane(trb, tlb, tlf, trf, roofMaterialID);
    hostResourceManager.hostMeshManager.registerMesh(roofMesh);

    HostMesh floorMesh = HostMesh::plane(brb, blb, blf, brf, floorMaterialID);
    hostResourceManager.hostMeshManager.registerMesh(floorMesh);
    
    auto v = hostResourceManager.hostMeshManager.getMeshs()[0].getTris()[0].v0;

    Pathtracer pathtracer = Pathtracer(hostResourceManager, camera);
    pathtracer.render((char*)"test.jpg");

    return 0;
}