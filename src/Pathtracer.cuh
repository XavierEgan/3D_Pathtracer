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
#include "Misc/HostResourceManager/HostMaterialManager.hpp"
#include "Misc/Camera.hpp"
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
        #ifdef REPORT_PERFORMANCE
            DevicePerformance devicePerformance = DevicePerformance(camera.screenParams);
        #endif

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

        printf("- **Resolution**: %dx%d\n- **Samples**: %d rays per pixel\n- **Scene Complexity**: %lld triangles\n- **Hardware**: NVIDIA RTX 4090 (16,384 CUDA cores)\n", camera.screenParams.width, camera.screenParams.height, camera.screenParams.rayPerPixel, deviceTriBuffer.getNumTris());

        auto start = std::chrono::high_resolution_clock::now();

        getPixelColorKernal<<<gridSize, blockSize>>>(
            deviceMaterialManagerPointer, 
            deviceTriBufferPointer, 
            deviceScreenBufferPointer, 
            camera
        #ifdef REPORT_PERFORMANCE
            , devicePerformance
        #endif
        );
        cudaError_t err = cudaGetLastError();
        if (err != cudaSuccess) {
            printf("Kernel launch failed: %s\n", cudaGetErrorString(err));
        }

        cudaDeviceSynchronize();

        auto end = std::chrono::high_resolution_clock::now();
        auto duration = std::chrono::duration_cast<std::chrono::milliseconds>(end-start);
        printf("Rendering took: %fs\n", duration.count()/1000.0f);

        err = cudaGetLastError();
        if (err != cudaSuccess) {
            printf("Kernel launch failed: %s\n", cudaGetErrorString(err));
        }

        deviceScreenBuffer.writeImage(outFile);

        #ifdef REPORT_PERFORMANCE
        devicePerformance.printReport();
        #endif
    }
};