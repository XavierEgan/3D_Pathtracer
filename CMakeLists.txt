# cd build
# cmake .. 
# cmake --build .
# 
# cmake --build . --target clean
cmake_minimum_required(VERSION 3.18)

project(
    3D_Pathtracer
    VERSION 1.0.0
    LANGUAGES CXX CUDA
)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CUDA_STANDARD 17)
set(CMAKE_CUDA_STANDARD_REQUIRED ON)



find_package(CUDAToolkit REQUIRED)

add_executable(
    d
    #src/main.cpp
    src/Pathtracer.cu
)

target_include_directories(
    d
    PRIVATE 
        ${CMAKE_CURRENT_SOURCE_DIR}/src/Math
        ${CMAKE_CURRENT_SOURCE_DIR}/src/Misc
        ${CMAKE_CURRENT_SOURCE_DIR}/src/Ext
        ${CMAKE_CURRENT_SOURCE_DIR}/src/Kernels
)

target_link_libraries(d CUDA::cudart)