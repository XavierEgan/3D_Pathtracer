#pragma once

/*  
    Written by Xavier Egan 2025
    WAY WAY WAY overuses SFINAE because im using this as an opportunity to learn it. Also a lot of the SFINAE is completely redundant.
    Also uses old style ::value instead of _v coz its better for learning
*/

#include <iostream>
#include <type_traits>
#include <string>

#define EPSILON 1.0e-6f

struct Vec3 {
    float x;
    float y;
    float z;

    __host__ __device__ constexpr Vec3() : x(0), y(0), z(0) {}
    __host__ __device__ constexpr Vec3(float x, float y, float z) : x(x), y(y), z(z) {}

    __host__ __device__ void print() const {
        printf("(%f,%f,%f)\n", x, y, z);
    }
    __host__ __device__ void print(const char* name) const {
        printf("%s: (%f,%f,%f)\n", name, x, y, z);
    }

    // + overrite
    template<typename T>
    __host__ __device__ constexpr typename std::enable_if<std::is_same<T, Vec3>::value, Vec3>::type operator+(const T& other) const {
        return Vec3(x + other.x, y + other.y, z + other.z);
    }
    template<typename T>
    __host__ __device__ constexpr typename std::enable_if<std::is_arithmetic<T>::value, Vec3>::type operator+(const T other) const {
        return Vec3(x + other, y + other, z + other);
    }
    template<typename T>
    __host__ __device__ constexpr typename std::enable_if<std::is_same<T, Vec3>::value, Vec3&>::type operator+=(const T& other) { // returns Vec3& so you can chain them if you want
        x += other.x; y += other.y; z += other.z;
        return *this;
    }
    template<typename T>
    __host__ __device__ constexpr typename std::enable_if<std::is_arithmetic<T>::value, Vec3&>::type operator+=(const T& other) { // returns Vec3& so you can chain them if you want
        x += other; y += other; z += other;
        return *this;
    }
    template<typename T, typename V>
    __host__ __device__ constexpr friend typename std::enable_if<std::is_arithmetic<T>::value && std::is_same<V, Vec3>::value, Vec3>::type operator+(const T other, const V& vec) {
        return Vec3(vec.x + other, vec.y + other, vec.z + other);
    }

    // - overrite
    template<typename T>
    __host__ __device__ constexpr typename std::enable_if<std::is_same<T, Vec3>::value, Vec3>::type operator-(const T& other) const {
        return Vec3(x - other.x, y - other.y, z - other.z);
    }
    template<typename T>
    __host__ __device__ constexpr typename std::enable_if<std::is_arithmetic<T>::value, Vec3>::type operator-(const T other) const {
        return Vec3(x - other, y - other, z - other);
    }
    template<typename T>
    __host__ __device__ constexpr typename std::enable_if<std::is_same<T, Vec3>::value, Vec3&>::type operator-=(const T& other) { // returns Vec3& so you can chain them if you want
        x -= other.x; y -= other.y; z -= other.z;
        return *this;
    }
    template<typename T>
    __host__ __device__ constexpr typename std::enable_if<std::is_arithmetic<T>::value, Vec3&>::type operator-=(const T& other) { // returns Vec3& so you can chain them if you want
        x -= other; y -= other; z -= other;
        return *this;
    }
    template<typename T, typename V>
    __host__ __device__ constexpr friend typename std::enable_if<std::is_arithmetic<T>::value && std::is_same<V, Vec3>::value, Vec3>::type operator-(const T other, const V& vec) {
        return Vec3(other - vec.x, other - vec.y, other - vec.z);
    }
    __host__ __device__ Vec3 operator-() const {
        return Vec3(-x, -y, -z);
    }

    // * overrite
    template<typename T>
    __host__ __device__ constexpr typename std::enable_if<std::is_same<T, Vec3>::value, Vec3>::type operator*(const T& other) const {
        return Vec3(x * other.x, y * other.y, z * other.z);
    }
    template<typename T>
    __host__ __device__ constexpr typename std::enable_if<std::is_arithmetic<T>::value, Vec3>::type operator*(const T other) const {
        return Vec3(x * other, y * other, z * other);
    }
    template<typename T>
    __host__ __device__ constexpr typename std::enable_if<std::is_same<T, Vec3>::value, Vec3&>::type operator*=(const T& other) { // returns Vec3& so you can chain them if you want
        x *= other.x; y *= other.y; z *= other.z;
        return *this;
    }
    template<typename T>
    __host__ __device__ constexpr typename std::enable_if<std::is_arithmetic<T>::value, Vec3&>::type operator*=(const T& other) { // returns Vec3& so you can chain them if you want
        x *= other; y *= other; z *= other;
        return *this;
    }
    template<typename T, typename V>
    __host__ __device__ constexpr friend typename std::enable_if<std::is_arithmetic<T>::value && std::is_same<V, Vec3>::value, Vec3>::type operator*(const T other, const V& vec) {
        return Vec3(vec.x * other, vec.y * other, vec.z * other);
    }

