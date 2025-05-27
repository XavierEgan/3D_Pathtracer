#include "Tri.h"
#include "Vec3.h"

#define epsilon 0.0000001f

int ray_triangle_intercept(Vec3 ray, Vec3 ray_origin, Tri tri, Vec3* int_pos) {
    ray = vec_normalise(ray);

    Vec3 e1 = vec_sub(tri.b, tri.a);
    Vec3 e2 = vec_sub(tri.c, tri.a);
    Vec3 rxe2 = vec_cross(ray, e2);
    float det = vec_dot(e1, rxe2);

    if (det > -epsilon && det < epsilon) {
        return 0; // no intercept
    }

    float inv_det = 1.0f/det;
    Vec3 s = vec_sub(ray_origin, tri.a);
    float u = inv_det * vec_dot(s, rxe2);

    if (u < 0.0f || u > 1.0f) { // modified from the wiki to be stricter and more efficient saving a couple checks
        return 0; // no intercept
    }

    Vec3 sxe1 = vec_cross(s, e1);
    float v = inv_det * vec_dot(ray, sxe1);

    if (v < 0.0f || u + v > 1.0f) {
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

Vec3 tri_normal (Tri tri) {
    // cross of AB and AC
    return vec_normalise(
        vec_cross(
            vec_sub(tri.b, tri.a), //AB
            vec_sub(tri.c, tri.a)  //AC
        )
    );
}
