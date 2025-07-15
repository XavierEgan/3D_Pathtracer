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
        
        DeviceResourceManager* deviceResourceManagerPointer;

        cudaMalloc(&deviceResourceManagerPointer, sizeof(DeviceResourceManager));
        cudaMemcpy(deviceResourceManagerPointer, &deviceResourceManager, sizeof(DeviceResourceManager), cudaMemcpyHostToDevice);

        //cudaDeviceSynchronize();
        getPixelColorKernal<<<gridSize, blockSize>>>(deviceResourceManagerPointer, camera);
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

    const unsigned int width = 32;
    const unsigned int height = 32;
    const float verticalFov = 90 * (3.1415f/180);
    const float horizontalFov = 90 * (3.1415f/180);
    const float focalLength = 1.0f;
    const unsigned int rayPerPixel = 1;
    const unsigned int maxBounces = 8;

    ScreenParams screenParams = ScreenParams(width, height, verticalFov, horizontalFov, focalLength, rayPerPixel, maxBounces);

    Vec3 camOrigin = Vec3(-1, .5, .5);
    Vec3 camForward = Vec3(1,0,0);
    Camera camera = Camera(
        camOrigin,
        camForward,
        screenParams
    );

    HostResourceManager hostResourceManager = HostResourceManager();
    
    HostMaterial leftWallMaterial = HostMaterial(
        0.0f, 1.0f, 1.0f, true, HostMap(Vec3(0.0f, 1.0f, 0.0f)), HostMap(Vec3(0.0f, 0.0f, 0.0f))
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

    HostMesh leftWallMesh = HostMesh::plane(tlb, tlf, blf, blb, leftWallMaterialID);
    hostResourceManager.hostMeshManager.registerMesh(leftWallMesh);

    HostMesh backWallMesh = HostMesh::plane(trb, tlb, blb, brb, backWallMaterialID);
    hostResourceManager.hostMeshManager.registerMesh(backWallMesh);

    HostMesh rightWallMesh = HostMesh::plane(trb, tlb, blb, brb, rightWallMaterialID);
    hostResourceManager.hostMeshManager.registerMesh(rightWallMesh);

    HostMesh roofMesh = HostMesh::plane(trb, tlb, tlf, trf, roofMaterialID);
    hostResourceManager.hostMeshManager.registerMesh(roofMesh);

    HostMesh floorMesh = HostMesh::plane(brb, blb, blf, brf, floorMaterialID);
    hostResourceManager.hostMeshManager.registerMesh(floorMesh);
    
    Pathtracer pathtracer = Pathtracer(DeviceResourceManager(hostResourceManager, screenParams), camera);
    pathtracer.render((char*)"test.jpg");

    return 0;
}