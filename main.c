#include <stdio.h>
#include <stdlib.h>

#include "math/Vec3.h"
#include "math/Tri.h"
#include "definitions/camera.h"
#include "definitions/color.h"
#include "definitions/framebuffer.h"
#include "definitions/mesh.h"
#include "render.h"

int main(void) {
    printf("hello");

    Mesh mesh1 = init_random_mesh(100, (Color){255,255,255}, -2, 2, 1, 0);
    Mesh mesh2 = init_random_mesh(100, (Color){255,255,255}, -2, 2, 0, 1);
    Mesh mesh3 = init_random_mesh(100, (Color){255,255,255}, -2, 2, 0, 0);
    Mesh meshs[] = {mesh1, mesh2, mesh3};
    unsigned int num_meshs = 3;

    float focal_length = 1;
    int width_px = 1920;
    int height_px = 1080;
    float horizontal_fov = 120.0f;
    float vertical_fov = 90.0f;
    int rays_per_pixel = 256;
    int num_bounces = 3;
    Vec3 pos = {0, -10, 0};
    Vec3 forward = {1, 0, 0};

    Camera cam = init_camera(focal_length, width_px, height_px, horizontal_fov, vertical_fov, rays_per_pixel, num_bounces, pos, forward);
    
    printf("hello 2");
    fflush(stdout);

    render(cam, meshs, num_meshs, "test");
}
