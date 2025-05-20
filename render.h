#ifndef RENDER_H
#define RENDER_H

#include "math/Vec3.h"
#include "math/Tri.h"
#include "definitions/camera.h"
#include "definitions/color.h"
#include "definitions/framebuffer.h"
#include "definitions/mesh.h"

typedef struct {
    Tri tri;
    Color color;
    int reflective;
    int emmisive;
} Render_Tri;

typedef struct {
    Render_Tri* tris;
    unsigned long long num_tris; // may be smaller than tris
} Render_Tri_Buffer;

void render(Camera cam, Mesh* meshs, unsigned int num_meshs, char* filename);

#endif