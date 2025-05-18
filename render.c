#include <stdio.h>
#include <stdlib.h>

#include "render.h"

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

void render(Camera cam, Mesh* meshs, int num_meshs, char* filename) {
    // construct list of all triangles for efficient memory access
    Render_Tri_Buffer tri_buffer = get_tris(meshs, num_meshs);

    
}
