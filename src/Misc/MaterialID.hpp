#pragma once
/*
identifier which uniquely indentifies each material
Identifies the same material between HostMaterialManager and DeviceMaterialManager
*/
struct MaterialID {
    unsigned int materialID;
    __host__ __device__ MaterialID(unsigned int materialID) : materialID(materialID) {}
};