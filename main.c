#include <stdio.h>
#include <stdlib.h>

#include "math/Vec3.h"
#include "math/Tri.h"
#include "definitions/camera.h"
#include "definitions/color.h"
#include "definitions/framebuffer.h"
#include "definitions/mesh.h"
#include "render.h"

int main1(void) {
    Vec3 
    tlfc, blfc,
    tlbc, blbc,
    trfc, brfc,
    trbc, brbc;
    tlfc = (Vec3){-1.0f, 1.0f, -1.0f}; // top left front corner
    blfc = (Vec3){-1.0f, -1.0f, -1.0f}; // bottom left front corner

    tlbc = (Vec3){1.0f, 1.0f, -1.0f}; // top left back corner
    blbc = (Vec3){1.0f, -1.0f, -1.0f}; // bottom left back corner

    trfc = (Vec3){-1.0f, 1.0f, 1.0f}; // top right front corner
    brfc = (Vec3){-1.0f, -1.0f, 1.0f}; // bottom right front corner

    trbc = (Vec3){1.0f, 1.0f, 1.0f}; // top right back corner
    brbc = (Vec3){1.0f, -1.0f, 1.0f}; // bottom right back corner


    Tri* left_wall_tris = malloc(sizeof(Tri) * 2);
    left_wall_tris[0] = (Tri){tlfc, blfc, tlbc};
    left_wall_tris[1] = (Tri){tlbc, blfc, blbc};
    Mesh left_wall = init_mesh(2, left_wall_tris, (Color){255, 255, 255}, 0, 1);

    Tri* back_wall_tris = malloc(sizeof(Tri) * 2);
    back_wall_tris[0] = (Tri){tlbc, trbc, brbc};
    back_wall_tris[1] = (Tri){tlbc, blbc, brbc};
    Mesh back_wall = init_mesh(2, back_wall_tris, (Color){255, 255, 255}, 0, 1);

    unsigned int num_meshs = 2;
    Mesh meshs[] = {left_wall, back_wall};

    float focal_length = 1;
    //1920x1080
    //640x360
    int width_px = 50;
    int height_px = 50;
    float horizontal_fov = 120.0f;
    float vertical_fov = 90.0f;
    int rays_per_pixel = 256;
    int num_bounces = 3;
    Vec3 pos = {-6, 0, 0};
    Vec3 forward = {1, 0, 0};

    Camera cam = init_camera(focal_length, width_px, height_px, horizontal_fov, vertical_fov, rays_per_pixel, num_bounces, pos, forward);

    render(cam, meshs, num_meshs, "actual_scene.ppm");
    return 1;
}


int main(void) {
    Mesh mesh1 = init_random_mesh(20, (Color){255,255,255}, -2, 2, 1, 0);
    Mesh mesh2 = init_random_mesh(20, (Color){255,255,255}, -2, 2, 0, 1);
    Mesh mesh3 = init_random_mesh(20, (Color){255,255,255}, -2, 2, 0, 0);
    Mesh meshs[] = {mesh1, mesh2, mesh3};
    unsigned int num_meshs = 3;

    float focal_length = 1;
    // 1920x1080
    //640x360
    int width_px = 100;
    int height_px = 100;
    float horizontal_fov = 120.0f;
    float vertical_fov = 90.0f;
    int rays_per_pixel = 256;
    int num_bounces = 3;
    Vec3 pos = {-5, 0, 0};
    Vec3 forward = {1, 0, 0};

    Camera cam = init_camera(focal_length, width_px, height_px, horizontal_fov, vertical_fov, rays_per_pixel, num_bounces, pos, forward);

    render(cam, meshs, num_meshs, "test_image.ppm");
}

