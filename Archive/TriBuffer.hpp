#pragma once

#include "../Math/Tri.cuh"
#include <vector>

struct TriBuffer {
    Tri* tris;
    size_t size;

    TriBuffer() {}
    TriBuffer(Tri* tris, size_t size) : tris(tris), size(size) {}

    __device__ Tri operator[](size_t index) {
        if (index < size) {
            return tris[index];
        } else {
            //std::out_of_range("Index out of range");
        }
        return Tri();
    }
};