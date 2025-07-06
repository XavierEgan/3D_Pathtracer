#pragma once

#include <type_traits>

#include "../Math/Vec3.cuh"

struct Environment {
    Vec3 skyColor;

    Environment(Vec3 skyColor) : skyColor(skyColor) {}
};