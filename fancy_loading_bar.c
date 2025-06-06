#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <time.h>

#include "fancy_loading_bar.h"
#include "definitions/camera.h"
#include "definitions/mesh.h"

void render_loading_bar();

const int loading_bar_width = 20;

uint64_t est_pixels_total;
uint64_t pixels_so_far;
uint64_t est_rays_total;
uint64_t rays_so_far;

clock_t start;

void start_loading_bar(Camera cam) {
    start = clock();
    
    est_pixels_total = cam.height_pixels * cam.width_pixels;
    est_rays_total = est_pixels_total * cam.rays_per_pixel;

    printf("\x1b[2J");
    fflush(stdout);

    render_loading_bar();
}

int render_counter = 0;
int render_counter_max = 20;

void update_loading_bar(uint32_t delta_rays, uint32_t delta_pixels) {
    rays_so_far += delta_rays;
    pixels_so_far += delta_pixels;

    if (render_counter >= render_counter_max) {
        render_loading_bar();
        render_counter = 0;
    } else {
        render_counter++;
    }
}

void render_loading_bar() {
    float percent = (((float)pixels_so_far) / est_pixels_total);
    
    int num_equal_signs = (int)(percent * loading_bar_width);

    char bar[256];

    for (unsigned int i=0; i<loading_bar_width; i++) {
        if (i < num_equal_signs) {
            bar[i] = '=';
        } else {
            bar[i] = '-';
        }
    }
    bar[loading_bar_width] = '\0';

    float elapsed_time = (float)(clock() - start) / CLOCKS_PER_SEC;
    long long est_time_remaining = (elapsed_time/percent - elapsed_time); // in s

    int est_time_remaining_h = est_time_remaining / 3600;
    est_time_remaining -= est_time_remaining_h*3600;

    int est_time_remaining_m = est_time_remaining / 60;
    est_time_remaining -= est_time_remaining_m*60;

    int est_time_remaining_s = est_time_remaining;

    printf("\033[HRendering [%s] %0.1f%%\n%lld/%lld pixels rendered\n%lld/%lld rays traced\ntime elapsed: %0.3fs\nest time remaining: %dh%dm%ds                                      \n                                      ", 
        bar,
        percent*100,
        pixels_so_far, est_pixels_total,
        rays_so_far, est_rays_total,
        elapsed_time,
        est_time_remaining_h, est_time_remaining_m, est_time_remaining_s
    );
    //fflush(stdout);
}