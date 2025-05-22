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

    Vec3 pos;
    Vec3 forward; // forward vec in global space
    Vec3 up;
    Vec3 right;
} Camera;

Camera init_camera(float focal_length, int width_pixels, int height_pixels, float width_fov, float height_fov, int rays_per_pixel, int num_bounces, Vec3 pos, Vec3 forward);

#endif