#pragma once

#include "Pathtracer.cuh"

void benchmarkImage1() {
    Vec3 
    tlf, blf,
    tlb, blb,
    trf, brf,
    trb, brb;
    tlf = Vec3(-1.0f, 1.0f, -1.0f); // top left front corner
    blf = Vec3(-1.0f, -1.0f, -1.0f); // bottom left front corner

    tlb = Vec3(1.0f, 1.0f, -1.0f); // top left back corner
    blb = Vec3(1.0f, -1.0f, -1.0f); // bottom left back corner

    trf = Vec3(-1.0f, 1.0f, 1.0f); // top right front corner
    brf = Vec3(-1.0f, -1.0f, 1.0f); // bottom right front corner

    trb = Vec3(1.0f, 1.0f, 1.0f); // top right back corner
    brb = Vec3(1.0f, -1.0f, 1.0f); // bottom right back corner

    const unsigned int width = 2048;//4096
    const unsigned int height = 2048;
    const float verticalFov = 90 * (3.1415f/180);
    const float horizontalFov = 90 * (3.1415f/180);
    const float focalLength = 1.0f;
    const unsigned int rayPerPixel = 128 * 64;
    const unsigned int maxBounces = 4;

    ScreenParams screenParams = ScreenParams(width, height, verticalFov, horizontalFov, focalLength, rayPerPixel, maxBounces);

    Vec3 camOrigin = Vec3(-2.,0,.75);
    Vec3 camForward = Vec3(1,0,-.5);

    Camera camera = Camera(
        camOrigin,
        camForward,
        screenParams,
        Vec3::BLACK
    );

    HostResourceManager hostResourceManager = HostResourceManager();
    
    HostMaterial leftWallMaterial = HostMaterial(
        0.0f, 1.0f, 0.7f, 0.0f, HostMap(Vec3(1.0f, 1.0f, 1.0f)), HostMap(Vec3())
    );
    MaterialID leftWallMaterialID = hostResourceManager.hostMaterialManager.registerMaterial(leftWallMaterial);

    HostMaterial backWallMaterial = HostMaterial(
        0.0f, 1.0f, 1.0f, 0.2f, HostMap(Vec3(1.0f, 1.0f, 1.0f)), HostMap(Vec3(0.0f, 0.0f, 0.0f))
    );
    MaterialID backWallMaterialID = hostResourceManager.hostMaterialManager.registerMaterial(backWallMaterial);

    HostMaterial rightWallMaterial = HostMaterial(
        0.0f, 1.0f, 1.0f, 0.0f, HostMap(Vec3(1.0f, 0.0f, 0.0f)), HostMap(Vec3(0.0f, 0.0f, 0.0f))
    );
    MaterialID rightWallMaterialID = hostResourceManager.hostMaterialManager.registerMaterial(rightWallMaterial);

    HostMaterial roofMaterial = HostMaterial(
        0.0f, 1.0f, 1.0f, 0.0f, HostMap(Vec3(1.0f, 0.0f, 1.0f)), HostMap(Vec3(0.0f, 0.0f, 0.0f))
    );
    MaterialID roofMaterialID = hostResourceManager.hostMaterialManager.registerMaterial(roofMaterial);

    HostMaterial floorMaterial = HostMaterial(
        0.0f, 1.0f, 1.0f, 0.0f, HostMap(Vec3(1.0f, 1.0f, 0.0f)), HostMap(Vec3(0.0f, 0.0f, 0.0f))
    );
    MaterialID floorMaterialID = hostResourceManager.hostMaterialManager.registerMaterial(floorMaterial);

    HostMaterial randMaterial = HostMaterial(
        0.0f, 1.0f, 1.0f, 0.0f, HostMap(Vec3(1.0f, 1.0f, 1.0f)), HostMap(Vec3(0.0f, 0.0f, 0.0f))
    );
    MaterialID randMaterialID = hostResourceManager.hostMaterialManager.registerMaterial(randMaterial);

    HostMesh leftWallMesh = HostMesh::plane(tlb, tlf, blf, blb, leftWallMaterialID);
    hostResourceManager.hostMeshManager.registerMesh(leftWallMesh);

    HostMesh backWallMesh = HostMesh::plane(trb, tlb, blb, brb, backWallMaterialID);
    hostResourceManager.hostMeshManager.registerMesh(backWallMesh);

    HostMesh rightWallMesh = HostMesh::plane(trb, brb, brf, trf, rightWallMaterialID);
    hostResourceManager.hostMeshManager.registerMesh(rightWallMesh);

    HostMesh roofMesh = HostMesh::plane(trf, tlf, tlb, trb, roofMaterialID);
    hostResourceManager.hostMeshManager.registerMesh(roofMesh);

    HostMesh floorMesh = HostMesh::plane(brb, blb, blf, brf, floorMaterialID);
    hostResourceManager.hostMeshManager.registerMesh(floorMesh);

    unsigned int seed = 0;

    HostMesh randMesh = HostMesh::randomMesh(-.5, .5, 20, seed, randMaterialID);
    //hostResourceManager.hostMeshManager.registerMesh(randMesh);
    
    Pathtracer pathtracer = Pathtracer(hostResourceManager, camera);

    pathtracer.render((char*)"test.jpg");
}

// HostMesh utahTeapot = HostMesh::utahTeapot(Vec3(0, -0.5f, 0.2f), 0.5f, randMaterialID);
// hostResourceManager.hostMeshManager.registerMesh(utahTeapot);

// HostMesh wavySphere = HostMesh::wavySphere(0.5f, Vec3(0, 0, .2), randMaterialID, 1.0f, 128, 64);
// hostResourceManager.hostMeshManager.registerMesh(wavySphere);

// HostMesh icosahedron1 = HostMesh::icosahedron(0.5f, Vec3(0, 0, -.5), randMaterialID);
// hostResourceManager.hostMeshManager.registerMesh(icosahedron1);
// HostMesh icosahedron2 = HostMesh::icosahedron(0.5f, Vec3(0, 0, .5), randMaterialID);
// hostResourceManager.hostMeshManager.registerMesh(icosahedron2);