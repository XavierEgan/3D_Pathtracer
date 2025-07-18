# 3D Pathtracer
## Overview
This project is a 3D pathtracer implemented in C++ with hardware acceleration using CUDA.

Originally implemented in single-threaded pure C, this new hardware-accelerated version achieves **~3664.44x** speed improvement (more details in Performance Evolution section below).

![alt text](Readme_Images/img1.jpg)
**Note**: Gamma correction disabled for artistic preference
- **Render Time**: 6.1 seconds
- **Resolution**: 2048×2048 (4.2M pixels)
- **Samples**: 8,192 rays per pixel
- **Scene Complexity**: 10 triangles
- **Ray Intersections**: ~2.7 trillion operations
- **Hardware**: NVIDIA RTX 4090 (16,384 CUDA cores)
- **Throughput**: ~205 billion rays/second

## Quick Start
Step 1:\
Clone the repo onto your device
```bash
git clone https://github.com/yourusername/cuda-pathtracer.git
cd cuda-pathtracer
```
Step 2:\
Setup the build directory
```bash
mkdir build
cd build
cmake ..
```

Step 3:\
Build with either Debug or Release
```bash
cmake --build . --config Release
```
or
```bash
cmake --build . --config Debug
```

Step 4:\
Run the project (depends if you chose Debug or Release before)
```bash
Debug\d.exe
```
or
```bash
Release\d.exe
```

## Performance Evolution
- **V1**: Single Threaded CPU (~5 hours)
- **V2**: CUDA parallel processing (~6.1 seconds)
- **V3**: OptiX and OpenGL Mathematics (GLM) (Unknown, future project)

**NOTE:** V1 did have multithreaded through #pragma omp parallel for, however it was harder to benchmark, so single threaded numbers are being used
### Improvement Over V1

In V1 of this project, the following image took `18322.2s` to render.
![alt text](Readme_Images/img2.png)
- **Resolution**: 2048×2048
- **Samples**: 2,048 rays per pixel  
- **Scene Complexity**: 30 triangles
- **Hardware**: Intel Core i9-12900k

Comparing to a render of V2, which took `5.0s` to render
![alt text](Readme_Images/img3.jpg)
- **Resolution**: 2048×2048 (4.2M pixels)
- **Samples**: 2,048 rays per pixel
- **Scene Complexity**: 30 triangles
- **Hardware**: NVIDIA RTX 4090 (16,384 CUDA cores)

**NOTE:** The images are not identical, however they the main differences are simple texture and color. The geometry is identical.

Performance Speedup: `18322.2 / 5.0 =` **3664.44x Speedup**

That means every second spent rendering with V2 is equivelent to an hour of rending with V1

#### Why not 16,384x speedup?
- **Texture sampling overhead** - V2 includes texture mapping
- **Launch overhead** - CUDA kernel launches have costs
- **Unoptimized code** - V2 is initial implementation without optimizations

## Optimisations
We will be Benchmarking with this image:
![alt text](Readme_Images/img4.png)
- **Resolution**: 2048×2048 (4.2M pixels)
- **Samples**: 8,192 rays per pixel
- **Scene Complexity**: 30 triangles
- **Hardware**: NVIDIA RTX 4090 (16,384 CUDA cores)

**Starting Render Time:** 45.6s

**NOTE:** Timings have quite a large variance of up to +-2s depending on many factors

### Early Pixel Termination (1.065x speedup)
We can cast 9 strategic rays (corners, edges, middle) And if all them dont hit anything, we consider the pixel to be black and early return.

In code that looks like this:
```C++
__device__ bool isBlankPixel(const DeviceTriBuffer& deviceTriBuffer, const Camera& camera, unsigned int planeX, unsigned int planeY, unsigned int& seed) {
    float subPixelOffsetX, subPixelOffsetY;
    int missedRayCount = 0;

    for (int x=0; x < 3; x++) {
        for (int y=0; y < 3; y++) {
            subPixelOffsetX = x * .5;
            subPixelOffsetY = y * .5;
            Ray ray = Ray(planeX, planeY, subPixelOffsetX, subPixelOffsetY, camera, seed);

            missedRayCount += !ray.getTriIntersection(deviceTriBuffer).hit;
        }
    }

    return missedRayCount == 9;
}
```

Final time after optimisation: `42.8s`\
Thats a `45.6/42.8 =` **1.065x speedup**

