#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "camera.h"
#include "../math/Vec3.h"

Camera init_camera(float focal_length, int width_pixels, int height_pixels, float width_fov, float height_fov, int rays_per_pixel, int num_bounces, Vec3 pos, Vec3 forward) {
    forward = vec_normalise(forward);

    // right is the cross product of forward and forward but moved down a lil bit (there is no roll which is why we can do this)
    Vec3 right = vec_normalise(vec_cross(vec_sub(forward, (Vec3){0,1,0}), forward));

    Vec3 up = vec_normalise(vec_cross(right, forward));

    float vertical_half_scale = tan(height_fov * (3.1415926535f/180) * .5f) * focal_length;
    float horizontal_half_scale = tan(width_fov * (3.1415926535f/180) * .5f) * focal_length;

    float px_height = (vertical_half_scale*2.0f)/height_pixels;
    float px_width = (horizontal_half_scale*2.0f)/width_pixels;

    Camera cam = {
        focal_length, width_pixels, height_pixels, width_fov*(3.1415926535f/180), height_fov*(3.1415926535f/180), 
        rays_per_pixel, num_bounces, 
        vertical_half_scale, horizontal_half_scale,
        px_height, px_width, 
        1.0f/RAND_MAX,
        pos, forward, up, right
    };

    return cam;
}
