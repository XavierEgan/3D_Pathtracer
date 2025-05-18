#include <stdio.h>
#include "camera.h"
#include "../math/Vec3.h"

Camera init_camera(float focal_length, int width_pixels, int height_pixels, int rays_per_pixel, Vec3 pos, Vec3 rot) {
    Camera cam = {focal_length, width_pixels, height_pixels, rays_per_pixel, pos, rot};
    return cam;
}
