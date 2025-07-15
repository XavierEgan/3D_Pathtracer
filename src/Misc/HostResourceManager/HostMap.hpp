#pragma once

#include <vector>
#include "../Math/Tri.cuh"

class HostMap {
    std::vector<unsigned char> mapData;
    unsigned int mapWidth;
    unsigned int mapHeight;
    unsigned int channels;

public:
    HostMap() = delete;
    HostMap(const Vec3& color) : mapWidth(1), mapHeight(1), channels(3) {
        mapData = std::vector<unsigned char>();
        mapData.reserve(3);
        mapData.push_back(static_cast<unsigned char>(color.x * 255));
        mapData.push_back(static_cast<unsigned char>(color.y * 255));
        mapData.push_back(static_cast<unsigned char>(color.z * 255));
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