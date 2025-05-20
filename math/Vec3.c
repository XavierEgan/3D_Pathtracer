#include <stdlib.h>
#include <math.h>
#include "Vec3.h"

#define epsilon 0.0000001f

Vec3 vec_init(float x, float y, float z) {
    Vec3 vec = {x, y, z};
    return vec;
}

Vec3 vec_from_spherical(float pitch, float yaw) {
    Vec3 r = {
        cos(yaw)*cos(pitch),
        sin(pitch),
        sin(yaw)*cos(pitch)
    };
    return r;
}

Vec3 vec_add(Vec3 a, Vec3 b) {
    Vec3 r = {a.x + b.x, a.y + b.y, a.z + b.z};
    return r;
}

Vec3 vec_sub(Vec3 a, Vec3 b) {
    Vec3 r = {a.x - b.x, a.y - b.y, a.z - b.z};
    return r;
}

Vec3 vec_scale(Vec3 a, float scale) {
    Vec3 r = {a.x*scale, a.y*scale, a.z*scale};
    return r;
}

Vec3 vec_cross(Vec3 a, Vec3 b) {
    Vec3 r = {
        a.y*b.z - a.z*b.y, 
        a.z*b.x - a.x*b.z,
        a.x*b.y - a.y*b.x
    };
    return r;
}

Vec3 vec_normalise(Vec3 a) {
    float len = vec_len(a);
    if (abs(len-1)<epsilon) {
        return a;
    }

    return vec_scale(a, 1.0f/len);
}

Vec3 vec_proj(Vec3 on, Vec3 vec) {
    Vec3 on_norm = vec_normalise(on);
    return vec_scale(on_norm, vec_dot(vec, on_norm));
}

Vec3 vec_oproj(Vec3 on, Vec3 vec) {
    Vec3 on_norm = vec_normalise(on);
    return vec_sub(vec, vec_scale(on_norm, vec_dot(vec, on_norm)));
}

float vec_dot(Vec3 a, Vec3 b) {
    return a.x*b.x + a.y*b.y + a.z*b.z;
}

float vec_len(Vec3 a) {
    return sqrt(vec_dot(a, a));
}

double dist_bet_points(Vec3 p1, Vec3 p2) {
    return len(vec_sub(p2, p1));
}

Vec3 vec_project(Vec3 on, Vec3 vec) {
    Vec3 norm_vec = vec_normalise(vec);
    return vec_scale(norm_vec, vec_dot(on, norm_vec));
}
