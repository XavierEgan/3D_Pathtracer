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
