#pragma once

#include <limits.h>

// this should be thread safe IFF each thread has a local seed
__host__ __device__ unsigned int randInt(unsigned int& seed) {
    seed = seed * 1664525 + 1013904223;
    return seed;
}

__host__ __device__ float randUniform(unsigned int& seed) {
    return randInt(seed) / ((float)UINT_MAX + 1.0f);
}

__host__ __device__ float randRange(unsigned int& seed, float min, float max) {
    int range_size = max - min;

    float u1 = randUniform(seed);
    u1 *= range_size; // gives [0, range_size)
    u1 += min; // gives [min, range_size + min)
    // since range_size = max - min
    // we can rewrite it as:
    // [min, max - min + min) = [min, max)
    return u1;
}