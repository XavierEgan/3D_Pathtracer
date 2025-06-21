#pragma once

#include <limits>

// this should be thread safe IFF each thread has a local seed
int randInt(unsigned int& seed) {
    seed = seed * 1664525 + 1013904223;
    return seed;
}

float randUniform(unsigned int& seed) {
    return randInt(seed) / ((float)std::numeric_limits<unsigned int>::max() + 1.0f);
}
