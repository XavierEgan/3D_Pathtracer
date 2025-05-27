#ifndef RENDER_H
#define RENDER_H

#include "math/Vec3.h"
#include "math/Tri.h"
#include "definitions/camera.h"
#include "definitions/color.h"
#include "definitions/framebuffer.h"
#include "definitions/mesh.h"

void render(Camera cam, Mesh* meshs, unsigned int num_meshs, char* filename);

#endif