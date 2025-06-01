#pragma once

#include <iostream>
#include <cmath>

#include "Vec3.hpp"

struct Tri {
    Vec3 p1;
    Vec3 p2;
    Vec3 p3;

    Vec3 calc_norm() const {
        Vec3 e1 = p2 - p1;
        Vec3 e2 = p3 - p1;
        return e1.cross(e2);
    }
};
