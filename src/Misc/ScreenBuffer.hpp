#pragma once
#include <vector>

#include "Camera.hpp"
#include "../Ext/stb_image_write.h"

struct ScreenBuffer {
    std::vector<char> data;

    unsigned int width;
    unsigned int height;

    ScreenBuffer(ScreenParams screenParams) : width(screenParams.width), height(screenParams.height) {
        data = std::vector<char>();
        data.resize((screenParams.width * screenParams.height + 10), 0); // 3 for r,g,b
    }

    void write(Vec3 data, unsigned int x, unsigned int y) {
        this->data[y * width * 3 + x * 3] = (char)(data.x * 255);
        this->data[y * width * 3 + x * 3 + 1] = (char)(data.y * 255);
        this->data[y * width * 3 + x * 3 + 2] = (char)(data.z * 255);
    }

    void writeImage(char* fileLoc) {
        const int maxQuality = 100;
        stbi_write_jpg(fileLoc, width, height, 3, data.data(), maxQuality);
    }
};
