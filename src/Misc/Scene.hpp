#pragma once
#include <vector>

#include "Material.hpp"
#include "Mesh.hpp"
#include "Camera.hpp"
#include "Environment.hpp"

struct Scene {
    std::vector<Mesh> meshs;
    std::vector<Material> materials;

    Camera camera;
    Environment environment;
    
    Scene(Camera camera, Environment environment);

    void registerMesh(Mesh mesh) {
        meshs.push_back(mesh);
    }

    uint16_t registerMaterial(Material material) {
        materials.push_back(material);
        return materials.size() - 1;
    }

    Material& getMaterial(uint16_t materialID) {
        return materials.at(materialID);
    }

    std::vector<Tri> getTris() {
        // get all the tris together
        std::vector<Tri> tris = std::vector<Tri>();
        for(Mesh mesh : meshs) {
            for (Tri tri : mesh.tris) {
                tris.push_back(tri);
            }
        }

        return tris;
    }
};