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

inline float vec_dot(Vec3 a, Vec3 b) {
    return a.x*b.x + a.y*b.y + a.z*b.z;
}

float vec_len(Vec3 a) {
    return sqrt(vec_dot(a, a));
}
