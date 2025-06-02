#pragma once

#include "Mat3.hpp"
#include "Ray.hpp"
#include "Tri.hpp"
#include "Vec3.hpp"
#include "Transform3D.hpp"

#include <cmath>

#define EPSILON = 1e-4f

float randf() {
    return rand() / (float)RAND_MAX;
}