#pragma once

#include <vector>

#include "../MaterialID.hpp"
#include "HostMaterial.hpp"

class HostMaterialManager {
    std::vector<HostMaterial> materials;

public:
    HostMaterialManager() = default;

    std::vector<HostMaterial> getMaterials() const {
        return materials;
    }

    MaterialID registerMaterial(HostMaterial material) {
        materials.push_back(material);
        return MaterialID(materials.size() - 1);
    }

    void print() const {
        for (HostMaterial hm : materials) {
            hm.print();
        }
    }
};