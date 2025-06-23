
#include "Misc/Camera.hpp"

int main(void) {
    std::cout << "Hello, World!";

    Camera camera = Camera(Vec3(), Vec3(0,1,0), ScreenParams(128, 128, 128, 16, 3.1415f/2, 3.1415f, 1.0f));

    

    return 0;
}