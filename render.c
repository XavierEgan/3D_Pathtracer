#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <math.h>

#include "render.h"
#include "fancy_loading_bar.h"

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
    unsigned long num_tris = 0;
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
    return (Render_Tri_Buffer){tris, num_tris};
}

typedef struct {
    Render_Tri render_tri;
    Vec3 loc;
} Ray_Tri_Int;

int trace_ray(Camera cam, Render_Tri_Buffer tri_buffer, Vec3 ray, Ray_Tri_Int* rt) {
    float cur_dist;
    float closest_dist = 999999999;

    Vec3 cur_intersec, closest_intersec;
    Vec3 tracing_ray = ray;
    Render_Tri closest_tri;

    int has_intersec;

    for (unsigned int r=0; r<cam.num_bounces; r++) {
        has_intersec = 0;
        // check if the ray intersecs any triangles
        for (unsigned int t=0; t<tri_buffer.num_tris; t++) {
            // check if the ray intersects the triangle
            if (!ray_triangle_intercept(ray, cam.pos, tri_buffer.tris[t].tri, &cur_intersec)) {
                continue;
            }

            // there is at least one intersec
            has_intersec = 1;

            // get the distance from cam to the point
            cur_dist = dist_bet_points(cur_intersec, cam.pos);

            // check if its the closest intersec so far
            if (cur_dist < closest_dist) {
                closest_dist = cur_dist;
                closest_intersec = cur_intersec;
                closest_tri = tri_buffer.tris[t];
            }
        }

        if (!has_intersec) {
            rt = NULL;
            return 0;
        }

        
    }
}

Color trace_pixel(Camera cam, Render_Tri_Buffer tri_buffer, float px_width, float px_height, float horizontal_half_scale, float vertical_half_scale) {
    float rand_x_off, rand_y_off;
    float inv_max_rand = 1.0f/RAND_MAX;

    Vec3 ray;

    for (unsigned int r=0; r<cam.rays_per_pixel; r++) {
        rand_x_off = rand() * inv_max_rand * px_width;
        rand_y_off = rand() * inv_max_rand * px_height;
        // ray = (pos + forward*focal_len) + (right*(horizontal_half_scale + rand_x_off) + up*(vertical_half_scale + rand_y_off))
        ray = vec_add(
            vec_add(cam.pos, vec_scale(cam.forward, cam.focal_length)), // +
            vec_add(
                vec_scale(cam.right, horizontal_half_scale + rand_x_off), 
                vec_scale(cam.up, vertical_half_scale + rand_y_off))
        );
        Ray_Tri_Int intersection;
        if (!trace_ray(cam, tri_buffer, ray, &intersection)) {
            continue;
        }

    }
}

void render(Camera cam, Mesh* meshs, unsigned int num_meshs, char* filename) {
    // alloc a frame buffer to write to
    Color* data = malloc(sizeof(Color) * cam.height_pixels * cam.width_pixels);
    Frame_Buffer buffer = {data, cam.width_pixels, cam.height_pixels};

    // construct list of all triangles for efficient memory access
    Render_Tri_Buffer tri_buffer = get_tris(meshs, num_meshs);

    // position on the plane of the corners
    float vertical_half_scale = tan(cam.height_fov) * cam.focal_length;
    float horizontal_half_scale = tan(cam.width_fov) * cam.focal_length;

    // height of a specifc pixel
    float px_height = (vertical_half_scale*2.0f)/cam.height_pixels;
    float px_width = (horizontal_half_scale*2.0f)/cam.width_pixels;

    // starting position on the screen (then we sweep across)
    float plane_x = -horizontal_half_scale;
    float plane_y = vertical_half_scale;

    Color pixel_color;

    float rand_x_off;
    float rand_y_off;

    float inv_max_rand = 1.0f/RAND_MAX;

    Vec3 ray;

    Color pix_color;

    start_loading_bar(cam);

    for (unsigned int y=0; y<cam.height_pixels; y++) {
        for (unsigned int x=0; x<cam.width_pixels; x++) {
            data[y*cam.width_pixels + x] = trace_pixel(cam, tri_buffer, px_width, px_height, horizontal_half_scale, vertical_half_scale);
            plane_x += px_width;

            update_loading_bar(cam.rays_per_pixel, 1);
        }
        plane_y += px_height;
        plane_x = -horizontal_half_scale;
    }
}
