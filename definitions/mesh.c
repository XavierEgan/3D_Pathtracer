#include "math/Tri.h"

typedef struct {
    unsigned int num_tris;
    Tri* tris;
    Vec3* normals;
} Mesh;

// free_mesh takes ownership of tris
Mesh init_mesh(int num_tris, Tri* tris) {
    Vec3* norms = malloc(sizeof(Vec3) * num_tris);
    for (unsigned int i=0; i<num_tris; i++) {
        norms[i] = tri_normal(tris[i]);
    }
    Mesh mesh = {num_tris, tris, norms};
    return mesh;
}

void free_mesh(Mesh mesh) {
    free(mesh.tris);
    free(mesh.normals);
}

void recompute_norms(Mesh* mesh) {
    for (unsigned int i=0; i<mesh->num_tris; i++) {
        mesh->normals[i] = tri_normal(mesh->tris[i]);
    }
}