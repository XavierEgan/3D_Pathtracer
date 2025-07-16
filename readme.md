# 3D Pathtracer
## Overview
This project is a 3D pathtracer implemented in C++ with hardware acceleration using CUDA.

Originally implemented in single-threaded pure C, this new hardware-accelerated version achieves **~1,520.5x** speed improvement (more details in Performance Evolution section below).

![alt text](Readme_Images/img1.jpg)
*Physically accurate global illumination with complex material interactions. The left wall has 0.7 roughness, creating realistic mixed diffuse-specular reflections.*\
**Note**: Gamma correction disabled for artistic preference
- **Render Time**: 13.2 seconds  
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
- **V1**: Single Threaded CPU (~5 hours above)
- **V2**: CUDA parallel processing (~13 seconds)

**NOTE:** V1 did have multithreaded through #pragma omp parallel for, however it was harder to benchmark, so single threaded numbers are being used
### Improvement Over V1

In V1 of this project, the following image took `18322.2s` to render.
![alt text](Readme_Images/img2.png)
- **Resolution**: 1024x1024
- **Samples**: 8,192 rays per pixel  
- **Scene Complexity**: 30 triangles
- **Hardware**: Intel Core i9-12900k

Comparing to a render of V2, which took `48.2s` to render
![alt text](Readme_Images/img3.png)
- **Resolution**: 2048×2048 (4.2M pixels)
- **Samples**: 8,192 rays per pixel
- **Scene Complexity**: 30 triangles
- **Hardware**: NVIDIA RTX 4090 (16,384 CUDA cores)

**NOTE:** The images are not identical, however they are close enough in complexity to reasonably compare performance

The render from V2 was `4x` more complex than the render from V1 (`2048x2048 = (2*1024)x(2*1024) = 4*(1024x1024)`)

Performance Speedup: `(18322.2 * 4) / 48.2 =` **1520.5x Speedup**

#### Why not 16,384x speedup?
- **Texture sampling overhead** - V2 includes texture mapping
- **Launch overhead** - CUDA kernel launches have costs
- **Unoptimized code** - V2 is initial implementation without optimizations

### Optimisations
We will be Benchmarking with this image:
![alt text](Readme_Images/img3.png)
- **Resolution**: 2048×2048 (4.2M pixels)
- **Samples**: 8,192 rays per pixel
- **Scene Complexity**: 30 triangles
- **Hardware**: NVIDIA RTX 4090 (16,384 CUDA cores)

**Starting Render Time:** 48.2s