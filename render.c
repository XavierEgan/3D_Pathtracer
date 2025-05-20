#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#include "render.h"

typedef struct {
    Vec3 I00
} viewplane;

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

            Render_Tri rtri = {tri, meshs[m].color};
            tris[true_num_tris] = rtri;

            true_num_tris++;
        }
    }
}

Vec3 get_next_ray() {

}

void render(Camera cam, Mesh* meshs, unsigned int num_meshs, char* filename) {
    // construct list of all triangles for efficient memory access
    Render_Tri_Buffer tri_buffer = get_tris(meshs, num_meshs);

    float vertical_half_scale = tan(cam.height_fov) * cam.focal_length;
    float horizontal_half_scale = tan(cam.height_fov) * cam.focal_length;

    Vec3 plane_offset = vec_add(cam.pos, vec_scale(cam.forward, cam.focal_length));

    Vec3 I00 = vec_add(vec_scale(cam.up, -vertical_half_scale), vec_scale(cam.right, -horizontal_half_scale));
    Vec3 I10 = vec_add(vec_scale(cam.up, vertical_half_scale), vec_scale(cam.right, -horizontal_half_scale));
    Vec3 I01 = vec_add(vec_scale(cam.up, -vertical_half_scale), vec_scale(cam.right, horizontal_half_scale));
    Vec3 I11 = vec_add(vec_scale(cam.up, vertical_half_scale), vec_scale(cam.right, horizontal_half_scale));

    

    for (unsigned int y=0; y<cam.height_pixels; y++) {
        for (unsigned int x=0; x<cam.width_pixels; x++) {
            Vec3 closest_intersec = {0.0f, 0.0f, 0.0f};
            Vec3 cur_intersec = {0.0f, 0.0f, 0.0f};
            Vec3 ray;
            for (unsigned int t=0; t<tri_buffer.num_tris; t++) {
                if (ray_triangle_intercept(ray, cam.pos, cur_intersec)) {
                    if (dist_bet_points(cam.pos, cur_intersec))
                }
            }
        }
    }
}
