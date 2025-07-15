#pragma once

#include <cmath>
#include <type_traits>

#include "../Math/Vec3.cuh"

struct ScreenParams {
    unsigned int width;
    unsigned int height;
    float verticalFov;
    float horizontalFov;
    float focalLength;

    unsigned int rayPerPixel;
    unsigned int maxBounces;

    float verticalHalfScale;
    float horizontalHalfScale;
    float pxHeight;
    float pxWidth;

    ScreenParams(unsigned int width, unsigned int height, float verticalFov, float horizontalFov, float focalLength, unsigned int rayPerPixel, unsigned int maxBounces) : width(width), height(height), verticalFov(verticalFov), horizontalFov(horizontalFov), focalLength(focalLength), rayPerPixel(rayPerPixel), maxBounces(maxBounces) {
        verticalHalfScale = std::abs(std::tan(verticalFov * 0.5f) * focalLength);
        horizontalHalfScale = std::abs(std::tan(horizontalFov * 0.5f) * focalLength);

        pxHeight = (verticalHalfScale * 2.0f) / height;

        pxWidth = (horizontalHalfScale * 2.0f) / width;

        printf("verticalHalfScale: %f\n", verticalHalfScale);
        printf("horizontalHalfScale: %f\n", horizontalHalfScale);
    }
};

struct Camera {
    Vec3 pos;
    Vec3 forward;
    Vec3 right;
    Vec3 up;

    ScreenParams screenParams;

    Camera(Vec3 pos, Vec3 forward, ScreenParams screenParams) : pos(pos), forward(forward.normalized()), screenParams(screenParams) {
        // right is the same as the cross product between the forward vector and the forward vector shifted up a lil 
        right = (forward.normalized().cross(forward + Vec3(0,.1,0))).normalized();

        // up is the cross between right a forward in that order
        up = (right.cross(forward.normalized())).normalized();

        forward.print("Camera forward");
        right.print("Camera right");
        up.print("Camera up");
        pos.print("Camera Pos");
        
    }
};