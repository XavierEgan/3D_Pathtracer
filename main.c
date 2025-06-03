#include <stdio.h>
#include <stdlib.h>

#include "math/Vec3.h"
#include "math/Tri.h"
#include "definitions/camera.h"
#include "definitions/color.h"
#include "definitions/framebuffer.h"
#include "definitions/mesh.h"
#include "render.h"

#define NUM_THREADS 24

void scenetest() {
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
    left_wall_tris[0] = (Tri){tlb, blf, blb};
    left_wall_tris[1] = (Tri){tlb, tlf, blf};
    Mesh left_wall = init_mesh(2, left_wall_tris, (Color){100, 100, 100}, 1, 0);

    Tri* back_wall_tris = malloc(sizeof(Tri) * 2);
    back_wall_tris[0] = (Tri){tlb,brb, trb};
    back_wall_tris[1] = (Tri){tlb, blb, brb};
    Mesh back_wall = init_mesh(2, back_wall_tris, (Color){0, 255, 0}, 0, 0);

    Tri* right_wall_tris = malloc(sizeof(Tri) * 2);
    right_wall_tris[0] = (Tri){trb, brb, brf};
    right_wall_tris[1] = (Tri){trb, brf, trf};
    Mesh right_wall = init_mesh(2, right_wall_tris, (Color){0, 0, 255}, 0, 0); // usually 0 0 255

    Tri* roof_tris = malloc(sizeof(Tri) * 2);
    roof_tris[0] = (Tri){tlb, trb, trf};
    roof_tris[1] = (Tri){tlb, trf, tlf};
    Mesh roof = init_mesh(2, roof_tris, (Color){255, 255, 0}, 0, 0);

    Tri* floor_tris = malloc(sizeof(Tri) * 2);
    floor_tris[0] = (Tri){blb, brf, brb};
    floor_tris[1] = (Tri){blb, blf, brf};
    Mesh floor = init_mesh(2, floor_tris, (Color){255, 0, 255}, 0, 0);

    Mesh rand_mesh = init_random_mesh(20, (Color){255, 255, 255}, -.5, .5, 0, 1);

    unsigned int num_meshs = 6;
    Mesh meshs[] = {left_wall, back_wall, right_wall, roof, floor, rand_mesh};

    float focal_length = 1;
    //1920x1080
    //640x360
    int width_px = 100;
    int height_px = 100;
    float horizontal_fov = 90.0f;
    float vertical_fov = 90.0f;
    int rays_per_pixel = 256*4;
    int num_bounces = 20; // there is early exit so most rays are only gonna bounce a couple times
    Vec3 pos = {-1 , 0, 1};
    Vec3 forward = {1, 0, -1.7}; // gets normalized in init_camera anyway

    Camera cam = init_camera(focal_length, width_px, height_px, horizontal_fov, vertical_fov, rays_per_pixel, num_bounces, pos, forward);

    render(cam, meshs, num_meshs, "scenetest.ppm");
}