    // / overrite
    template<typename T>
    __host__ __device__ constexpr typename std::enable_if<std::is_same<T, Vec3>::value, Vec3>::type operator/(const T& other) const {
        // computing the / first them mult might stuff up compiler optimisations so im just gonna have this to play it safe
        return Vec3(x / other.x, y / other.y, z / other.z);
    }
    template<typename T>
    __host__ __device__ constexpr typename std::enable_if<std::is_arithmetic<T>::value, Vec3>::type operator/(const T other) const {
        // computing the / first them mult might stuff up compiler optimisations so im just gonna have this to play it safe
        return Vec3(x / other, y / other, z / other);
    }
    template<typename T>
    __host__ __device__ constexpr typename std::enable_if<std::is_same<T, Vec3>::value, Vec3&>::type operator/=(const T& other) { // returns Vec3& so you can chain them if you want
        x /= other.x; y /= other.y; z /= other.z;
        return *this;
    }
    template<typename T>
    __host__ __device__ constexpr typename std::enable_if<std::is_arithmetic<T>::value, Vec3&>::type operator/=(const T& other) { // returns Vec3& so you can chain them if you want
        x /= other; y /= other; z /= other;
        return *this;
    }
    template<typename T, typename V>
    __host__ __device__ constexpr friend typename std::enable_if<std::is_arithmetic<T>::value && std::is_same<V, Vec3>::value, Vec3>::type operator/(const T other, const V& vec) {
        return Vec3(other / vec.x , other / vec.y , other/ vec.z);
    }

    // comparison overrites
    template<typename T> 
    __host__ __device__ constexpr typename std::enable_if<std::is_same<T, Vec3>::value, bool>::type operator>(const T& other) const {
        return x > other.x && y > other.y && z > other.z;
    }
    template<typename T> 
    __host__ __device__ constexpr typename std::enable_if<std::is_same<T, Vec3>::value, bool>::type operator>=(const T& other) const {
        return x >= other.x && y >= other.y && z >= other.z;
    }
    template<typename T> 
    __host__ __device__ constexpr typename std::enable_if<std::is_arithmetic<T>::value, bool>::type operator>(const T& other) const {
        return x > other && y > other && z > other;
    }
    template<typename T> 
    __host__ __device__ constexpr typename std::enable_if<std::is_arithmetic<T>::value, bool>::type operator>=(const T& other) const {
        return x >= other && y >= other && z >= other;
    }
    template<typename T> 
    __host__ __device__ constexpr typename std::enable_if<std::is_same<T, Vec3>::value, bool>::type operator<(const T& other) const {
        return x < other.x && y < other.y && z < other.z;
    }
    template<typename T> 
    __host__ __device__ constexpr typename std::enable_if<std::is_same<T, Vec3>::value, bool>::type operator<=(const T& other) const {
        return x <= other.x && y <= other.y && z <= other.z;
    }
    template<typename T> 
    __host__ __device__ constexpr typename std::enable_if<std::is_arithmetic<T>::value, bool>::type operator<(const T& other) const {
        return x < other && y < other && z < other;
    }
    template<typename T> 
    __host__ __device__ constexpr typename std::enable_if<std::is_arithmetic<T>::value, bool>::type operator<=(const T& other) const {
        return x <= other && y <= other && z <= other;
    }
    template<typename T> 
    __host__ __device__ constexpr typename std::enable_if<std::is_same<T, Vec3>::value, bool>::type operator==(const T& other) const {
        return x == other.x && y == other.y && z == other.z; 
    }
    template<typename T> 
    __host__ __device__ constexpr typename std::enable_if<std::is_same<T, Vec3>::value, bool>::type operator!=(const T& other) const {
        return x != other.x || y != other.y || z != other.z; 
    }
    template<typename T> 
    __host__ __device__ constexpr typename std::enable_if<std::is_arithmetic<T>::value, bool>::type operator==(const T& other) const {
        return x == other && y == other && z == other;
    }
    template<typename T> 
    __host__ __device__ constexpr typename std::enable_if<std::is_arithmetic<T>::value, bool>::type operator!=(const T& other) const {
        return x != other && y != other && z != other;
    }
    
