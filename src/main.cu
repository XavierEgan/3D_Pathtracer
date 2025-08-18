// #define REPORT_PERFORMANCE // Make a report of performance and print it (like 2-3x slower)
#define DEBUG // check inputs to functions
#define UNROLL_RAYPPLOOP 4096
#define GAMMA_CORRECTION
#include "Pathtracer.cuh"
#include "Scenes/BenchmarkImage1.cuh"
#include "Scenes/BenchmarkImage2.cuh"
#include "Scenes/BenchmarkImage3.cuh"

int main(void) {
    benchmarkImage1();
    return 0;
}