### Change `TriHit` To Use Pointers (1.48x speedup)
This optimisation was descovered by accident while working on the below optimisation (Ray Coherence)

`TriHit` previously Looked like this
```C++
struct TriHit {
    Vec3 intersecPoint;
    float dist;
    Vec3 baryCoords;
    Tri tri;
    bool hit;
};
```
However, we can store a reference to `Tri` instead of copying the entire tri each time.
```C++
struct TriHit {
    Vec3 intersecPoint;
    float dist;
    Vec3 baryCoords;
    const Tri* tri;
    bool hit;
};
```

The reason this has such a dramatic performance boost is that TriHit is in the hottest loop in the entire program. It's returned for each ray-tri intersection check, which is the heart of the 3d pathtracer

Final time after optimisation: `28.9s`\
Thats a `42.8/28.9 =` **1.48x speedup**

### Pixel Triangle Coherence Checking (1.06x speedup)
Similar to Early Pixel Termination, we can cast 9 strategic rays and check if they all hit the same triangle. If they all do then we can skip the first ray-tri intersection check, and only intersect with the one triangle.

We can modify the Early Pixel Termination code to also check for this by returning a POD struct `pixelOptimisationReport`

```C++
struct pixelOptimisationReport {
    bool isBlankPixel;
    bool isCoherentPixel;
    Tri& coherentTri;
}
```
```C++
__device__ PixelOptimisationReport pixelOptimisationsCheck(const DeviceTriBuffer& deviceTriBuffer, const Camera& camera, unsigned int planeX, unsigned int planeY, unsigned int& seed) {
    float subPixelOffsetX, subPixelOffsetY;
    int missedRayCount = 0;

    const Tri* referenceTriPointer = nullptr;

    TriHit triHit;

    bool coherentTri = true;

    PixelOptimisationReport dummyReport = PixelOptimisationReport(false, false, Tri());

    for (int x=0; x < 3; x++) {
        for (int y=0; y < 3; y++) {
            subPixelOffsetX = x * .5;
            subPixelOffsetY = y * .5;
            Ray ray = Ray(planeX, planeY, subPixelOffsetX, subPixelOffsetY, camera, seed);

            triHit = ray.getTriIntersection(deviceTriBuffer, dummyReport, false);

            if (x==0 && y==0) {
                if (triHit.hit) {
                    referenceTriPointer = triHit.tri;
                } else {
                    coherentTri = false;
                }
            }

            if (coherentTri) {
                coherentTri = referenceTriPointer == triHit.tri;
            }

            missedRayCount += !triHit.hit;
        }
    }

    return PixelOptimisationReport(
        missedRayCount == 9,
        coherentTri,
        *referenceTriPointer
    );
}
```
The code now compares each intersected triangle with a reference triangle (reference triangle is the first triangle hit). If all triangles are equal to the reference triangle, then we know the pixel is coherent and we can assume we hit this triangle first for all camera ray casts.

We can now also modify the ray-tri intersection code to skip if we are a coherent tri and we are not a bouncing ray

```C++
    __device__ TriHit getTriIntersection(const DeviceTriBuffer& deviceTriBuffer, const PixelOptimisationReport& pixelOptimisationReport, bool cameraRay) const {
        if (cameraRay && pixelOptimisationReport.isCoherentPixel) {
            return rayTriIntercept(pixelOptimisationReport.coherentTri);
        }

        // Skip entire triangle intersection checking loop
    }
```

Final time after optimisation: `27.3s`\
Thats a `28.9/27.3 =` **1.12x speedup**

### Remove Error Checking In Release Build (1.12x speedup)
Since we can be reasonably confident that out of bound memory accesses wont take place in build, we can use a preprocessor conditional to not run the checks.

This is especially usefull in the `getTri` method, as this is run for every ray-tri intercept check
```C++
__device__ const Tri& getTri(unsigned int i) const {
    #ifdef DEBUG
    if (i >= numTris) {
        printf("[DEVICE ERROR] in getTri, index out of range");
    }
    #endif
    return tris[i];
}
```

Final time after optimisation: `24.3s`\
Thats a `27.3/24.3 =` **1.12x speedup**

### Rewrite `bsdfReflect` (1.08x speedup)
`bsdfReflect` was in desperate need of a rewrite, the code was messy and ineficient

