#pragma once
#include <vector>
#include <cstdlib>


#include "Misc/Scene.hpp"
#include "Misc/ScreenBuffer.hpp"
#include "Math/Ray.hpp"

struct Pathtracer {
    Scene scene;

    std::vector<Tri> tris; // to store all tris

    Pathtracer(Scene scene) : scene(scene) {}

    void singleThreadRender(char* outFile) {
        // make a buffer to write to
        ScreenBuffer buffer = ScreenBuffer(scene.camera.screenParams);

        /* Get all the data together (usefull for when i rewrite this on cuda) */
        std::vector<Tri> tris = scene.getTris();
        (void) scene.materials;

        // loop for every pixel
        #pragma omp parallel for num_threads(NUM_THREADS)
        for (size_t pixelY; pixelY < scene.camera.screenParams.height; pixelY++) {
            // so threads dont fight over a single seed
            unsigned int localSeed = 0;
            for (size_t pixelX; pixelX < scene.camera.screenParams.width; pixelX++) {
                float planeX = -scene.camera.screenParams.horizontalHalfScale + pixelX * scene.camera.screenParams.pxWidth;
                float planeY = scene.camera.screenParams.verticalHalfScale - pixelY * scene.camera.screenParams.pxHeight;

                buffer.write(
                    getPixelColor(planeX, planeY, localSeed),
                    pixelX, pixelY
                );
            }
        }
    }

    Vec3 getPixelColor(float planeX, float planeY, unsigned int& localSeed) {
        Vec3 runningPixelColor = Vec3(0.0f, 0.0f, 0.0f);

        for (size_t r = 0; r < scene.camera.screenParams.rayPerPixel; r++) {
            Vec3 runningAlbedo = Vec3(1.0f, 1.0f, 1.0f);
            Vec3 runningEmission = Vec3(0.0f, 0.0f, 0.0f);

            // get the ray from the camera but slightly nudged
            Ray activeRay = Ray(planeX, planeY, scene);

            for (size_t i = 0; i < scene.camera.screenParams.maxBounces; i++) {
                // check if the ray hits any triangles
                std::optional<TriHit> triHit = activeRay.getTriIntersection(tris);

                if (!triHit.has_value()) {
                    // we didnt hit anything which means we are done
                    break;
                }

                // we have a hit!
                // get the tris material
                Material& triMaterial = scene.getMaterial(triHit.value().tri.materialID);

                // reflect the ray and update runningAlbedo and runningEmission
                activeRay.bsdfReflect(triMaterial, triHit.value(), localSeed, runningAlbedo, runningEmission);
            }

            Vec3 finalColor = runningAlbedo + runningEmission;
            runningPixelColor += finalColor;
        }

        return runningPixelColor / scene.camera.screenParams.maxBounces;
    }
};