#include <stdlib.h>
#include <math.h>

#define epsilon 0.0000001f

typedef struct {
    float x;
    float y;
    float z;
} Vec3;

typedef struct {
    Vec3 a;
    Vec3 b;
    Vec3 c;
} Tri;

Vec3 vec_init(float x, float y, float z) {
    Vec3 vec = {x, y, z};
    return vec;
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

int ray_triangle_intercept(Vec3 ray, Vec3 ray_origin, Tri tri, Vec3* int_pos) {
    ray = vec_normalise(ray);

    Vec3 e1 = vec_sub(tri.b, tri.a);
    Vec3 e2 = vec_sub(tri.c, tri.a);
    Vec3 rxe2 = vec_cross(ray, e2);
    float det = vec_dot(e1, rxe2);

    if (det > -epsilon && det < epsilon) {
        return 0; // no intercept
    }

    float inv_det = 1.0/det;
    Vec3 s = vec_sub(ray_origin, tri.a);
    float u = inv_det * vec_dot(s, rxe2);

    if (u < 0.0 || u > 1.0) { // modified from the wiki to be stricter and more efficient saving a couple checks
        return 0; // no intercept
    }

    Vec3 sxe1 = vec_cross(s, e1);
    float v = inv_det * vec_dot(ray, sxe1);

    if (v < 0.0 || u + v > 1.0) {
        return 0; // no intercept
    }

    float t = inv_det * vec_dot(e2, sxe1);

    if (t > epsilon) {
        *int_pos = vec_add(ray_origin, vec_scale(ray, t));
        return 1; // intercept
    } else {
        return 0; // no intercept
    }
}
