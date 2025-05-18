#ifndef CAMERA_H
#define CAMERA_H

#include "../math/Vec3.h"

typedef struct {
    float focal_length;
    int width_pixels;
    int height_pixels;
    int rays_per_pixel;

    Vec3 pos;
    Vec3 forward; // forward vec in global space
} Camera;

Camera init_camera(float focal_length, int width_pixels, int height_pixels, int rays_per_pixel, Vec3 pos, Vec3 forward);

#endif