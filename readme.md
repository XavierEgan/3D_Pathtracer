# 3D_Pathtracer
This project is a 3D pathtracer built in pure C which renders an image in the `.ppm` format. 

## Key Features
- **Pure C implementation** - No external libraries
- **Physically-based rendering** - Accurate light transport simulation
- **Multi-bounce global illumination** - Realistic lighting with reflections
- **Command-line progress tracking** - Real-time render statistics

## Technical Implementation
- **Ray-triangle intersection** using Möller-Trumbore algorithm
- **Monte Carlo sampling** for anti-aliasing and global illumination
- **Cosine-weighted hemisphere sampling** for realistic diffuse reflections
- **Perfect specular reflection** for mirror surfaces
- **PPM image output** for simple, uncompressed results

## Future Optimizations
The pathtracer is incredibly slow, lacking many basic optimisations. However, the following optimisations are in the roadmap for implementation:
- **Adaptive pixel sampling**: Instead of always casting all 1000+ rays per pixel, first cast 9 strategic rays (corners, edges, center). If they all miss, skip the remaining rays. If they all hit the same triangle, only test that triangle for the remaining rays.
- **Triangle coherence optimization**: When the initial sample rays all hit the same triangle, we can skip testing other triangles for the remaining rays in that pixel.
 - **Bounding Volume Hierarchy Tree**. We can arrange the triangles into a binary tree with each node being a Axis Aligned Bounding Box. This means we can cut out triangle search space in half at each step, resulting in $O(log(n))$ instead of $O(n)$
 - **SIMD Instructions** to make 4 ray triangle intersection checks in parallel

## Unoptimized Renderer
This is the first complete, unoptimized implimentaion. It uses a lot of brute force to render the image, resulting in long render times.

Future optimisations will be explainedi in a later section with performance analysis

### Examples
![blob of bright triangles in a multi colored room with a mirror](readme_images/Render1.png)  
#### Performance
**Render Time:** 747s (12m 27s)  
#### Specs  
**CPU:** i9-12900k  
**Threads:** 1  
**Compiler:** gcc  
**Compiler Flags:** -Wall -g -mavx -O3 (although mavx is not used)  
#### Render Params
**Dimensions:** 500x500  
**Rays Per Pixel:** 1024  
**Max Bounces Per Ray:** 20  
**Horizontal FOV:** 90  
**Triangles:** 30

![blob of bright triangles in a multi colored room with mirros facing each other so its repeated a bunch of times](readme_images/Render2.png)  

#### Performance
**Render Time:** 870.5s (14m 30s)  
#### Specs  
**CPU:** i9-12900k  
**Threads:** 1  
**Compiler:** gcc  
**Compiler Flags:** -Wall -g -mavx -O3 (although mavx is not used)  
#### Render Params
**Dimensions:** 500x500  
**Rays Per Pixel:** 1024  
**Max Bounces Per Ray:** 50  
**Horizontal FOV:** 90  
**Triangles:** 30

### Performance Analysis
You might be wondering whats taking an i9-12900k almost 15 minutes to render only 30 triangles at 500x500 resolution?  
Well, there are $500\times500 = 250,000$ pixels  
each pixel casting $1024$ rays  
each ray bouncing a max of $50$ times  
each ray checking $30$ triangles (this highlights the need for a BVHT)  
```math
\text{Worst case (every ray bouncing 50 times): }500\times 500\times 1024\times 50\times 30 = 384,000,000,000
```
```math
\text{Average case (every ray bouncing 5 times, half triangles culled): }
500\times 500\times 1024\times 5\times 15 = 19,200,000,000
```
```math
\text{Reasonable Best case (every ray bouncing 1 times, half triangles culled): }
500\times 500\times 1024\times 15 = 3,840,000,000 
```
Even in the best case there is still almost 4 billion ray intersect checks to complete, or 4.5 million per second at 870.5s render time.