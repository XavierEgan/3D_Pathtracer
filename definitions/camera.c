#include <stdio.h>
#include "camera.h"
#include "../math/Vec3.h"

Camera init_camera(float focal_length, int width_pixels, int height_pixels, float width_fov, float height_fov, int rays_per_pixel, Vec3 pos, Vec3 forward) {
    

    Camera cam = {focal_length, width_pixels, height_pixels, rays_per_pixel, width_fov*(3.1415926535f/180), height_fov*(3.1415926535f/180),pos, forward, {}};
    return cam;
}
