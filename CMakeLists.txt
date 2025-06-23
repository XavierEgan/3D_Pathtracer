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

add_compile_options($<$<COMPILE_LANGUAGE:CXX>:-Wall>)
add_compile_options($<$<COMPILE_LANGUAGE:C>:-Wall>)

add_compile_options($<$<COMPILE_LANGUAGE:CUDA>:-Xcompiler=-Wall,-wd4514,-wd4710,-wd4711>) # make the  noisy ones shut up

find_package(CUDAToolkit REQUIRED)

add_executable(
    d
    src/main.cpp
)

target_link_libraries(d CUDA::cudart)