    // other helpers
    template<typename T>
    __host__ __device__ constexpr typename std::enable_if<std::is_same<T, Vec3>::value, float>::type dot(const T& other) const {
        return x*other.x + y*other.y + z*other.z;
    }

    template<typename T>
    __host__ __device__ constexpr typename std::enable_if<std::is_same<T, Vec3>::value, Vec3>::type cross(const T& other) const {
        return Vec3(
            y*other.z - z*other.y,
            z*other.x - x*other.z,
            x*other.y - y*other.x
        );
    }

    __host__ __device__ constexpr float lengthSquared() const {
        return x*x + y*y + z*z;
    }

    __host__ __device__ float length() const {
        return sqrtf(x*x + y*y + z*z);
    }

    __host__ __device__ float invLength() const {
        return rsqrtf(x*x + y*y + z*z);
    }

    __host__ __device__ Vec3& normalize() {
        float invLen = this->invLength();
        this->x *= invLen;
        this->y *= invLen;
        this->z *= invLen;
        return *this;
    }

    __host__ __device__ constexpr friend Vec3 min(Vec3& t, Vec3& o) {
        return Vec3(fminf(t.x, o.x), fminf(t.y, o.y), fminf(t.z, o.z));
    }

    __host__ __device__ constexpr friend Vec3 max(Vec3& t, Vec3& o) {
        return Vec3(fmaxf(t.x, o.x), fmaxf(t.y, o.y), fmaxf(t.z, o.z));
    }

    __host__ __device__ constexpr Vec3 normalized() const {
        return *this * this->invLength();
    }

    __host__ __device__ constexpr Vec3 epsilonShift(const Vec3& dir) const {
        // dir should be normalised
        return *this + dir * EPSILON;
    }

    __host__ __device__ constexpr Vec3 clamp(float min, float max) const {
        // dir should be normalised
        return Vec3(fmaxf(fminf(x, max), min), fmaxf(fminf(y, max), min), fmaxf(fminf(z, max), min));
    }

    static const Vec3 FORWARD;
    static const Vec3 BACK;
    static const Vec3 LEFT;
    static const Vec3 RIGHT;
    static const Vec3 UP;
    static const Vec3 DOWN;
    
    static const Vec3 RED;
    static const Vec3 GREEN;
    static const Vec3 BLUE;
    static const Vec3 WHITE;
    static const Vec3 BLACK;

    static const Vec3 YELLOW;
    static const Vec3 MAGENTA;
    static const Vec3 CYAN;
    static const Vec3 ORANGE;
    static const Vec3 PURPLE;
    static const Vec3 GRAY;
};

constexpr Vec3 Vec3::FORWARD = Vec3(-1.0f, 0.0f, 0.0f);
constexpr Vec3 Vec3::BACK = Vec3(1.0f, 0.0f, 0.0f);
constexpr Vec3 Vec3::LEFT = Vec3(0.0f, 0.0f, -1.0f);
constexpr Vec3 Vec3::RIGHT = Vec3(0.0f, 0.0f, 1.0f);
constexpr Vec3 Vec3::UP = Vec3(0.0f, 1.0f, 0.0f);
constexpr Vec3 Vec3::DOWN = Vec3(0.0f, -1.0f, 0.0f);

constexpr Vec3 Vec3::RED = Vec3(1.0f, 0.0f, 0.0f);
constexpr Vec3 Vec3::GREEN = Vec3(0.0f, 1.0f, 0.0f);
constexpr Vec3 Vec3::BLUE = Vec3(0.0f, 0.0f, 1.0f);
constexpr Vec3 Vec3::WHITE = Vec3(1.0f, 1.0f, 1.0f);
constexpr Vec3 Vec3::BLACK = Vec3(0.0f, 0.0f, 0.0f);

constexpr Vec3 Vec3::YELLOW = Vec3(1.0f, 1.0f, 0.0f);
constexpr Vec3 Vec3::MAGENTA = Vec3(1.0f, 0.0f, 1.0f);
constexpr Vec3 Vec3::CYAN = Vec3(0.0f, 1.0f, 1.0f);
constexpr Vec3 Vec3::ORANGE = Vec3(1.0f, 0.5f, 0.0f);
constexpr Vec3 Vec3::PURPLE = Vec3(0.5f, 0.0f, 0.5f);
constexpr Vec3 Vec3::GRAY = Vec3(0.5f, 0.5f, 0.5f);