The main way this improved performance was removing branches and only performing computation needed for the type of reflection

Final time after optimisation: `22.5s`\
Thats a `24.3/22.5 =` **1.08x speedup**

### Split Tri into CoreTri and Tri (1.16x speedup)
This optimisation makes ray intersection checking faster since it stores a new struct, `CoreTri` (9 floats, 36 bytes) in a seperate array from `Tri`. When the loop inside `getTriIntersection` runs, we get more cache hits. This is because when we arrange `CoreTri`s in contiguous memory, its more likely for data we need to be arranged on the same cache line. This means we are more likely to bring in the verticies (what we actually need for ray-tri intercept) into the cache, rather than bringing in UV's or other almost useless information (only usefull when we get a hit).

Its important to note that at 36 bytes, `CoreTri` is not aligned with cache lines meaning we may bring in part of the next `CoreTri` into the cache, but not the whole thing

Final time after optimisation: `19.47s`\
Thats a `22.5/19.47 =` **1.16x speedup**

### Split `CoreTri` into 9 float arrays (Failed speedup)
The idea for this improvement was that more data can be fetched into the cache, since we read 9 floats and then pull 9 whole cache lines in.
This idea proably would have worked with float3's and making use of CUDA's __ldg() to load them into read only cache which has lower latency.
```C++
class DeviceTriBuffer {
    Tri* tris;

    float* coreTriVertex0Xs;
    float* coreTriVertex0Ys;
    float* coreTriVertex0Zs;

    float* coreTriVertex1Xs;
    float* coreTriVertex1Ys;
    float* coreTriVertex1Zs;

    float* coreTriVertex2Xs;
    float* coreTriVertex2Ys;
    float* coreTriVertex2Zs;
    
    size_t numTris;
public:
    __host__ DeviceTriBuffer() = delete;
    __host__ DeviceTriBuffer(const HostMeshManager& hostMeshManager) {
        std::vector<Tri> hostTris;
        std::vector<float> hostCoreTriVertex0Xs;
        std::vector<float> hostCoreTriVertex0Ys;
        std::vector<float> hostCoreTriVertex0Zs;

        std::vector<float> hostCoreTriVertex1Xs;
        std::vector<float> hostCoreTriVertex1Ys;
        std::vector<float> hostCoreTriVertex1Zs;

        std::vector<float> hostCoreTriVertex2Xs;
        std::vector<float> hostCoreTriVertex2Ys;
        std::vector<float> hostCoreTriVertex2Zs;

        int i=0;
        for (HostMesh hm : hostMeshManager.getMeshs()) {
            for (const Tri& t : hm.getTris()) {
                hostTris.push_back(t);
                
                hostCoreTriVertex0Xs.push_back(t.coreTri.v0.x);
                hostCoreTriVertex0Ys.push_back(t.coreTri.v0.y);
                hostCoreTriVertex0Zs.push_back(t.coreTri.v0.z);

                hostCoreTriVertex1Xs.push_back(t.coreTri.v1.x);
                hostCoreTriVertex1Ys.push_back(t.coreTri.v1.y);
                hostCoreTriVertex1Zs.push_back(t.coreTri.v1.z);

                hostCoreTriVertex2Xs.push_back(t.coreTri.v2.x);
                hostCoreTriVertex2Ys.push_back(t.coreTri.v2.y);
                hostCoreTriVertex2Zs.push_back(t.coreTri.v2.z);
            }
            i++;
        }

        numTris = hostTris.size();

        size_t size = hostTris.size() * sizeof(Tri);
        size_t coreTriVertexSize = hostCoreTriVertex0Xs.size() * sizeof(float);

        cudaError_t errs[20];

        errs[2] = cudaMalloc(&coreTriVertex0Xs, coreTriVertexSize);
        errs[3] = cudaMemcpy(coreTriVertex0Xs, hostCoreTriVertex0Xs.data(), coreTriVertexSize, cudaMemcpyHostToDevice);
        errs[4] = cudaMalloc(&coreTriVertex0Ys, coreTriVertexSize);
        errs[5] = cudaMemcpy(coreTriVertex0Ys, hostCoreTriVertex0Ys.data(), coreTriVertexSize, cudaMemcpyHostToDevice);
        errs[6] = cudaMalloc(&coreTriVertex0Zs, coreTriVertexSize);
        errs[7] = cudaMemcpy(coreTriVertex0Zs, hostCoreTriVertex0Zs.data(), coreTriVertexSize, cudaMemcpyHostToDevice);

        errs[8] = cudaMalloc(&coreTriVertex1Xs, coreTriVertexSize);
        errs[9] = cudaMemcpy(coreTriVertex1Xs, hostCoreTriVertex1Xs.data(), coreTriVertexSize, cudaMemcpyHostToDevice);
        errs[10] = cudaMalloc(&coreTriVertex1Ys, coreTriVertexSize);
        errs[11] = cudaMemcpy(coreTriVertex1Ys, hostCoreTriVertex1Ys.data(), coreTriVertexSize, cudaMemcpyHostToDevice);
        errs[12] = cudaMalloc(&coreTriVertex1Zs, coreTriVertexSize);
        errs[13] = cudaMemcpy(coreTriVertex1Zs, hostCoreTriVertex1Zs.data(), coreTriVertexSize, cudaMemcpyHostToDevice);

        errs[14] = cudaMalloc(&coreTriVertex2Xs, coreTriVertexSize);
        errs[15] = cudaMemcpy(coreTriVertex2Xs, hostCoreTriVertex2Xs.data(), coreTriVertexSize, cudaMemcpyHostToDevice);
        errs[16] = cudaMalloc(&coreTriVertex2Ys, coreTriVertexSize);
        errs[17] = cudaMemcpy(coreTriVertex2Ys, hostCoreTriVertex2Ys.data(), coreTriVertexSize, cudaMemcpyHostToDevice);
        errs[18] = cudaMalloc(&coreTriVertex2Zs, coreTriVertexSize);
        errs[19] = cudaMemcpy(coreTriVertex2Zs, hostCoreTriVertex2Zs.data(), coreTriVertexSize, cudaMemcpyHostToDevice);

    __device__ const CoreTri& getCoreTri(unsigned int i) const {
        #ifdef DEBUG
        if (i >= numTris) {
            printf("[DEVICE ERROR] in getCoreTri, index out of range");
        }
        #endif
        return CoreTri(
            Vec3(coreTriVertex0Xs[i], coreTriVertex0Ys[i], coreTriVertex0Zs[i]),
            Vec3(coreTriVertex1Xs[i], coreTriVertex1Ys[i], coreTriVertex1Zs[i]),
            Vec3(coreTriVertex2Xs[i], coreTriVertex2Ys[i], coreTriVertex2Zs[i])
        );
    }
```

