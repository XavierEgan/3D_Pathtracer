#ifndef MESH_H
#define MESH_H

#include <stdlib.h>
#include <stdio.h>
#include "../math/Tri.h"
#include "color.h"

typedef struct {
    unsigned int num_tris;
    Tri* tris;
    Vec3* normals;
    Color color;
} Mesh;

// takes ownership of tris
Mesh init_mesh(unsigned int num_tris, Tri* tris, Color color);

Mesh init_random_mesh(unsigned int num_tris, Color color, float min, float max);

void free_mesh(Mesh mesh);

void recompute_norms(Mesh* mesh);

#endif