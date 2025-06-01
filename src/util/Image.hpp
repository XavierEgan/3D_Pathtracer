#pragma once

#include <iostream>
#include <vector>

#define STB_IMAGE_IMPLEMENTATION
#include "../ext/stb_image.h"

struct Image {
    uint8_t* get_image_data(const char* fileName, int& x, int& y, int& channels,  int force_channels) {

        unsigned char* data = stbi_load(fileName, &x, &y, &channels, force_channels);

        if (data == nullptr) {
            std::cout << "Failed to load image: " << stbi_failure_reason() << std::endl;
        }

        return data;
    }

    void free_image_data(uint8_t* data) {
        stbi_image_free(data);
    }
};