### Use only `CoreTri` for intersection checks (1.17x speedup)
If we modify the intersection loop and add another array to `TriBuffer` of `CoreTri`s, then we can just load `CoreTri`s and intersect with them, only loading the actual `Tri` we need
```C++
for (int i = 0; i < deviceTriBuffer.getNumTris(); i++) {
    const CoreTri& tri = deviceTriBuffer.getCoreTri(i);

    _TriDist dist = this->getTriHitDist(tri);

    if (dist.dist > 0.0f && dist.dist < closestDist.dist) {
        closestDist = dist;
        closestTriIndex = i;
    }
}
```
16.7
Final time after optimisation: `16.7s`\
Thats a `19.47/16.7 =` **1.17x speedup**


## Limitations
- **No Energy Conservation:** The lighting model multiplies albedo during bounces and only adds emission when directly hitting a light source. This doesn't conserve energy, leading to biased or overly bright/dark results in complex scenes.
- **Simplified BSDF and Sampling:** Reflections are handled with a basic mix of diffuse and specular based on roughness, without advanced features like Fresnel effects, microfacet models, or importance sampling. Paths use a fixed number of bounces without Russian Roulette, which introduces bias and inefficiency.

These choices were made to keep the code manageable as a first-year student project, allowing me to focus on core implementation rather than perfect theory.


## What I learned
- **Parallel Computing with CUDA:** Optimizing for GPU parallelism (e.g., pixel coherence checks and cache-friendly structs) taught me about thread management, memory access patterns, and achieving massive speedups (like 3664x over CPU).
- **3D Math and Graphics Fundamentals:** Working with rays, vectors, intersections, and materials deepened my understanding of spatial thinking and rendering pipelines.
- **C++ Best Practices:** From debugging device code to using preprocessors for error checking, I improved my proficiency in low-level programming and performance tuning.
