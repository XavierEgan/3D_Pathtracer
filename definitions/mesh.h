#ifndef MESH_H
#define MESH_H

#include <stdlib.h>
#include <stdio.h>
#include "../math/Tri.h"
#include "color.h"

typedef struct {
    unsigned int num_tris;
    Tri* tris;
    Color color;
    int reflective;
    int emmisive;
} Mesh;

// takes ownership of tris
Mesh init_mesh(unsigned int num_tris, Tri* tris, Color color, int reflective, int emmisive);

Mesh init_random_mesh(unsigned int num_tris, Color color, float min, float max, int reflective, int emmisive);

void free_mesh(Mesh mesh);

void recompute_norms(Mesh* mesh);

#endif