void scene1() {
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
    left_wall_tris[0] = (Tri){tlb, blf, blb};
    left_wall_tris[1] = (Tri){tlb, tlf, blf};
    Mesh left_wall = init_mesh(2, left_wall_tris, (Color){100, 100, 100}, 1, 0);

    Tri* back_wall_tris = malloc(sizeof(Tri) * 2);
    back_wall_tris[0] = (Tri){tlb,brb, trb};
    back_wall_tris[1] = (Tri){tlb, blb, brb};
    Mesh back_wall = init_mesh(2, back_wall_tris, (Color){0, 255, 0}, 0, 0);

    Tri* right_wall_tris = malloc(sizeof(Tri) * 2);
    right_wall_tris[0] = (Tri){trb, brb, brf};
    right_wall_tris[1] = (Tri){trb, brf, trf};
    Mesh right_wall = init_mesh(2, right_wall_tris, (Color){0, 0, 255}, 0, 0); // usually 0 0 255

    Tri* roof_tris = malloc(sizeof(Tri) * 2);
    roof_tris[0] = (Tri){tlb, trb, trf};
    roof_tris[1] = (Tri){tlb, trf, tlf};
    Mesh roof = init_mesh(2, roof_tris, (Color){255, 255, 0}, 0, 0);

    Tri* floor_tris = malloc(sizeof(Tri) * 2);
    floor_tris[0] = (Tri){blb, brf, brb};
    floor_tris[1] = (Tri){blb, blf, brf};
    Mesh floor = init_mesh(2, floor_tris, (Color){255, 0, 255}, 0, 0);

    Mesh rand_mesh = init_random_mesh(20, (Color){255, 255, 255}, -.5, .5, 0, 1);

    unsigned int num_meshs = 6;
    Mesh meshs[] = {left_wall, back_wall, right_wall, roof, floor, rand_mesh};

    float focal_length = 1;
    //1920x1080
    //640x360
    int width_px = 500;
    int height_px = 500;
    float horizontal_fov = 90.0f;
    float vertical_fov = 90.0f;
    int rays_per_pixel = 256*4;
    int num_bounces = 20; // there is early exit so most rays are only gonna bounce a couple times
    Vec3 pos = {-1 , 0, 1};
    Vec3 forward = {1, 0, -1.7}; // gets normalized in init_camera anyway

    Camera cam = init_camera(focal_length, width_px, height_px, horizontal_fov, vertical_fov, rays_per_pixel, num_bounces, pos, forward);

    render(cam, meshs, num_meshs, "scene1.ppm");
}

// mirrors one
void scene2() {
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
    left_wall_tris[0] = (Tri){tlb, blf, blb};
    left_wall_tris[1] = (Tri){tlb, tlf, blf};
    Mesh left_wall = init_mesh(2, left_wall_tris, (Color){200, 200, 200}, 1, 0);

    Tri* back_wall_tris = malloc(sizeof(Tri) * 2);
    back_wall_tris[0] = (Tri){tlb,brb, trb};
    back_wall_tris[1] = (Tri){tlb, blb, brb};
    Mesh back_wall = init_mesh(2, back_wall_tris, (Color){0, 255, 0}, 0, 0);

    Tri* right_wall_tris = malloc(sizeof(Tri) * 2);
    right_wall_tris[0] = (Tri){trb, brb, brf};
    right_wall_tris[1] = (Tri){trb, brf, trf};
    Mesh right_wall = init_mesh(2, right_wall_tris, (Color){200, 200, 200}, 1, 0); // usually 0 0 255

    Tri* roof_tris = malloc(sizeof(Tri) * 2);
    roof_tris[0] = (Tri){tlb, trb, trf};
    roof_tris[1] = (Tri){tlb, trf, tlf};
    Mesh roof = init_mesh(2, roof_tris, (Color){255, 255, 0}, 0, 0);

    Tri* floor_tris = malloc(sizeof(Tri) * 2);
    floor_tris[0] = (Tri){blb, brf, brb};
    floor_tris[1] = (Tri){blb, blf, brf};
    Mesh floor = init_mesh(2, floor_tris, (Color){255, 0, 255}, 0, 0);

    Mesh rand_mesh = init_random_mesh(20, (Color){255, 255, 255}, -.5, .5, 0, 1);

    unsigned int num_meshs = 6;
    Mesh meshs[] = {left_wall, back_wall, right_wall, roof, floor, rand_mesh};

    float focal_length = 1;
    //1920x1080
    //640x360
    int width_px = 500;
    int height_px = 500;
    float horizontal_fov = 90.0f;
    float vertical_fov = 90.0f;
    int rays_per_pixel = 256*4;
    int num_bounces = 50; // there is early exit so most rays are only gonna bounce a couple times
    Vec3 pos = {-.9 , 0, 1};
    Vec3 forward = {.9, 0, -1}; // gets normalized in init_camera anyway

    Camera cam = init_camera(focal_length, width_px, height_px, horizontal_fov, vertical_fov, rays_per_pixel, num_bounces, pos, forward);

    render(cam, meshs, num_meshs, "scene2.ppm");
}

