#pragma once

#include <vector>
#include "Math/Tri.cuh"

#include "MeshStuff/teapot.hpp"

class HostMesh {
    std::vector<Tri> tris;

public:  
    HostMesh() = default;
    HostMesh(std::vector<Tri> tris) : tris(tris) {}

    static HostMesh plane(Vec3 c1, Vec3 c2, Vec3 c3, Vec3 c4, MaterialID materialID) {
        /*
        points should be ccw
        */
        Vec3 p1uv = Vec3(1, 1, 0);
        Vec3 p2uv = Vec3(0, 1, 0);
        Vec3 p3uv = Vec3(0, 0, 0);
        Vec3 p4uv = Vec3(1, 0, 0);

        std::vector<Tri> planeTris = {
            Tri(c1, c2, c3, p1uv, p2uv, p3uv, materialID), 
            Tri(c1, c3, c4, p1uv, p3uv, p4uv, materialID)
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

    static HostMesh cube(float size, Vec3 pos, MaterialID matId) {
        Vec3 
        tlf, blf,
        tlb, blb,
        trf, brf,
        trb, brb;
        tlf = Vec3(-1.0f, 1.0f, -1.0f) * size + pos; // top left front corner
        blf = Vec3(-1.0f, -1.0f, -1.0f) * size + pos; // bottom left front corner

        tlb = Vec3(1.0f, 1.0f, -1.0f) * size + pos; // top left back corner
        blb = Vec3(1.0f, -1.0f, -1.0f) * size + pos; // bottom left back corner

        trf = Vec3(-1.0f, 1.0f, 1.0f) * size + pos; // top right front corner
        brf = Vec3(-1.0f, -1.0f, 1.0f) * size + pos; // bottom right front corner

        trb = Vec3(1.0f, 1.0f, 1.0f) * size + pos; // top right back corner
        brb = Vec3(1.0f, -1.0f, 1.0f) * size + pos; // bottom right back corner

        HostMesh mesh = HostMesh();

        // Front face (z = -size)
        mesh.addTri(tlf, blf, trf, matId);
        mesh.addTri(trf, blf, brf, matId);

        // Right face (x = -size)
        mesh.addTri(trf, brf, tlf, matId);
        mesh.addTri(tlf, brf, blf, matId);

        // Back face (z = +size)
        mesh.addTri(trb, brb, tlb, matId);
        mesh.addTri(tlb, brb, blb, matId);

        // Left face (x = +size)
        mesh.addTri(tlb, blb, trb, matId);
        mesh.addTri(trb, blb, brb, matId);

        // Top face (y = +size)
        mesh.addTri(tlf, trf, tlb, matId);
        mesh.addTri(tlb, trf, trb, matId);

        // Bottom face (y = -size)
        mesh.addTri(blf, blb, brf, matId);
        mesh.addTri(brf, blb, brb, matId);

        return mesh;
    }

    static HostMesh icosahedron(float size, Vec3 pos, MaterialID matId) {
        //https://blog.lslabs.dev/posts/generating_icosphere_with_code
        const float phi = (1.0f + sqrt(5.0f)) * 0.5f; // the golden ratio

        Vec3 verts[12] = {
            Vec3(-1,  phi,  0),
            Vec3( 1,  phi,  0),
            Vec3(-1, -phi,  0),
            Vec3( 1, -phi,  0),

            Vec3( 0, -1,  phi),
            Vec3( 0,  1,  phi),
            Vec3( 0, -1, -phi),
            Vec3( 0,  1, -phi),

            Vec3( phi,  0, -1),
            Vec3( phi,  0,  1),
            Vec3(-phi,  0, -1),
            Vec3(-phi,  0,  1)
        };

        for (int i = 0; i < 12; ++i) {
            verts[i] = verts[i].normalized() * size + pos;
        }

        int faces[20][3] = {
            {0, 11, 5},
            {0, 5, 1},
            {0, 1, 7},
            {0, 7, 10},
            {0, 10, 11},

            {1, 5, 9},
            {5, 11, 4},
            {11, 10, 2},
            {10, 7, 6},
            {7, 1, 8},

            {3, 9, 4},
            {3, 4, 2},
            {3, 2, 6},
            {3, 6, 8},
            {3, 8, 9},

            {4, 9, 5},
            {2, 4, 11},
            {6, 2, 10},
            {8, 6, 7},
            {9, 8, 1}
        };

        HostMesh mesh = HostMesh();
        for (int i = 0; i < 20; ++i) {
            mesh.addTri(verts[faces[i][0]], verts[faces[i][1]], verts[faces[i][2]], matId);
        }

        return mesh;
    }


    std::vector<Tri> getTris() const {
        return tris;
    }

    static HostMesh wavySphere(
        float radius, const Vec3 pos, MaterialID matId,
        float xSquish,
        float zSquish,
        int slices = 64, int stacks = 32,
        float waveAmp = 0.08f, float waveFreq = 10.0f)
    {
        HostMesh mesh;

        // Precompute vertex positions
        std::vector<std::vector<Vec3>> verts(stacks + 1);
        for (int i = 0; i <= stacks; ++i) {
            float v = float(i) / stacks;
            float theta = v * 3.14159;

            verts[i].resize(slices + 1);
            for (int j = 0; j <= slices; ++j) {
                float u = float(j) / slices;
                float phi = u * 2.0f * 3.14159;

                float x = sinf(theta) * cosf(phi);
                float y = cosf(theta);
                float z = sinf(theta) * sinf(phi);

                float r = radius * (1.0f + waveAmp * sinf(waveFreq * theta + waveFreq * phi));

                Vec3 p = Vec3(x * xSquish, y, -z * zSquish) * r + pos; // -z to turn it inside out
                verts[i][j] = p;
            }
        }

        // Generate triangles (anticlockwise order for outside view)
        for (int i = 0; i < stacks; ++i) {
            for (int j = 0; j < slices; ++j) {
                Vec3 v1 = verts[i][j];
                Vec3 v2 = verts[i+1][j];
                Vec3 v3 = verts[i+1][j+1];
                Vec3 v4 = verts[i][j+1];

                mesh.addTri(v1, v2, v3, matId); // lower triangle
                mesh.addTri(v1, v3, v4, matId); // upper triangle
            }
        }

        return mesh;
    }

    static HostMesh utahTeapot(Vec3 pos, float scale, MaterialID matId, float yRotationDeg = 0.0f) {
        HostMesh mesh = HostMesh();

        float cosY = cos(yRotationDeg * 3.141592/180);
        float sinY = sin(yRotationDeg * 3.141592/180);

        Vec3 vertices[3];

        for (int i=0; i < teapot_count; i+=9) {
            for (int v=0; v < 3; v++) {
                Vec3 original(teapot[i + v*3], -teapot[i + v*3 + 1], -teapot[i + v*3 + 2]);

                // Apply Y rotation
                Vec3 rotated(
                    original.x * cosY + original.z * sinY,
                    original.y,
                    -original.x * sinY + original.z * cosY
                );

                vertices[v] = rotated * scale + pos;
            }
            mesh.addTri(vertices[0], vertices[1], vertices[2], matId);
        }
        return mesh;
    }

    Tri* getTrisPointer() {
        return tris.data();
    }

    void addTri(Vec3 v0, Vec3 v1, Vec3 v2, MaterialID matID) {
        tris.emplace_back(v0, v1, v2, matID);
    }
};