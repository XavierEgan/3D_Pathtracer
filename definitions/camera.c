#include <stdio.h>
#include "camera.h"
#include "../math/Vec3.h"

Camera init_camera(float focal_length, int width_pixels, int height_pixels, float width_fov, float height_fov, int rays_per_pixel, Vec3 pos, Vec3 forward) {
    forward = vec_normalise(forward);

    // right is the cross product of forward and forward but moved down a lil bit (there is no roll which is why we can do this)
    Vec3 right = vec_normalise(vec_cross(forward, vec_sub(forward, {0,1,0})));

    Vec3 up = vec_normalise(vec_cross(right, forward));

    Camera cam = {focal_length, width_pixels, height_pixels, rays_per_pixel, width_fov*(3.1415926535f/180), height_fov*(3.1415926535f/180), pos, forward, up, right};

    return cam;
}
