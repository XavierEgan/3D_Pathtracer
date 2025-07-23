#pragma once

#include <vector>
#include "../Math/Tri.cuh"

#include <filesystem>

#define STB_IMAGE_IMPLEMENTATION
#include "../Ext/stb_image.h"

class HostMap {
    std::vector<unsigned char> mapData;
    int mapWidth;
    int mapHeight;
    int channels;

public:
    HostMap() = delete;
    HostMap(const Vec3& color) : mapWidth(1), mapHeight(1), channels(3) {
        mapData = std::vector<unsigned char>();
        mapData.reserve(3);
        mapData.push_back(static_cast<unsigned char>(color.x * 255));
        mapData.push_back(static_cast<unsigned char>(color.y * 255));
        mapData.push_back(static_cast<unsigned char>(color.z * 255));
    }
    HostMap(const char* filename) {
        unsigned char *data = stbi_load(filename, &mapWidth, &mapHeight, &channels, 0);

        if (!data) {
            printf("[HOST] Error loading %s. Message: %s\n", filename, stbi_failure_reason());
            std::string path = "./";

            for (const auto & entry : std::filesystem::directory_iterator(path)) {
                std::cout << entry.path() << std::endl;
            }

            // load the texture not found image
            const char* imageNotFoundTexture = "../src/Textures/notLoadedTexture.png";
            data = stbi_load(imageNotFoundTexture, &mapWidth, &mapHeight, &channels, 0);
        }

        mapData = std::vector(data, data + (mapWidth * mapHeight * channels));

        stbi_image_free(data);
    }
    
    unsigned int getWidth() const {
        return mapWidth;
    }

    unsigned int getHeight() const {
        return mapHeight;
    }

    unsigned int getChannels() const {
        return channels;
    }

    std::vector<unsigned char> getData() const {
        return mapData;
    }
};