#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <math.h>

#include "render.h"
#include "fancy_loading_bar.h"

typedef struct {
    Tri tri;
    Color color;
    Vec3 albedo;
    Vec3 normal;
    int reflective;
    int emmisive;
} Render_Tri;

typedef struct {
    Render_Tri* tris;
    unsigned long num_tris; // may be smaller than tris
} Render_Tri_Buffer;

typedef struct {
    Color* data;
    unsigned int width;
    unsigned int height;
} Frame_Buffer;

Frame_Buffer alloc_frame_buffer(unsigned int width, unsigned int height) {
    Color* data = malloc(sizeof(Color) * width * height);
    if (!data) {
        // it joever
        fprintf(stderr, "alloc_frame_buffer alloc failed");
        abort();
    }
    return (Frame_Buffer){data, width, height};
}

void free_frame_buffer(Frame_Buffer *buffer) {
    free(buffer->data);
}

typedef struct {
    Render_Tri tri;
    Vec3 pos;
    float dist;
} Ray_Tri_Intercept;

void write_image(Camera cam, Frame_Buffer buffer, char* filename) {
    FILE *fp = fopen(filename, "wb");
    if (!fp) {
        fprintf(stderr, "Error opening file for writing\n");
        abort();
    }

    fprintf(fp, "P6\n%d %d\n255\n", cam.width_pixels, cam.height_pixels);

    for (unsigned int y=0; y<cam.height_pixels; y++) {
        for (unsigned int x=0; x<cam.width_pixels; x++) {
            fputc(buffer.data[y*cam.width_pixels + x].r, fp);
            fputc(buffer.data[y*cam.width_pixels + x].g, fp);
            fputc(buffer.data[y*cam.width_pixels + x].b, fp);
        }
    }
    fclose(fp);
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
    unsigned long long tri_index = 0;
    for (unsigned int m=0; m<num_meshs; m++) {
        for (unsigned int t=0; t<meshs[m].num_tris; t++) {
            Tri tri = meshs[m].tris[t];

            Render_Tri rtri = {tri, meshs[m].color, meshs[m].albedo, tri_normal(tri), meshs[m].reflective, meshs[m].emmisive};
            tris[tri_index] = rtri;

            tri_index++;
        }
    }
    return (Render_Tri_Buffer){tris, num_tris};
}

int get_intercept(Vec3 ray, Vec3 ray_origin, Render_Tri_Buffer tris, Ray_Tri_Intercept* ret) {
    int has_intercept = 0;

    Ray_Tri_Intercept closest_intercept;
    Vec3 cur_intercept;
    closest_intercept.dist = 999999999.0f;

    for (int t=0; t<tris.num_tris; t++) {
        // backface culling
        // if the salar projection of ray on tri normal is +ve then dont render coz its facing away
        if (vec_dot(tris.tris[t].normal, ray) > 0) {
            continue;
        }

        if (!ray_triangle_intercept(ray, ray_origin, tris.tris[t].tri, &cur_intercept)) {continue;}
        // we have at least one intercept
        has_intercept = 1;

        float cur_dist = dist_bet_points(ray_origin, cur_intercept);

        if (cur_dist < closest_intercept.dist) {
            // we have a new closest intercept
            closest_intercept.dist = cur_dist;
            closest_intercept.tri = tris.tris[t];
            closest_intercept.pos = cur_intercept;
        }
    }
    if (has_intercept) {
        ret->dist = closest_intercept.dist;
        ret->pos = closest_intercept.pos;
        ret->tri = closest_intercept.tri;
    }
    // if there is no intercept then we do nothing with ret anyway
    return has_intercept;
}

