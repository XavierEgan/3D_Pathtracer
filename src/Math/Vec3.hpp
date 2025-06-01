#pragma once

#include <iostream>
#include <cmath>

struct Vec3 {
    float x, y, z;
    
    // constructors
    Vec3() : x(0), y(0), z(0) {}
    Vec3(float x, float y, float z) : x(x), y(y), z(z) {}

    // overriding operators           \/\/ means it doesnt modify this object
    // + overriding
    Vec3 operator+(const Vec3& other) const {
        return Vec3(x + other.x, y + other.y, z + other.z);
    }
    Vec3 operator+(float scalar) const {
        return Vec3(x + scalar, y + scalar, z + scalar);
    }
    // returns reference to this vector so you can chain like (vec += other) += difother
    Vec3& operator+=(const Vec3& other) {
        x += other.x; y += other.y; z += other.z;
        return *this;
    }
    Vec3& operator+=(float scalar) {
        x += scalar; y += scalar; z += scalar;
        return *this;
    }
    
    // - overriding
    Vec3 operator-() const {
        return Vec3(-x, -y, -z);
    }
    Vec3 operator-(const Vec3& other) const {
        return Vec3(x - other.x, y - other.y, z - other.z);
    }
    Vec3 operator-(float scalar) const {
        return Vec3(x - scalar, y - scalar, z - scalar);
    }
    Vec3& operator-=(const Vec3& other) {
        x -= other.x; y -= other.y; z -= other.z;
        return *this;
    }
    Vec3& operator-=(float scalar) {
        x -= scalar; y -= scalar; z -= scalar;
        return *this;
    }

    // * overriding
    Vec3 operator*(const Vec3& other) const {
        return Vec3(x*other.x, y*other.y, z*other.z);
    }
    Vec3 operator*(float scalar) const {
        return Vec3(x * scalar, y * scalar, z * scalar);
    }
    Vec3& operator*=(const Vec3& other) {
        x *= other.x; y *= other.y; z *= other.z;
        return *this;
    }
    Vec3& operator*=(float scalar) {
        x *= scalar; y *= scalar; z *= scalar;
        return *this;
    }
    friend Vec3 operator*(float scalar, const Vec3& vec) {
        return Vec3(vec.x*scalar, vec.y*scalar, vec.z*scalar);
    }

    // / overriding
    Vec3 operator/(const Vec3& other) const {
        return Vec3(x/other.x, y/other.y, z/other.z);
    }
    Vec3 operator/(float scalar) const {
        return Vec3(x / scalar, y / scalar, z / scalar);
    }
    Vec3& operator/=(const Vec3& other) {
        x /= other.x; y /= other.y; z /= other.z;
        return *this;
    }
    Vec3& operator/=(float scalar) {
        x /= scalar; y /= scalar; z /= scalar;
        return *this;
    }
    friend Vec3 operator/(float scalar, const Vec3& vec) {
        // f / v
        // = f*(1/v)
        return Vec3(scalar/vec.x, scalar/vec.y, scalar/vec.z);
    }
    
    // other overrides
    bool operator==(const Vec3& other) const {
        const float epsilon = 1e-6f;
        return std::abs(x - other.x) < epsilon && 
            std::abs(y - other.y) < epsilon && 
            std::abs(z - other.z) < epsilon;
    }

    bool operator!=(const Vec3& other) const {
        return !(*this == other);
    }

    float dot(const Vec3& other) const {
        return x * other.x + y * other.y + z * other.z;
    }

    Vec3 cross(const Vec3& other) const {
        return Vec3(
            y*other.z - z*other.y,
            z*other.x - x*other.z,
            x*other.y - y*other.x
        );
    }

    float length() const {
        return std::sqrt(x*x + y*y + z*z);
    }

    float lengthSquared() const {
        return x*x + y*y + z*z;
    }

    Vec3 normalized() const {
        float len = length();
        return (len > 0) ? *this / len : Vec3();
    }

    Vec3& normalize() {
        *this = normalized();
        return *this;
    }

    friend std::ostream& operator<<(std::ostream& os, const Vec3& vec) {
        os << "(" << vec.x << ", " << vec.y << ", " << vec.z << ")";
        return os;
    }
};
