#include <type_traits>

#include "../Math/Vec3.hpp"

struct Material {
    float transmission;
    float IOR;
    float roughness;
    float metallic;
};