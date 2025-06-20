#pragma once
#include <vector>
#include <cstdlib>


#include "Misc/Scene.hpp"
#include "Misc/ScreenBuffer.hpp"
#include "Math/Ray.hpp"

struct Pathtracer {
    Scene scene;

    std::vector<TriAlbedoEmission> hitTriAlbedoEmissions; // to store tri hits and avoid mallocing billions of times
    std::vector<Tri> tris; // to store all tris

    std::vector<Vec3> rayColors; // to store tri hits and avoid mallocing billions of times

    Pathtracer(Scene scene) : scene(scene) {}

    void singleThreadRender(char* outFile) {
        // make a buffer to write to
        ScreenBuffer buffer = ScreenBuffer(scene.camera.screenParams);

        /* Get all the data together (usefull for when i rewrite this on cuda) */
        std::vector<Tri> tris = scene.getTris();
        (void) scene.materials;

        // loop for every pixel
        for (size_t pixelY; pixelY < scene.camera.screenParams.height; pixelY++) {
            for (size_t pixelX; pixelX < scene.camera.screenParams.width; pixelX++) {
                float planeX = -scene.camera.screenParams.horizontalHalfScale + pixelX * scene.camera.screenParams.pxWidth;
                float planeY = scene.camera.screenParams.verticalHalfScale - pixelY * scene.camera.screenParams.pxHeight;

                buffer.write(
                    getPixelColor(planeX, planeY),
                    pixelX, pixelY
                );
            }
        }
    }

    Vec3 getPixelColor(float planeX, float planeY) {
        // reset the rayColors vector
        rayColors.clear();

        for (size_t r = 0; r < scene.camera.screenParams.rayPerPixel; r++) {
            // reset the triHits vector
            hitTriAlbedoEmissions.clear();

            // get the ray but slightly nudged
            Ray activeRay = Ray(planeX, planeY, scene);

            for (size_t i = 0; i < scene.camera.screenParams.maxBounces; i++) {
                // check if the ray hits any triangles
                std::optional<TriHit> triHit = activeRay.getTriIntersection(tris);

                if (!triHit.has_value()) {
                    // we didnt hit anything which means we are done, now backtrack through trialbedoemission
                    break;
                }

                // we have a hit!
                // get the tris material
                Material& triMaterial = scene.getMaterial(triHit.value().tri.materialID);

                // reflect the ray
                TriAlbedoEmission triAlbedoemission = activeRay.bsdfReflect(triMaterial, triHit.value());

                // add the albedo and emission to the list for later backtracking
                hitTriAlbedoEmissions.push_back(triAlbedoemission);

            }
        }
    }
};