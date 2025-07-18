# cd build
# cmake .. 
# cmake --build .
# 
# cmake --build . --target clean

# specify build directory:
# cmake -B build -DCMAKE_BUILD_TYPE=Release

# build release
# cmake --build . --config Release
cmake_minimum_required(VERSION 3.18)

project(
    3D_Pathtracer
    VERSION 1.0.0
    LANGUAGES CXX CUDA
)

string(APPEND CMAKE_CUDA_FLAGS_RELEASE " -use_fast_math")

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CUDA_STANDARD 17)
set(CMAKE_CUDA_STANDARD_REQUIRED ON)

# if(NOT CMAKE_BUILD_TYPE)
#     set(CMAKE_BUILD_TYPE Release)
# endif()

find_package(CUDAToolkit REQUIRED)

add_executable(
    d
    #src/main.cpp
    src/Pathtracer.cu
)

set_property(TARGET d PROPERTY CUDA_SEPARABLE_COMPILATION ON)

target_compile_options(d PRIVATE
    $<$<AND:$<COMPILE_LANGUAGE:CUDA>,$<CONFIG:Release>>:--use_fast_math -O3>
    $<$<AND:$<COMPILE_LANGUAGE:CUDA>,$<CONFIG:Debug>>:-G -g>
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

message(STATUS "CMAKE_BUILD_TYPE: ${CMAKE_BUILD_TYPE}")
message(STATUS "CMAKE_CXX_FLAGS_DEBUG: ${CMAKE_CXX_FLAGS_DEBUG}")
message(STATUS "CMAKE_CXX_FLAGS_RELEASE: ${CMAKE_CXX_FLAGS_RELEASE}")
message(STATUS "CMAKE_CUDA_FLAGS_DEBUG: ${CMAKE_CUDA_FLAGS_DEBUG}")
message(STATUS "CMAKE_CUDA_FLAGS_RELEASE: ${CMAKE_CUDA_FLAGS_RELEASE}")