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
    Mesh mesh1 = init_random_mesh(100, (Color){255,255,255}, -2, 2, 1, 0);
    Mesh mesh2 = init_random_mesh(100, (Color){255,255,255}, -2, 2, 0, 1);
    Mesh mesh3 = init_random_mesh(100, (Color){255,255,255}, -2, 2, 0, 0);
    Mesh meshs[] = {mesh1, mesh2, mesh3};
    unsigned int num_meshs = 3;

    Camera cam = init_camera(1, 1280, 720, 120, 90, 256, (Vec3){0, -10, 0}, (Vec3){1, 0, 0});

    render(cam, meshs, num_meshs, "test");

    
}
