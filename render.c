#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#include "render.h"

typedef struct {
    Color* data;
    unsigned int width;
    unsigned int height;
} Frame_Buffer;

int render_tri(Tri tri) {
    return 1; // will be properly implimented later
}

Render_Tri_Buffer get_tris(Mesh* meshs, unsigned int num_meshs) {
    // first, how many tris do we have?
    unsigned long long num_tris = 0;
    for (unsigned int m=0; m<num_meshs; m++) {
        num_tris += meshs[m].num_tris;
    }

    // we will have at most this many triangles, so alloc a list to hold them all
    Render_Tri* tris = malloc(sizeof(Render_Tri) * num_tris);
    if (!tris) {
        // completely unrecoverable.
        fprintf(stderr, "Render_Tri_Buffer alloc failed");
        abort();
    }

    // fill the list with Render_Tri
    unsigned long long true_num_tris = 0;
    for (unsigned int m=0; m<num_meshs; m++) {
        for (unsigned int t=0; t<meshs[m].num_tris; t++) {
            Tri tri = meshs[m].tris[t];

            if (!render_tri(tri)) {
                continue;
            }

            Render_Tri rtri = {tri, meshs[m].color, tri_normal(tri), meshs[m].reflective, meshs[m].emmisive};
            tris[true_num_tris] = rtri;

            true_num_tris++;
        }
    }
}

Color trace_ray(Vec3 ray, Vec3 ray_origin, Render_Tri_Buffer tris, int num_bounces) {

}

void render(Camera cam, Mesh* meshs, unsigned int num_meshs, char* filename) {
    // alloc a frame buffer to write to
    Color* data = malloc(sizeof(Color) * cam.height_pixels * cam.width_pixels);
    Frame_Buffer buffer = {data, cam.width_pixels, cam.height_pixels};

    // construct list of all triangles for efficient memory access
    Render_Tri_Buffer tri_buffer = get_tris(meshs, num_meshs);

    float vertical_half_scale = tan(cam.height_fov) * cam.focal_length;
    float horizontal_half_scale = tan(cam.height_fov) * cam.focal_length;

    float px_height = (vertical_half_scale*2.0f)/cam.height_pixels;
    float px_width = (horizontal_half_scale*2.0f)/cam.width_pixels;

    float plane_x = -horizontal_half_scale;
    float plane_y = vertical_half_scale;

    Vec3 ray;
    Color pixel_color;

    for (unsigned int y=0; y<cam.height_pixels; y++) {
        for (unsigned int x=0; x<cam.width_pixels; x++) {
            // get the next ray to trace
            ray = vec_add(vec_add(vec_scale(cam.up, plane_y), vec_scale(cam.right, plane_x)), vec_scale(cam.forward, cam.focal_length));

            // trace the ray
            pixel_color = trace_ray(ray, cam.pos, tri_buffer, cam.num_bounces);

            // write pixel to buffer
            buffer.data[y*cam.width_pixels + x] = pixel_color;

            plane_x += px_width;
        }
        plane_y += px_height;
    }
}
