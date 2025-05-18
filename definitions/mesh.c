#include <stdlib.h>
#include <stdio.h>
#include "../math/Tri.h"
#include "mesh.h"
#include "color.h"

// takes ownership of tris
Mesh init_mesh(unsigned int num_tris, Tri* tris, Color color) {
    Mesh mesh = {num_tris, tris, NULL, color};
    
    recompute_norms(&mesh);

    return mesh;
}

float randbetween(float min, float max) {
    return min + (rand()/(float)RAND_MAX) * (max - min);
}

Mesh init_random_mesh(unsigned int num_tris, Color color, float min, float max) {
    Mesh mesh = {num_tris, NULL, NULL, color};

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
    recompute_norms(&mesh);

    return mesh;
}

void free_mesh(Mesh mesh) {
    free(mesh.tris);
    free(mesh.normals);
}

void recompute_norms(Mesh* mesh) {
    if (mesh->normals) {
        free(mesh->normals); // we cant be sure its the right size (tri data updated etc)
    }
    mesh->normals = malloc(sizeof(Vec3) * mesh->num_tris);

    if (!mesh->normals) {
        // oh no, probably memory leak
        fprintf(stderr, "FATAL: Cannot allocate mesh normals");
        abort();
    }

    for (unsigned int i=0; i<mesh->num_tris; i++) {
        mesh->normals[i] = tri_normal(mesh->tris[i]);
    }
}
