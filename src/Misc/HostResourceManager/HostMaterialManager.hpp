#pragma once

#include <vector>

#include "../MaterialID.hpp"
#include "HostMaterial.hpp"

class HostMaterialManager {
    std::vector<HostMaterial> materials;

public:
    HostMaterialManager() : materials(std::vector<HostMaterial>()) {}

    std::vector<HostMaterial> getMaterials() const {
        return materials;
    }

    MaterialID registerMaterial(HostMaterial material) {
        materials.push_back(material);
        return MaterialID(materials.size() - 1);
    }
};