// high fidelity mirrors one
void scene3() {
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
    left_wall_tris[0] = (Tri){tlb, blf, blb};
    left_wall_tris[1] = (Tri){tlb, tlf, blf};
    Mesh left_wall = init_mesh(2, left_wall_tris, (Color){200, 200, 200}, 1, 0);

    Tri* back_wall_tris = malloc(sizeof(Tri) * 2);
    back_wall_tris[0] = (Tri){tlb,brb, trb};
    back_wall_tris[1] = (Tri){tlb, blb, brb};
    Mesh back_wall = init_mesh(2, back_wall_tris, (Color){0, 255, 0}, 0, 0);

    Tri* right_wall_tris = malloc(sizeof(Tri) * 2);
    right_wall_tris[0] = (Tri){trb, brb, brf};
    right_wall_tris[1] = (Tri){trb, brf, trf};
    Mesh right_wall = init_mesh(2, right_wall_tris, (Color){200, 200, 200}, 1, 0); // usually 0 0 255

    Tri* roof_tris = malloc(sizeof(Tri) * 2);
    roof_tris[0] = (Tri){tlb, trb, trf};
    roof_tris[1] = (Tri){tlb, trf, tlf};
    Mesh roof = init_mesh(2, roof_tris, (Color){255, 255, 0}, 0, 0);

    Tri* floor_tris = malloc(sizeof(Tri) * 2);
    floor_tris[0] = (Tri){blb, brf, brb};
    floor_tris[1] = (Tri){blb, blf, brf};
    Mesh floor = init_mesh(2, floor_tris, (Color){255, 0, 255}, 0, 0);

    Mesh rand_mesh = init_random_mesh(20, (Color){255, 255, 255}, -.5, .5, 0, 1);

    unsigned int num_meshs = 6;
    Mesh meshs[] = {left_wall, back_wall, right_wall, roof, floor, rand_mesh};

    float focal_length = 1;
    //1920x1080
    //640x360
    int width_px = 1000;
    int height_px = 1000;
    float horizontal_fov = 90.0f;
    float vertical_fov = 90.0f;
    int rays_per_pixel = 256*16;
    int num_bounces = 50; // there is early exit so most rays are only gonna bounce a couple times
    Vec3 pos = {-.9 , 0, 1};
    Vec3 forward = {.9, 0, -1}; // gets normalized in init_camera anyway

    Camera cam = init_camera(focal_length, width_px, height_px, horizontal_fov, vertical_fov, rays_per_pixel, num_bounces, pos, forward);

    render(cam, meshs, num_meshs, "scene3.ppm");
}

void scene4() {
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
    left_wall_tris[0] = (Tri){tlb, blf, blb};
    left_wall_tris[1] = (Tri){tlb, tlf, blf};
    Mesh left_wall = init_mesh(2, left_wall_tris, (Color){255, 0, 0}, 0, 0);

    Tri* back_wall_tris = malloc(sizeof(Tri) * 2);
    back_wall_tris[0] = (Tri){tlb,brb, trb};
    back_wall_tris[1] = (Tri){tlb, blb, brb};
    Mesh back_wall = init_mesh(2, back_wall_tris, (Color){0, 255, 0}, 0, 0);

    Tri* right_wall_tris = malloc(sizeof(Tri) * 2);
    right_wall_tris[0] = (Tri){trb, brb, brf};
    right_wall_tris[1] = (Tri){trb, brf, trf};
    Mesh right_wall = init_mesh(2, right_wall_tris, (Color){255, 255, 255}, 0, 1); // usually 0 0 255

    Tri* roof_tris = malloc(sizeof(Tri) * 2);
    roof_tris[0] = (Tri){tlb, trb, trf};
    roof_tris[1] = (Tri){tlb, trf, tlf};
    Mesh roof = init_mesh(2, roof_tris, (Color){255, 255, 255}, 0, 0);

    Tri* floor_tris = malloc(sizeof(Tri) * 2);
    floor_tris[0] = (Tri){blb, brf, brb};
    floor_tris[1] = (Tri){blb, blf, brf};
    Mesh floor = init_mesh(2, floor_tris, (Color){255, 0, 255}, 0, 0);

    Mesh rand_mesh = init_random_mesh(20, (Color){255, 255, 255}, -.5, .5, 0, 0);

    unsigned int num_meshs = 6;
    Mesh meshs[] = {left_wall, back_wall, right_wall, roof, floor, rand_mesh};

    float focal_length = 1.0f;
    //1920x1080
    //640x360
    int width_px = 500;
    int height_px = 500;
    float horizontal_fov = 90.0f;
    float vertical_fov = 90.0f;
    int rays_per_pixel = 256*4;
    int num_bounces = 20; // there is early exit so most rays are only gonna bounce a couple times
    Vec3 pos = {-3 , 0, 0};
    Vec3 forward = {1, 0, 0}; // gets normalized in init_camera anyway

    Camera cam = init_camera(focal_length, width_px, height_px, horizontal_fov, vertical_fov, rays_per_pixel, num_bounces, pos, forward);

    render(cam, meshs, num_meshs, "scene4.ppm");
}

