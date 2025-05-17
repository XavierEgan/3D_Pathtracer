#include "Vec3.h"
#ifndef TRI_H
#define TRI_H

typedef struct {
    Vec3 a;
    Vec3 b;
    Vec3 c;
} Tri;

int ray_triangle_intercept(Vec3 ray, Vec3 ray_origin, Tri tri, Vec3* int_pos);

Vec3 tri_normal (Tri tri);

#endif