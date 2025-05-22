#ifndef LOADING_BAR_H
#define LOADING_BAR_H

#include "fancy_loading_bar.h"
#include "definitions/camera.h"
#include "definitions/mesh.h"

void start_loading_bar(Camera cam);

void update_loading_bar(uint32_t delta_rays, uint32_t delta_pixels);

#endif