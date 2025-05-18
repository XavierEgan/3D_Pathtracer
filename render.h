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
} Render_Tri;

typedef struct {
    Render_Tri* tris;
    unsigned long long num_tris; // may be smaller than tris
} Render_Tri_Buffer;

int render_tri(Tri tri);

void render(Camera cam, Mesh* meshs, int num_meshs, char* filename);

#endif