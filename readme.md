# 3D Pathtracer
## Overview
This project is a 3D pathtracer implemented in C++ with hardware acceleration using CUDA.

Originally implemented in single-threaded pure C, this new hardware-accelerated version achieves **~4404.38x** speed improvement (more details in the Performance Evolution section below).

![alt text](Readme_Images/overview_image_3.jpg)
- **Render Time**: 3299.6s (O(n) times are not pretty)
- **Resolution**: 512x512
- **Samples**: 8192 rays per pixel
- **Scene Complexity**: 66146 triangles
- **Hardware**: NVIDIA RTX 4090 (16,384 CUDA cores)
- **AABB Intersections**: ~688.9 trillion
- **Ray-Tri Intersections**: ~53.4 billion
- **Throughput**: 208.8 billion AABB Intersection Tests per second

![alt text](Readme_Images/overview_image_1.jpg)
- **Render Time**: 446.39 seconds
- **Resolution**: 512x512
- **Samples**: 8,192 rays per pixel
- **Scene Complexity**: 16394 triangles
- **Hardware**: NVIDIA RTX 4090 (16,384 CUDA cores)
- **AABB Intersections**: ~69.1 trillion
- **Ray-Tri Intersections**: ~36.6 billion
- **Throughput**: 154.8 billion AABB Intersection Tests per second

That's more than one AABB intersection test for every human that has ever lived per second!

**NOTE:**intersections were calculated by rendering scenes with 64x less resolution and turning performance analytics on, then multiplying the results by 64. 


![alt text](Readme_Images/overview_image_2.jpg)
- **Render Time**: 712.0 seconds (before BVHT)
- **Resolution**: 2048x2048
- **Samples**: 16384 rays per pixel
- **Scene Complexity**: 588 triangles
- **Hardware**: NVIDIA RTX 4090 (16,384 CUDA cores)
- **AABB Intersections**: ~135.7 trillion
- **Ray-Tri Intersections**: ~47.2 billion
- **Throughput**: 190.6 billion AABB Intersection Tests per second

## Quick Start
**Requirements:**\
- NVIDIA GPU
- CUDA Toolkit
- CMake 3.18+
Step 0:\
Install the CUDA Toolkit onto your system from [here](https://developer.nvidia.com/cuda-toolkit)
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
Release\d
```
or
```bash
Debug\d
```

## Performance Evolution
- **V1**: Single Threaded CPU (~5 hours)
- **V2**: CUDA (~4.16 seconds)
- **V3**: OptiX and OpenGL Mathematics (GLM) (Unknown, future project)

**NOTE:** V1 did have multithreaded through #pragma omp parallel for, however it was never benchmarked, so single threaded numbers are being used
### Improvement Over V1

In V1 of this project, the following image took `18322.2s` to render.
![alt text](Readme_Images/V1_image_1.png)
- **Render Time**: 18322.2 seconds
- **Resolution**: 2048×2048
- **Samples**: 2,048 rays per pixel  
- **Scene Complexity**: 30 triangles
- **Hardware**: Intel Core i9-12900k

Comparing to a render of V2, which took `4.16s` to render
![alt text](Readme_Images/V2_image_1.jpg)
- **Render Time**: 4.16 seconds
- **Resolution**: 2048×2048 (4.2M pixels)
- **Samples**: 2,048 rays per pixel
- **Scene Complexity**: 30 triangles
- **Hardware**: NVIDIA RTX 4090 (16,384 CUDA cores)

**NOTE:** The images are not identical, however the main differences are simple texture and color. The geometry is identical.

Performance Speedup: `18322.2 / 4.16 =` **4404.38x Speedup**

#### Why not 16,384x speedup?
- **Texture sampling overhead** - V2 includes texture mapping
- **Better material system** - V2 includes a more complex material system, allowing transparent objects.
- **Launch overhead** - CUDA kernel launches have costs
- **Slower Cores** - CUDA cores are optimised for massive throughput, as opposed to CPU cores which are optimised for single core performance.

## Optimisations
We will be Benchmarking with this image:
![alt text](Readme_Images\benchmark_image_1.jpg)
- **Resolution**: 2048×2048 (4.2M pixels)
- **Samples**: 8,192 rays per pixel
- **Scene Complexity**: 30 triangles
- **Hardware**: NVIDIA RTX 4090 (16,384 CUDA cores)

**Starting Render Time:** 45.6s

**NOTE:** Timings have a variance of up to +-1s depending on many factors

### Early Pixel Termination (1.065x speedup)
We can cast 9 strategic rays (corners, edges, middle) And if all of them don't hit anything, we consider the pixel to be black and early return.

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
This optimisation was discovered by accident while working on the below optimisation (Ray Coherence)

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

This is especially useful in the `getTri` method, as this is run for every ray-tri intercept check
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
`bsdfReflect` was in desperate need of a rewrite, the code was messy and inefficient

The main way this improved performance was removing branches and only performing computation needed for the type of reflection

Final time after optimisation: `22.5s`\
Thats a `24.3/22.5 =` **1.08x speedup**

### Split Tri into CoreTri and Tri (1.16x speedup)
This optimisation makes ray intersection checking faster since it stores a new struct, `CoreTri` (9 floats, 36 bytes) in a separate array from `Tri`. When the loop inside `getTriIntersection` runs, we get more cache hits. This is because when we arrange `CoreTri`s in contiguous memory, it's more likely for data we need to be arranged on the same cache line. This means we are more likely to bring in the vertices (what we actually need for ray-tri intercept) into the cache, rather than bringing in UV's or other almost useless information (only useful when we get a hit).

It's important to note that at 36 bytes, `CoreTri` is not aligned with cache lines meaning we may bring in part of the next `CoreTri` into the cache, but not the whole thing

Final time after optimisation: `19.47s`\
Thats a `22.5/19.47 =` **1.16x speedup**

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
