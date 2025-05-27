// this was the old render file but it didnt work properly and I had 5 layers of nesting so i rewrote it lmao

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

typedef struct {
    Render_Tri tri;
    Vec3 pos;
    float dist;
} Ray_Tri_Intercept;

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
    return (Render_Tri_Buffer){tris, true_num_tris};
}

void get_pixel_ray_colors(Camera cam, float plane_x, float plane_y, ) {
    for (unsigned int r=0; r<cam.rays_per_pixel; r++) {
        float rand_x_off = rand() * cam.inv_max_rand * cam.px_width;
        float rand_y_off = rand() * cam.inv_max_rand * cam.px_height;
        // ray = forward*focal_len + (right*(horizontal_half_scale + rand_x_off) + up*(vertical_half_scale + rand_y_off))
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
        
        int count_bounces = 0;
        closest_intercept.dist = 999999999.0f;

        // we just need to fill up the ray_intercepts array here then we will backtrack through it later
        for (unsigned int rt=0; rt<cam.num_bounces; rt++) {
            has_intersec = 0;
            // check if the ray intersecs any triangles
            for (unsigned int t=0; t<tri_buffer.num_tris; t++) {
                // check if the ray intersects the triangle
                if (!ray_triangle_intercept(ray, ray_origin, tri_buffer.tris[t].tri, &cur_intersec)) {
                    continue;
                }

                // there is at least one intersec
                has_intersec = 1;

                // get the distance from ray_origin to the point
                cur_dist = dist_bet_points(cur_intersec, ray_origin);

                // check if its the closest intersec so far
                if (cur_dist < closest_intercept.dist) {
                    closest_intercept.dist = cur_dist;
                    closest_intercept.pos = cur_intersec;
                    closest_intercept.tri = tri_buffer.tris[t];
                }
            }
            if (!has_intersec) {
                pixel_colors[r] = (Vec3){0.0f, 0.0f, 0.0f}; // color is black
                break; // there are no more bounces (break and go to next ray)
            }
            
            //printf("test");
            // we do have an intersection
            count_bounces++;
            if (closest_intercept.tri.emmisive) {
                if (rt == 0) {
                    // we hit a light source on the first go, lucky us
                    // "return" the lights color immidiently
                    pixel_colors[r] = (Vec3){closest_intercept.tri.color.r, closest_intercept.tri.color.g, closest_intercept.tri.color.b};
                    break; // there are no more bounces (break and go to next ray)
                    // since has_intersec is zero, there will be no backtracking through our ray_intercepts list
                } else {
                    break; // there are no more bounces (break and go to next ray)
                }
            } else {
                // we hit a triangle
                // what type of reflectiveness is it?
                if (closest_intercept.tri.reflective) {
                    // its reflective so simply just reflect the ray
                    ray_origin = closest_intercept.pos;
                    // R = reflected ray, I = incidence ray, N = tri normal
                    // R = I - 2(ProjN(I))
                    Vec3 N = closest_intercept.tri.normal;
                    Vec3 I = ray;
                    ray = vec_sub(I, vec_scale(vec_proj(N, I), 2.0f));

                    // add the thing we hit to the ray_intercepts array
                    ray_intercepts[rt] = closest_intercept;
                } else {
                    // its not reflective 
                    // ceebs doing cosine weighted reflection 
                    // FIXME: MAKE THIS COSINE WEIGHTED YOU LAZY BASTARD
                    
                    ray_origin = closest_intercept.pos;

                    // make a random ray (this is not uniformly disributed but i have to replace it with cosine weight later anyway)
                    ray = vec_from_spherical(rand()*cam.inv_max_rand*2*3.1415926535f, rand()*cam.inv_max_rand*2*3.1415926535f);
                    
                    // if its "inside" the triange, then flip it along the triangle normal
                    // if the scalar projection is negative its inside 
                    if (vec_dot(ray, closest_intercept.tri.normal) < 0) {
                        ray = vec_scale(ray, -1);
                    }
                    // add the thing we hit to the ray_intercepts array
                    ray_intercepts[rt] = closest_intercept;
                }
            }
        }

        Vec3 ray_color = {0,0,0};
        // backtrack through the pixel_intercepts array
        // impliment attenuation later
        if (count_bounces != 0) {
            for (unsigned int i=count_bounces-1; i>0; i--) {
                ray_color = vec_add(ray_color, (Vec3){ray_intercepts[i].tri.color.r, ray_intercepts[i].tri.color.g, ray_intercepts[i].tri.color.b});
            }
            ray_color = vec_scale(ray_color, 1.0f/count_bounces);
            pixel_colors[r] = ray_color;
        }
    }
}

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

