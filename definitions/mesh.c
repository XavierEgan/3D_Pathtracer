#include <stdlib.h>
#include <stdio.h>
#include "../math/Tri.h"
#include "mesh.h"
#include "color.h"

// takes ownership of tris
Mesh init_mesh(unsigned int num_tris, Tri* tris, Color color, int reflective, int emmisive) {
    Vec3 albedo = {color.r/255.0f, color.g/255.0f, color.b/255.0f};
    Mesh mesh = {num_tris, tris, color, albedo, reflective, emmisive};

    return mesh;
}

float randbetween(float min, float max) {
    return min + (rand()/(float)RAND_MAX) * (max - min);
}

Mesh init_random_mesh(unsigned int num_tris, Color color, float min, float max, int reflective, int emmisive) {
    Vec3 albedo = {color.r/255.0f, color.g/255.0f, color.b/255.0f};
    Mesh mesh = {num_tris, NULL, color, albedo, reflective, emmisive};

    Tri* tris = malloc(sizeof(Tri) * num_tris);
    if (!tris) {
        // unrecoverable
        fprintf(stderr, "random mesh alloc failed");
        abort();
    }

    for (unsigned int t=0; t<num_tris; t++) {
        Vec3 a = {randbetween(min, max), randbetween(min, max), randbetween(min, max)};
        Vec3 b = {randbetween(min, max), randbetween(min, max), randbetween(min, max)};
        Vec3 c = {randbetween(min, max), randbetween(min, max), randbetween(min, max)};

        Tri tri = {a, b, c};

        tris[t] = tri;
    }

    mesh.tris = tris;

    return mesh;
}

void free_mesh(Mesh mesh) {
    free(mesh.tris);
}
