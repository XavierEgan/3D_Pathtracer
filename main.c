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
    Vec3 
    tlf, blf,
    tlb, blb,
    trf, brf,
    trb, brb;
    tlf = (Vec3){-1.0f, 1.0f, -1.0f}; // top left front corner
    blf = (Vec3){-1.0f, -1.0f, -1.0f}; // bottom left front corner

    tlb = (Vec3){1.0f, 1.0f, -1.0f}; // top left back corner
    blb = (Vec3){1.0f, -1.0f, -1.0f}; // bottom left back corner

    trf = (Vec3){-1.0f, 1.0f, 1.0f}; // top right front corner
    brf = (Vec3){-1.0f, -1.0f, 1.0f}; // bottom right front corner

    trb = (Vec3){1.0f, 1.0f, 1.0f}; // top right back corner
    brb = (Vec3){1.0f, -1.0f, 1.0f}; // bottom right back corner


    Tri* left_wall_tris = malloc(sizeof(Tri) * 2);
    left_wall_tris[0] = (Tri){tlb, blb, blf};
    left_wall_tris[1] = (Tri){tlb, tlf, blf};
    Mesh left_wall = init_mesh(2, left_wall_tris, (Color){100, 100, 100}, 1, 0);

    Tri* back_wall_tris = malloc(sizeof(Tri) * 2);
    back_wall_tris[0] = (Tri){tlb,brb, trb};
    back_wall_tris[1] = (Tri){tlb, blb, brb};
    Mesh back_wall = init_mesh(2, back_wall_tris, (Color){0, 255, 0}, 0, 1);

    Tri* right_wall_tris = malloc(sizeof(Tri) * 2);
    right_wall_tris[0] = (Tri){trb, brb, brf};
    right_wall_tris[1] = (Tri){trb, trf, brf};
    Mesh right_wall = init_mesh(2, right_wall_tris, (Color){255, 0, 255}, 0, 1);

    Tri* roof_tris = malloc(sizeof(Tri) * 2);
    roof_tris[0] = (Tri){tlb, trb, trf};
    roof_tris[1] = (Tri){tlb, tlf, trf};
    Mesh roof = init_mesh(2, roof_tris, (Color){0, 0, 255}, 0, 1);

    Tri* floor_tris = malloc(sizeof(Tri) * 2);
    floor_tris[0] = (Tri){blb, brb, brf};
    floor_tris[1] = (Tri){blb, blf, brf};
    Mesh floor = init_mesh(2, floor_tris, (Color){255, 0, 0}, 0, 1);

    Mesh rand_mesh = init_random_mesh(20, (Color){255, 255, 255}, -.5, .5, 0, 1);

    unsigned int num_meshs = 6;
    Mesh meshs[] = {left_wall, back_wall, right_wall, roof, floor, rand_mesh};

    float focal_length = 1;
    //1920x1080
    //640x360
    int width_px = 1080;
    int height_px = 1080;
    float horizontal_fov = 90.0f;
    float vertical_fov = 90.0f;
    int rays_per_pixel = 256;
    int num_bounces = 3;
    Vec3 pos = {-2, 0, 1};
    Vec3 forward = {1, 0, -1}; // gets normalized in init_camera anyway

    Camera cam = init_camera(focal_length, width_px, height_px, horizontal_fov, vertical_fov, rays_per_pixel, num_bounces, pos, forward);

    render(cam, meshs, num_meshs, "actual_scene.ppm");
    return 0;
}

int main2(void) {
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

int main3(void) {
    Tri* tri = malloc(sizeof(Tri));
    tri->a = (Vec3){0.0f, -1.0f, -1.0f};// bottom left corner
    tri->b = (Vec3){0.0f, -1.0f, 1.0f}; // bottom right corner
    tri->c = (Vec3){0.0f, 1.0f, 1.0f}; // top right
    Mesh mesh1 = init_mesh(1, tri, (Color){255, 255, 255}, 0, 1);
    Mesh meshs[] = {mesh1};
    unsigned int num_meshs = 1;

    float focal_length = 1;
    // 1920x1080
    //640x360
    int width_px = 100;
    int height_px = 100;
    float horizontal_fov = 90.0f;
    float vertical_fov = 90.0f;
    int rays_per_pixel = 256;
    int num_bounces = 3;
    Vec3 pos = {-5, 0, 0};
    Vec3 forward = {1, 0, 0};

    Camera cam = init_camera(focal_length, width_px, height_px, horizontal_fov, vertical_fov, rays_per_pixel, num_bounces, pos, forward);

    render(cam, meshs, num_meshs, "test_image.ppm");
}