void render(Camera cam, Mesh* meshs, unsigned int num_meshs, char* filename) {
    // alloc a frame buffer to write to
    Color* data = malloc(sizeof(Color) * cam.height_pixels * cam.width_pixels);
    if (!data) {
        // unrecoverable, ggs
        printf("frame buffer failed alloc");
        abort();
    }

    Frame_Buffer buffer = {data, cam.width_pixels, cam.height_pixels};

    // construct list of all triangles for efficient memory access
    Render_Tri_Buffer tri_buffer = get_tris(meshs, num_meshs);

    // starting position on the screen (then we sweep across)
    float plane_x = -cam.horizontal_half_scale;
    float plane_y = cam.vertical_half_scale;

    Vec3 ray;
    Vec3 ray_origin;

    Vec3 cur_intersec;
    float cur_dist;

    Ray_Tri_Intercept closest_intercept;
    closest_intercept.dist = 999999999.0f; // we need this to be inited
    Ray_Tri_Intercept* ray_intercepts = malloc(sizeof(Ray_Tri_Intercept) * cam.num_bounces); // fill this up then backtrack through it for the ray color
    if (!ray_intercepts) {
        // unrecoverable
        printf("ray_intercepts failed to alloc");
        abort();
    }
    int count_bounces;

    Vec3* pixel_colors = malloc(sizeof(Color) * cam.rays_per_pixel);
    if (!pixel_colors) {
        // diabolically unrecoverable
        printf("colors failed to alloc");
        abort();
    }

    start_loading_bar(cam);

    for (unsigned int y=0; y<cam.height_pixels; y++) {
        for (unsigned int x=0; x<cam.width_pixels; x++) {
            for (unsigned int r=0; r<cam.rays_per_pixel; r++) {
                float rand_x_off = rand() * cam.inv_max_rand * cam.px_width;
                float rand_y_off = rand() * cam.inv_max_rand * cam.px_height;
                // ray = forward*focal_len + (right*(horizontal_half_scale + rand_x_off) + up*(vertical_half_scale + rand_y_off))
                ray = vec_normalise(
                    vec_add(
                        vec_scale(cam.forward, cam.focal_length),
                        vec_add(
                            vec_scale(cam.right, plane_x + rand_x_off), 
                            vec_scale(cam.up, plane_y + rand_y_off)
                        )
                    )
                );
                ray_origin = cam.pos;
                
                count_bounces = 0;
                closest_intercept.dist = 999999999.0f;

                // we just need to fill up the ray_intercepts array here then we will backtrack through it later
                for (unsigned int rt=0; rt<cam.num_bounces; rt++) {
                    has_intersec = 0;
                    // check if the ray intersecs any triangles
                    for (unsigned int t=0; t<tri_buffer.num_tris; t++) {
                        // check if the ray intersects the triangle
                        if (!ray_triangle_intercept(ray, ray_origin, tri_buffer.tris[t].tri, &cur_intersec)) {
                            continue;
                        }

                        // there is at least one intersec
                        has_intersec = 1;

                        // get the distance from ray_origin to the point
                        cur_dist = dist_bet_points(cur_intersec, ray_origin);

                        // check if its the closest intersec so far
                        if (cur_dist < closest_intercept.dist) {
                            closest_intercept.dist = cur_dist;
                            closest_intercept.pos = cur_intersec;
                            closest_intercept.tri = tri_buffer.tris[t];
                        }
                    }
                    if (!has_intersec) {
                        pixel_colors[r] = (Vec3){0.0f, 0.0f, 0.0f}; // color is black
                        break; // there are no more bounces (break and go to next ray)
                    }
                    
                    //printf("test");
                    // we do have an intersection
                    count_bounces++;
                    if (closest_intercept.tri.emmisive) {
                        if (rt == 0) {
                            // we hit a light source on the first go, lucky us
                            // "return" the lights color immidiently
                            pixel_colors[r] = (Vec3){closest_intercept.tri.color.r, closest_intercept.tri.color.g, closest_intercept.tri.color.b};
                            break; // there are no more bounces (break and go to next ray)
                            // since has_intersec is zero, there will be no backtracking through our ray_intercepts list
                        } else {
                            break; // there are no more bounces (break and go to next ray)
                        }
                    } else {
                        // we hit a triangle
                        // what type of reflectiveness is it?
                        if (closest_intercept.tri.reflective) {
                            // its reflective so simply just reflect the ray
                            ray_origin = closest_intercept.pos;
                            // R = reflected ray, I = incidence ray, N = tri normal
                            // R = I - 2(ProjN(I))
                            Vec3 N = closest_intercept.tri.normal;
                            Vec3 I = ray;
                            ray = vec_sub(I, vec_scale(vec_proj(N, I), 2.0f));

                            // add the thing we hit to the ray_intercepts array
                            ray_intercepts[rt] = closest_intercept;
                        } else {
                            // its not reflective 
                            // ceebs doing cosine weighted reflection 
                            // FIXME: MAKE THIS COSINE WEIGHTED YOU LAZY BASTARD
                            
                            ray_origin = closest_intercept.pos;

                            // make a random ray (this is not uniformly disributed but i have to replace it with cosine weight later anyway)
                            ray = vec_from_spherical(rand()*cam.inv_max_rand*2*3.1415926535f, rand()*cam.inv_max_rand*2*3.1415926535f);
                            
                            // if its "inside" the triange, then flip it along the triangle normal
                            // if the scalar projection is negative its inside 
                            if (vec_dot(ray, closest_intercept.tri.normal) < 0) {
                                ray = vec_scale(ray, -1);
                            }
                            // add the thing we hit to the ray_intercepts array
                            ray_intercepts[rt] = closest_intercept;
                        }
                    }
                }

                Vec3 ray_color = {0,0,0};
                // backtrack through the pixel_intercepts array
                // impliment attenuation later
                if (count_bounces != 0) {
                    for (unsigned int i=count_bounces-1; i>0; i--) {
                        ray_color = vec_add(ray_color, (Vec3){ray_intercepts[i].tri.color.r, ray_intercepts[i].tri.color.g, ray_intercepts[i].tri.color.b});
                    }
                    ray_color = vec_scale(ray_color, 1.0f/count_bounces);
                    pixel_colors[r] = ray_color;
                }
            }
            
            // average all the rays to be the final pixel color
            Vec3 sum ={0.0f, 0.0f, 0.0f};
            for (unsigned int i=0; i<cam.rays_per_pixel; i++) {
                sum = vec_add(sum, pixel_colors[i]);
            }
            vec_scale(sum, 1.0f/cam.rays_per_pixel);
            
            buffer.data[y*cam.width_pixels + x] = (Color){(uint8_t)sum.x, (uint8_t)sum.y, (uint8_t)sum.z};

            plane_x += cam.px_width;

            update_loading_bar(cam.rays_per_pixel, 1);
        }
        plane_y -= cam.px_height;
        plane_x = -cam.horizontal_half_scale;
    }

    write_image(cam, buffer, filename);

    free(ray_intercepts);
    free(buffer.data);
}