Vec3 trace_ray(Camera cam, Render_Tri_Buffer tris, Vec3 ray, Vec3 ray_origin) {
    // returns the color of the ray as a vec3 (x=r, y=g, z=b)

    // mallocing billions of times is probably a bad idea, refactor later
    Ray_Tri_Intercept* intercepts = malloc(sizeof(Ray_Tri_Intercept) * cam.num_bounces);

    int intercept_count = 0;

    for (unsigned int rb=0; rb<cam.num_bounces; rb++) {
        if (!get_intercept(ray, ray_origin, tris, &intercepts[rb])) {
            // we hit nothing which means this isnt lit so we just leave early
            free(intercepts);
            return (Vec3){0.0f, 0.0f, 0.0f};
        }

        // we have an intercept, handle it
        intercept_count++;
        if (intercepts[rb].tri.emmisive) {
            // we hit a light source
            if (rb == 0) {
                // we hit a light source on the first go, it should just be the saturated value of the light source
                free(intercepts);
                return (Vec3){intercepts[rb].tri.color.r, intercepts[rb].tri.color.g, intercepts[rb].tri.color.b};
            } else {
                // we hit a light source at some point, were done tracing the ray now
                break;
            }
        } else {
            // we didnt hit a light source (matte)
            // reflect the ray depending on material properties
            if (intercepts[rb].tri.reflective) {
                // its perfectly reflective
                ray = reflect_ray(ray, intercepts[rb].tri.normal);

                // move it a lil along to make sure it doesnt intersect the same triangle
                ray_origin = epsilon_shift(intercepts[rb].pos, ray);

                continue;
            } else {
                // its perfectly matte
                // cosine weighted sampling
                // source for algorithm: https://cseweb.ucsd.edu/~tzli/cse272/wi2023/lectures/malley_method.pdf

                // uniformly sample a point on a disk
                float r = sqrt(rand()*cam.inv_max_rand);
                float phi = 2.0f * PI * rand()*cam.inv_max_rand;

                Vec3 local_ray = vec_from_spherical(acos(sqrt(1.0f-r*r)), phi);

                // arbitrary tangent vector
                Vec3 tangent;
                Vec3 normal = intercepts[rb].tri.normal;
                if (normal.x>0 ? normal.x : -normal.x  > 0.9f) {
                    tangent = (Vec3){0.0f, 1.0f, 0.0f};
                } else {
                    tangent = (Vec3){1.0f, 0.0f, 0.0f};
                }

                // Gram-Schmidt orthogonalization
                tangent = vec_normalise(vec_sub(tangent, vec_scale(normal, vec_dot(tangent, normal))));

                // bitangent give us the the full basis
                Vec3 bitangent = vec_cross(normal, tangent);

                // Transform local direction to global space
                ray = vec_normalise(vec_add(vec_add(vec_scale(tangent, local_ray.x), vec_scale(bitangent, local_ray.y)), vec_scale(normal, local_ray.z)));

                ray_origin = epsilon_shift(intercepts[rb].pos, ray);
            }
        }
    }

    // backtrack through the ray trace to get a final color
    Vec3 final_color = {
        intercepts[intercept_count-1].tri.color.r, 
        intercepts[intercept_count-1].tri.color.g, 
        intercepts[intercept_count-1].tri.color.b
    }; // start out with the color of the light source hit

    for (int i=intercept_count-2; i >= 0; i--) {
        final_color = vec_mult(final_color, intercepts[i].tri.albedo);
    }

    free(intercepts);

    return final_color;
}

float final_scale(float x) {
    return x;
    //return pow(x * 255*255*255, 1.0f/4.0f);
}

Color get_pixel_color(Camera cam, Render_Tri_Buffer tris, float plane_x, float plane_y) {
    Vec3 running_color_total = {0.0f, 0.0f, 0.0f}; // just sum all the pixel values and average it at the end

    for (unsigned int r=0; r<cam.rays_per_pixel; r++) {
        // make the ray we are tracing
        float rand_x_off = rand() * cam.inv_max_rand * cam.px_width;
        float rand_y_off = rand() * cam.inv_max_rand * cam.px_height;
        Vec3 ray = vec_normalise(
            vec_add(
                vec_scale(cam.forward, cam.focal_length),
                vec_add(
                    vec_scale(cam.right, plane_x + rand_x_off),
                    vec_scale(cam.up, plane_y + rand_y_off)
                )
            )
        );
        Vec3 ray_origin = cam.pos;

        running_color_total = vec_add(running_color_total, trace_ray(cam, tris, ray, ray_origin));
    }
    
    running_color_total = vec_scale(running_color_total, 1.0f/cam.rays_per_pixel);

    return (Color){final_scale(running_color_total.x), final_scale(running_color_total.y), final_scale(running_color_total.z)};
}

void render(Camera cam, Mesh* meshs, unsigned int num_meshs, char* filename) {
    Frame_Buffer buffer = alloc_frame_buffer(cam.width_pixels, cam.height_pixels);

    Render_Tri_Buffer tris = get_tris(meshs, num_meshs);

    float plane_x;
    float plane_y;

    start_loading_bar(cam);

    for (unsigned int y=0; y<cam.height_pixels; y++) {
        for (unsigned int x=0; x<cam.width_pixels; x++) {
            plane_x = -cam.horizontal_half_scale + x * cam.px_width;
            plane_y = cam.vertical_half_scale - y * cam.px_height;

            buffer.data[y*cam.width_pixels + x] = get_pixel_color(cam, tris, plane_x, plane_y);

            update_loading_bar(cam.rays_per_pixel, 1);
        }
    }

    write_image(cam, buffer, filename);

    free_frame_buffer(&buffer);
}