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

    const unsigned int width = 2048/4;//4096
    const unsigned int height = 2048/4;
    const float verticalFov = 90 * (3.1415f/180);
    const float horizontalFov = 90 * (3.1415f/180);
    const float focalLength = 1.0f;
    const unsigned int rayPerPixel = 128 * 32;
    const unsigned int maxBounces = 32;

    ScreenParams screenParams = ScreenParams(width, height, verticalFov, horizontalFov, focalLength, rayPerPixel, maxBounces);

    Vec3 camOrigin = Vec3(-2.,0,.75);
    Vec3 camForward = Vec3(1,0,-.5);

    Camera camera = Camera(
        camOrigin,
        camForward,
        screenParams
    );

    HostResourceManager hostResourceManager = HostResourceManager();
    
    HostMaterial leftWallMaterial = HostMaterial(
        0.0f, 1.0f, 0.6f, false, HostMap(Vec3(1.0f, 1.0f, 1.0f)), HostMap(Vec3(0.0f, 0.0f, 0.0f))
    );
    MaterialID leftWallMaterialID = hostResourceManager.hostMaterialManager.registerMaterial(leftWallMaterial);
    HostMesh leftWallMesh = HostMesh::plane(tlb, tlf, blf, blb, leftWallMaterialID);
    hostResourceManager.hostMeshManager.registerMesh(leftWallMesh);


    HostMaterial backWallMaterial = HostMaterial(
        0.0f, 1.0f, 1.0f, false, HostMap(Vec3(1.0f, 1.0f, 1.0f)), HostMap(Vec3(0.0f, 0.0f, 0.0f))
    );
    MaterialID backWallMaterialID = hostResourceManager.hostMaterialManager.registerMaterial(backWallMaterial);
    HostMesh backWallMesh = HostMesh::plane(blb, brb, trb, tlb, backWallMaterialID);
    hostResourceManager.hostMeshManager.registerMesh(backWallMesh);

    float backWallLightSize = 0.4f;
    float backWallDistFromWall = 0.1f;
    HostMaterial backWallLightMaterial = HostMaterial(
        0.0f, 1.0f, 1.0f, true, HostMap(Vec3(1.0f, 1.0f, 1.0f)), HostMap(Vec3(0.0f, 0.0f, 0.0f))
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
        0.0f, 1.0f, 1.0f, false, HostMap(Vec3(1.0f, 0.0f, 0.0f)), HostMap(Vec3(0.0f, 0.0f, 0.0f))
    );
    MaterialID rightWallMaterialID = hostResourceManager.hostMaterialManager.registerMaterial(rightWallMaterial);
    HostMesh rightWallMesh = HostMesh::plane(trb, brb, brf, trf, rightWallMaterialID);
    hostResourceManager.hostMeshManager.registerMesh(rightWallMesh);


    HostMaterial roofMaterial = HostMaterial(
        0.0f, 1.0f, 1.0f, false, HostMap(Vec3(1.0f, 0.0f, 1.0f)), HostMap(Vec3(0.0f, 0.0f, 0.0f))
    );
    MaterialID roofMaterialID = hostResourceManager.hostMaterialManager.registerMaterial(roofMaterial);
    HostMesh roofMesh = HostMesh::plane(trf, tlf, tlb, trb, roofMaterialID);
    hostResourceManager.hostMeshManager.registerMesh(roofMesh);


    HostMaterial floorMaterial = HostMaterial(
        0.0f, 1.0f, 1.0f, false, HostMap(Vec3(1.0f, 1.0f, 0.0f)), HostMap(Vec3(0.0f, 0.0f, 0.0f))
    );
    MaterialID floorMaterialID = hostResourceManager.hostMaterialManager.registerMaterial(floorMaterial);
    HostMesh floorMesh = HostMesh::plane(brb, blb, blf, brf, floorMaterialID);
    hostResourceManager.hostMeshManager.registerMesh(floorMesh);


    // HostMaterial causticSphereMaterial = HostMaterial(
    //     1.0f, 1.3f, 0.0f, false, HostMap(Vec3(1.0f, 1.0f, 1.0f)), HostMap(Vec3(0.0f, 0.0f, 0.0f))
    // );
    // MaterialID causticSphereID = hostResourceManager.hostMaterialManager.registerMaterial(causticSphereMaterial);
    // HostMesh causticSphereMesh = HostMesh::causticSphere(0.5f, Vec3(0, 0, .2), causticSphereID, 1.0f, 256/4, 128/4);
    // hostResourceManager.hostMeshManager.registerMesh(causticSphereMesh);


    // printf("leftWallMaterialID: %d\n", leftWallMaterialID.materialID);
    HostMaterial utahTeapotMaterial = HostMaterial(
        1.0f, 1.33f, 1.0f, false, HostMap(Vec3(1.0f, 1.0f, 1.0f)), HostMap(Vec3(0.0f, 0.0f, 0.0f))
    );
    MaterialID utahTeapotMaterialID = hostResourceManager.hostMaterialManager.registerMaterial(utahTeapotMaterial);
    HostMesh utahTeapot = HostMesh::utahTeapot(Vec3(0, -0.5f, 0.2f), 0.5f, utahTeapotMaterialID);
    hostResourceManager.hostMeshManager.registerMesh(utahTeapot);

    

    // HostMesh icosahedron1 = HostMesh::icosahedron(0.5f, Vec3(0, 0, -.5), randMaterialID);
    // hostResourceManager.hostMeshManager.registerMesh(icosahedron1);
    // HostMesh icosahedron2 = HostMesh::icosahedron(0.5f, Vec3(0, 0, .5), randMaterialID);
    // hostResourceManager.hostMeshManager.registerMesh(icosahedron2);

    unsigned int seed = 0;
    
    Pathtracer pathtracer = Pathtracer(hostResourceManager, camera);

    pathtracer.render((char*)"dontdelte.jpg");
}