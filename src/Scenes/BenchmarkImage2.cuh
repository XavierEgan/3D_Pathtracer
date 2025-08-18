#pragma once

#include "../Pathtracer.cuh"

void benchmarkImage2() {
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

    const unsigned int width = 2048/8;//4096
    const unsigned int height = 2048/8;
    const float verticalFov = 60 * (3.1415f/180);
    const float horizontalFov = 60 * (3.1415f/180);
    const float focalLength = 1.0f;
    const unsigned int rayPerPixel = 128 * 1;
    const unsigned int maxBounces = 16;
    Vec3 camOrigin = Vec3(-.5,-.2,1);
    Vec3 camForward = Vec3(.5,-.1,-1);

    const float backWallLightSize = 0.4f;
    const float backWallDistFromWall = 0.01f;

    const float tableSize = 0.4f;
    const float tableDistFromFloor = 0.5f;
    
    const Vec3 utahTeapotPos = Vec3(0, -0.5f, 0.2f);
    const float utahTeapotScale = 0.5f;
    const float utahTeapotRotationDeg = 90.0f;

    ScreenParams screenParams = ScreenParams(width, height, verticalFov, horizontalFov, focalLength, rayPerPixel, maxBounces);

    Camera camera = Camera(
        camOrigin,
        camForward,
        screenParams,
        Vec3::BLACK
    );

    HostResourceManager hostResourceManager = HostResourceManager();
    
    HostMaterial leftWallMaterial = HostMaterial(
        0.0f, 1.0f, 0.2f, false, HostMap(Vec3::WHITE), HostMap(Vec3::BLACK)
    );
    MaterialID leftWallMaterialID = hostResourceManager.hostMaterialManager.registerMaterial(leftWallMaterial);
    HostMesh leftWallMesh = HostMesh::plane(tlb, tlf, blf, blb, leftWallMaterialID);
    hostResourceManager.hostMeshManager.registerMesh(leftWallMesh);

    HostMaterial backWallMaterial = HostMaterial(
        0.0f, 1.0f, 1.0f, false, HostMap(Vec3::WHITE), HostMap(Vec3::BLACK)
    );
    MaterialID backWallMaterialID = hostResourceManager.hostMaterialManager.registerMaterial(backWallMaterial);
    HostMesh backWallMesh = HostMesh::plane(blb, brb, trb, tlb, backWallMaterialID);
    hostResourceManager.hostMeshManager.registerMesh(backWallMesh);

    HostMaterial backWallLightMaterial = HostMaterial(
        0.0f, 1.0f, 1.0f, true, HostMap(Vec3::WHITE), HostMap(Vec3::BLACK)
    );
    MaterialID backWallLightMaterialID = hostResourceManager.hostMaterialManager.registerMaterial(backWallLightMaterial);
    HostMesh backWallLightMesh = HostMesh::plane(
        Vec3(1.0f - backWallDistFromWall, backWallLightSize, backWallLightSize), 
        Vec3(1.0f - backWallDistFromWall, backWallLightSize, -backWallLightSize), 
        Vec3(1.0f - backWallDistFromWall, -backWallLightSize, -backWallLightSize),
        Vec3(1.0f - backWallDistFromWall, -backWallLightSize, backWallLightSize),
        backWallLightMaterialID);
    hostResourceManager.hostMeshManager.registerMesh(backWallLightMesh);

    HostMaterial rightWallMaterial = HostMaterial(
        0.0f, 1.0f, 1.0f, false, HostMap(Vec3::RED), HostMap(Vec3::BLACK)
    );
    MaterialID rightWallMaterialID = hostResourceManager.hostMaterialManager.registerMaterial(rightWallMaterial);
    HostMesh rightWallMesh = HostMesh::plane(trb, brb, brf, trf, rightWallMaterialID);
    hostResourceManager.hostMeshManager.registerMesh(rightWallMesh);

    HostMaterial roofMaterial = HostMaterial(
        0.0f, 1.0f, 1.0f, false, HostMap(Vec3::MAGENTA), HostMap(Vec3::BLACK)
    );
    MaterialID roofMaterialID = hostResourceManager.hostMaterialManager.registerMaterial(roofMaterial);
    HostMesh roofMesh = HostMesh::plane(trf, tlf, tlb, trb, roofMaterialID);
    hostResourceManager.hostMeshManager.registerMesh(roofMesh);


    HostMaterial floorMaterial = HostMaterial(
        0.0f, 1.0f, 1.0f, false, HostMap(Vec3::YELLOW), HostMap(Vec3::BLACK)
    );
    MaterialID floorMaterialID = hostResourceManager.hostMaterialManager.registerMaterial(floorMaterial);
    HostMesh floorMesh = HostMesh::plane(brb, blb, blf, brf, floorMaterialID);
    hostResourceManager.hostMeshManager.registerMesh(floorMesh);

    HostMaterial utahTeapotMaterial = HostMaterial(
        0.5f, 1.33f, 0.0f, false, HostMap(Vec3::WHITE), HostMap(Vec3::BLACK)
    );
    MaterialID utahTeapotMaterialID = hostResourceManager.hostMaterialManager.registerMaterial(utahTeapotMaterial);
    HostMesh utahTeapotMesh = HostMesh::utahTeapot(utahTeapotPos, utahTeapotScale, utahTeapotMaterialID, utahTeapotRotationDeg);
    hostResourceManager.hostMeshManager.registerMesh(utahTeapotMesh);

    HostMaterial tableMaterial = HostMaterial(
        0.0f, 1.0f, 0.6f, false, HostMap("../Maps/Textures/bark_willow_02_diff_4k.png"), HostMap("../Maps/Normal/bark_willow_02_nor_gl_4k.png")
    );
    MaterialID tableMaterialID = hostResourceManager.hostMaterialManager.registerMaterial(tableMaterial);
    HostMesh tableMesh = HostMesh::plane(
        Vec3(tableSize, -1.0f + tableDistFromFloor, tableSize), 
        Vec3(tableSize, -1.0f + tableDistFromFloor, -tableSize), 
        Vec3(-tableSize, -1.0f + tableDistFromFloor, -tableSize),
        Vec3(-tableSize, -1.0f + tableDistFromFloor, tableSize),
        tableMaterialID
    );
    hostResourceManager.hostMeshManager.registerMesh(tableMesh);

    unsigned int seed = 0;
    
    Pathtracer pathtracer = Pathtracer(hostResourceManager, camera);

    pathtracer.render((char*)"yuoghb5wert.jpg");
}