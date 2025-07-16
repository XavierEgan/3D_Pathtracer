#pragma once

#include <vector>
#include "../../Math/Tri.cuh"

class HostMesh {
    std::vector<Tri> tris;

public:  
    HostMesh() = default;
    HostMesh(std::vector<Tri> tris) : tris(tris) {}

    static HostMesh plane(Vec3 c1, Vec3 c2, Vec3 c3, Vec3 c4, MaterialID materialID) {
        /*
        points should be ccw
        */
        std::vector<Tri> planeTris = {
            Tri(c1, c2, c3, materialID), 
            Tri(c1, c3, c4, materialID)
        };

        return HostMesh(planeTris);
    }

    static HostMesh randomMesh(float min, float max, size_t numTris, unsigned int& seed,  MaterialID materialID) {
        std::vector<Tri> randomMeshTris = std::vector<Tri>();

        for (int i=0; i < numTris; i++) {
            randomMeshTris.emplace_back(
                Vec3(randRange(seed, min, max), randRange(seed, min, max), randRange(seed, min, max)),
                Vec3(randRange(seed, min, max), randRange(seed, min, max), randRange(seed, min, max)),
                Vec3(randRange(seed, min, max), randRange(seed, min, max), randRange(seed, min, max)),
                materialID
            );
        }

        return HostMesh(randomMeshTris);
    }

    std::vector<Tri> getTris() const {
        return tris;
    }

    Tri* getTrisPointer() {
        return tris.data();
    }

    void addTri(Vec3 v0, Vec3 v1, Vec3 v2, MaterialID matID) {
        tris.emplace_back(v0, v1, v2, matID);
    }
};