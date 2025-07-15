#pragma once

#include <vector>
#include "../../Math/Tri.cuh"

class HostMesh {
    std::vector<Tri> tris;

public:  
    HostMesh() : tris(std::vector<Tri>()) {}
    HostMesh(std::vector<Tri> tris) : tris(tris) {}

    static HostMesh plane(Vec3 c1, Vec3 c2, Vec3 c3, Vec3 c4, MaterialID materialID) {
        /*
        points should be clockwise or anticlockwise
        */
        std::vector<Tri> planeTris = {
            Tri(c1, c2, c3, materialID), 
            Tri(c1, c4, c3, materialID)
        };

        return HostMesh(planeTris);
    }

    std::vector<Tri> getTris() {
        return tris;
    }

    Tri* getTrisPointer() {
        return tris.data();
    }
};