#include "math/Math.h"

typedef struct {
    float focal_length;
    int width_pixels;
    int height_pixels;

    Vec3 pos;
    Vec3 rot;
} Camera;

Camera init_camera(float focal_length, int width_pixels, int height_pixels, Vec3 pos, Vec3 rot) {
    Camera cam = {focal_length, width_pixels, height_pixels, pos, rot};
    return cam;
}

