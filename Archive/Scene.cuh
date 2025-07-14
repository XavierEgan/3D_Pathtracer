#pragma once
#include <vector>

#include "Material.hpp"
#include "Mesh.hpp"
#include "Camera.hpp"
#include "Environment.hpp"
#include "Misc/TriBuffer.hpp"

struct Scene {
    std::vector<Mesh> meshs;
    std::vector<Material> materials;

    Material* deviceMaterials;

    Camera camera;
    Environment environment;
    
    Scene(Camera camera, Environment environment) : camera(camera), environment(environment) {}

    void registerMesh(Mesh mesh) {
        meshs.push_back(mesh);
    }

    uint16_t registerMaterial(Material material) {
        materials.push_back(material);
        return materials.size() - 1;
    }

    __host__ void materialsToDevice() {
        for (Material m : materials) {
            m.mapsToDevice();
        }
        
        cudaMalloc(&deviceMaterials, sizeof(Material) * materials.size());
        cudaMemcpy(deviceMaterials, materials.data(), sizeof(Material) * materials.size(), cudaMemcpyHostToDevice);
    }

    __device__ Material& getMaterial(uint16_t materialID) {
        return deviceMaterials[materialID];
    }

    TriBuffer getTrisOnDevice() {
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

        return TriBuffer(tris, trisVec.size());
    }

    void freeTris(Tri* tris) {
        cudaFree(tris);
    }
};