void scene4_1() {
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
    left_wall_tris[0] = (Tri){tlb, blf, blb};
    left_wall_tris[1] = (Tri){tlb, tlf, blf};
    Mesh left_wall = init_mesh(2, left_wall_tris, (Color){255, 0, 0}, 0, 0);

    Tri* back_wall_tris = malloc(sizeof(Tri) * 2);
    back_wall_tris[0] = (Tri){tlb,brb, trb};
    back_wall_tris[1] = (Tri){tlb, blb, brb};
    Mesh back_wall = init_mesh(2, back_wall_tris, (Color){0, 255, 0}, 0, 0);

    Tri* right_wall_tris = malloc(sizeof(Tri) * 2);
    right_wall_tris[0] = (Tri){trb, brb, brf};
    right_wall_tris[1] = (Tri){trb, brf, trf};
    Mesh right_wall = init_mesh(2, right_wall_tris, (Color){255, 255, 255}, 0, 1); // usually 0 0 255

    Tri* roof_tris = malloc(sizeof(Tri) * 2);
    roof_tris[0] = (Tri){tlb, trb, trf};
    roof_tris[1] = (Tri){tlb, trf, tlf};
    Mesh roof = init_mesh(2, roof_tris, (Color){255, 255, 255}, 0, 0);

    Tri* floor_tris = malloc(sizeof(Tri) * 2);
    floor_tris[0] = (Tri){blb, brf, brb};
    floor_tris[1] = (Tri){blb, blf, brf};
    Mesh floor = init_mesh(2, floor_tris, (Color){255, 0, 255}, 0, 0);

    Mesh rand_mesh = init_random_mesh(10, (Color){255, 255, 255}, -.5, .5, 0, 0);

    unsigned int num_meshs = 6;
    Mesh meshs[] = {left_wall, back_wall, right_wall, roof, floor, rand_mesh};

    float focal_length = 1.0f;
    int width_px  = 512; // 1024
    int height_px = 512; // 1024
    float horizontal_fov = 90.0f;
    float vertical_fov   = 90.0f;
    int rays_per_pixel = 256*1;
    int num_bounces = 4; // there is early exit so most rays are only gonna bounce a couple times
    Vec3 pos = {-2 , 0, .8};
    Vec3 forward = {1, 0, -.4}; // gets normalized in init_camera anyway

    Camera cam = init_camera(focal_length, width_px, height_px, horizontal_fov, vertical_fov, rays_per_pixel, num_bounces, pos, forward);

    render(cam, meshs, num_meshs, "scene4_1.ppm");
}


int main(void) {
    scene4_1();
    return 0;
}
/*
int main2(void) {
    Mesh mesh1 = init_random_mesh(20, (Color){255,255,255}, -2, 2, 1, 0);
    Mesh mesh2 = init_random_mesh(20, (Color){255,255,255}, -2, 2, 0, 1);
    Mesh mesh3 = init_random_mesh(20, (Color){255,255,255}, -2, 2, 0, 0);
    Mesh meshs[] = {mesh1, mesh2, mesh3};
    unsigned int num_meshs = 3;

    float focal_length = 1;
    // 1920x1080
    // 640x360
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

    return 0;
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

    return 0;
}
*/