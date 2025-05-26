#ifndef CAMERA_H
#define CAMERA_H

#include "../math/Vec3.h"

typedef struct {
    float focal_length;
    int width_pixels;
    int height_pixels;
    float width_fov;
    float height_fov;
    int rays_per_pixel;
    int num_bounces;

    // position on the plane of the corners
    float vertical_half_scale;
    float horizontal_half_scale;

    // height of a specifc pixel
    float px_height;
    float px_width;

    float inv_max_rand;

    Vec3 pos;
    Vec3 forward; // forward vec in global space
    Vec3 up;
    Vec3 right;
} Camera;

Camera init_camera(float focal_length, int width_pixels, int height_pixels, float width_fov, float height_fov, int rays_per_pixel, int num_bounces, Vec3 pos, Vec3 forward);

#endif