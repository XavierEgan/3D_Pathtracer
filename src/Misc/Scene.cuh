#pragma once
#include <vector>

#include "Material.hpp"
#include "Mesh.hpp"
#include "Camera.hpp"
#include "Environment.hpp"
#include "Misc/TriBuffer.hpp"

struct Scene {
    std::vector<Mesh> meshs;
    Material* materials;
    size_t numMaterials;

    Camera camera;
    Environment environment;
    
    Scene(Camera camera, Environment environment);

    /* NOTE TO USER: DONT FUCKING OVERFLOW THIS OR I WILL DISEMBOWEL YOU */
    void allocMaterials(size_t materialsCap) {
        size_t size = materialsCap * sizeof(Material);

        cudaMalloc(&materials, size);

        numMaterials = 0;
    }

    void registerMesh(Mesh mesh) {
        meshs.push_back(mesh);
    }

    uint16_t registerMaterial(Material material) {
        materials[numMaterials] = material;
        numMaterials++;
        return numMaterials;
    }

    __host__ __device__ Material& getMaterial(uint16_t materialID) {
        return materials[materialID];
    }

    TriBuffer getTris() {
        // get all the tris together
        std::vector<Tri> trisVec = std::vector<Tri>();
        for(Mesh mesh : meshs) {
            for (Tri tri : mesh.tris) {
                trisVec.push_back(tri);
            }
        }

        Tri* tris;
        size_t size = trisVec.size() * sizeof(Tri);
        cudaMalloc(&tris, size);
        cudaMemcpy(tris, trisVec.data(), size, cudaMemcpyHostToDevice);

        return TriBuffer(tris, size);
    }

    void freeTris(Tri* tris) {
        cudaFree(tris);
    }
};