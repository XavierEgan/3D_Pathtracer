#pragma once
#include "Math/Tri.cuh"

struct PixelOptimisationReport {
    bool isBlankPixel;
    bool isCoherentPixel;
    const Tri& coherentTri;

    __device__ PixelOptimisationReport(
        bool isBlankPixel, 
        bool isCoherentPixel, 
        const Tri& coherentTri
    ) : 
        isBlankPixel(isBlankPixel),
        isCoherentPixel(isCoherentPixel),
        coherentTri(coherentTri)
    {}
};