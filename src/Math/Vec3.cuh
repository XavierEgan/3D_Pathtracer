#pragma once

/*  
    Written by Xavier Egan 2025
    WAY WAY WAY overuses SFINAE because im using this as an opportunity to learn it. Also a lot of the SFINAE is completely redundant.
    Also uses old style ::value instead of _v coz its better for learning
*/

#include <iostream>
#include <type_traits>
#include <string>

struct Vec3 {
    float x;
    float y;
    float z;

    __host__ __device__ Vec3() : x(0), y(0), z(0) {}
    __host__ __device__ Vec3(float x, float y, float z) : x(x), y(y), z(z) {}

    __host__ __device__ void print() const {
        printf("(%f,%f,%f)\n", x, y, z);
    }
    __host__ __device__ void print(const char* name) const {
        printf("%s: (%f,%f,%f)\n", name, x, y, z);
    }

    // + overrite
    template<typename T>
    __host__ __device__ typename std::enable_if<std::is_same<T, Vec3>::value, Vec3>::type operator+(const T& other) const {
        return Vec3(x + other.x, y + other.y, z + other.z);
    }
    template<typename T>
    __host__ __device__ typename std::enable_if<std::is_arithmetic<T>::value, Vec3>::type operator+(const T other) const {
        return Vec3(x + other, y + other, z + other);
    }
    template<typename T>
    __host__ __device__ typename std::enable_if<std::is_same<T, Vec3>::value, Vec3&>::type operator+=(const T& other) { // returns Vec3& so you can chain them if you want
        x += other.x; y += other.y; z += other.z;
        return *this;
    }
    template<typename T>
    __host__ __device__ typename std::enable_if<std::is_arithmetic<T>::value, Vec3&>::type operator+=(const T& other) { // returns Vec3& so you can chain them if you want
        x += other; y += other; z += other;
        return *this;
    }
    template<typename T, typename V>
    __host__ __device__ friend typename std::enable_if<std::is_arithmetic<T>::value && std::is_same<V, Vec3>::value, Vec3>::type operator+(const T other, const V& vec) {
        return Vec3(vec.x + other, vec.y + other, vec.z + other);
    }

    // - overrite
    template<typename T>
    __host__ __device__ typename std::enable_if<std::is_same<T, Vec3>::value, Vec3>::type operator-(const T& other) const {
        return Vec3(x - other.x, y - other.y, z - other.z);
    }
    template<typename T>
    __host__ __device__ typename std::enable_if<std::is_arithmetic<T>::value, Vec3>::type operator-(const T other) const {
        return Vec3(x - other, y - other, z - other);
    }
    template<typename T>
    __host__ __device__ typename std::enable_if<std::is_same<T, Vec3>::value, Vec3&>::type operator-=(const T& other) { // returns Vec3& so you can chain them if you want
        x -= other.x; y -= other.y; z -= other.z;
        return *this;
    }
    template<typename T>
    __host__ __device__ typename std::enable_if<std::is_arithmetic<T>::value, Vec3&>::type operator-=(const T& other) { // returns Vec3& so you can chain them if you want
        x -= other; y -= other; z -= other;
        return *this;
    }
    template<typename T, typename V>
    __host__ __device__ friend typename std::enable_if<std::is_arithmetic<T>::value && std::is_same<V, Vec3>::value, Vec3>::type operator-(const T other, const V& vec) {
        return Vec3(other - vec.x, other - vec.y, other - vec.z);
    }
    __host__ __device__ Vec3 operator-() const {
        return Vec3(-x, -y, -z);
    }

    // * overrite
    template<typename T>
    __host__ __device__ typename std::enable_if<std::is_same<T, Vec3>::value, Vec3>::type operator*(const T& other) const {
        return Vec3(x * other.x, y * other.y, z * other.z);
    }
    template<typename T>
    __host__ __device__ typename std::enable_if<std::is_arithmetic<T>::value, Vec3>::type operator*(const T other) const {
        return Vec3(x * other, y * other, z * other);
    }
    template<typename T>
    __host__ __device__ typename std::enable_if<std::is_same<T, Vec3>::value, Vec3&>::type operator*=(const T& other) { // returns Vec3& so you can chain them if you want
        x *= other.x; y *= other.y; z *= other.z;
        return *this;
    }
    template<typename T>
    __host__ __device__ typename std::enable_if<std::is_arithmetic<T>::value, Vec3&>::type operator*=(const T& other) { // returns Vec3& so you can chain them if you want
        x *= other; y *= other; z *= other;
        return *this;
    }
    template<typename T, typename V>
    __host__ __device__ friend typename std::enable_if<std::is_arithmetic<T>::value && std::is_same<V, Vec3>::value, Vec3>::type operator*(const T other, const V& vec) {
        return Vec3(vec.x * other, vec.y * other, vec.z * other);
    }

    // / overrite
    template<typename T>
    __host__ __device__ typename std::enable_if<std::is_same<T, Vec3>::value, Vec3>::type operator/(const T& other) const {
        // computing the / first them mult might stuff up compiler optimisations so im just gonna have this to play it safe
        return Vec3(x / other.x, y / other.y, z / other.z);
    }
    template<typename T>
    __host__ __device__ typename std::enable_if<std::is_arithmetic<T>::value, Vec3>::type operator/(const T other) const {
        // computing the / first them mult might stuff up compiler optimisations so im just gonna have this to play it safe
        return Vec3(x / other, y / other, z / other);
    }
    template<typename T>
    __host__ __device__ typename std::enable_if<std::is_same<T, Vec3>::value, Vec3&>::type operator/=(const T& other) { // returns Vec3& so you can chain them if you want
        x /= other.x; y /= other.y; z /= other.z;
        return *this;
    }
    template<typename T>
    __host__ __device__ typename std::enable_if<std::is_arithmetic<T>::value, Vec3&>::type operator/=(const T& other) { // returns Vec3& so you can chain them if you want
        x /= other; y /= other; z /= other;
        return *this;
    }
    template<typename T, typename V>
    __host__ __device__ friend typename std::enable_if<std::is_arithmetic<T>::value && std::is_same<V, Vec3>::value, Vec3>::type operator/(const T other, const V& vec) {
        return Vec3(other / vec.x , other / vec.y , other/ vec.z);
    }

    // comparison overrites
    template<typename T> 
    __host__ __device__ typename std::enable_if<std::is_same<T, Vec3>::value, bool>::type operator>(const T& other) const {
        return x > other.x && y > other.y && z > other.z;
    }
    template<typename T> 
    __host__ __device__ typename std::enable_if<std::is_same<T, Vec3>::value, bool>::type operator>=(const T& other) const {
        return x >= other.x && y >= other.y && z >= other.z;
    }
    template<typename T> 
    __host__ __device__ typename std::enable_if<std::is_arithmetic<T>::value, bool>::type operator>(const T& other) const {
        return x > other && y > other && z > other;
    }
    template<typename T> 
    __host__ __device__ typename std::enable_if<std::is_arithmetic<T>::value, bool>::type operator>=(const T& other) const {
        return x >= other && y >= other && z >= other;
    }
    template<typename T> 
    __host__ __device__ typename std::enable_if<std::is_same<T, Vec3>::value, bool>::type operator<(const T& other) const {
        return x < other.x && y < other.y && z < other.z;
    }
    template<typename T> 
    __host__ __device__ typename std::enable_if<std::is_same<T, Vec3>::value, bool>::type operator<=(const T& other) const {
        return x <= other.x && y <= other.y && z <= other.z;
    }
    template<typename T> 
    __host__ __device__ typename std::enable_if<std::is_arithmetic<T>::value, bool>::type operator<(const T& other) const {
        return x < other && y < other && z < other;
    }
    template<typename T> 
    __host__ __device__ typename std::enable_if<std::is_arithmetic<T>::value, bool>::type operator<=(const T& other) const {
        return x <= other && y <= other && z <= other;
    }
    template<typename T> 
    __host__ __device__ typename std::enable_if<std::is_same<T, Vec3>::value, bool>::type operator==(const T& other) const {
        return x == other.x && y == other.y && z == other.z; 
    }
    template<typename T> 
    __host__ __device__ typename std::enable_if<std::is_same<T, Vec3>::value, bool>::type operator!=(const T& other) const {
        return x != other.x || y != other.y || z != other.z; 
    }
    template<typename T> 
    __host__ __device__ typename std::enable_if<std::is_arithmetic<T>::value, bool>::type operator==(const T& other) const {
        return x == other && y == other && z == other;
    }
    template<typename T> 
    __host__ __device__ typename std::enable_if<std::is_arithmetic<T>::value, bool>::type operator!=(const T& other) const {
        return x != other && y != other && z != other;
    }
    
    // other helpers
    template<typename T>
    __host__ __device__ typename std::enable_if<std::is_same<T, Vec3>::value, float>::type dot(const T& other) const {
        return x*other.x + y*other.y + z*other.z;
    }

    template<typename T>
    __host__ __device__ typename std::enable_if<std::is_same<T, Vec3>::value, Vec3>::type cross(const T& other) const {
        return Vec3(
            y*other.z - z*other.y,
            z*other.x - x*other.z,
            x*other.y - y*other.x
        );
    }

    __host__ __device__ float lengthSquared() const {
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

    __host__ __device__ friend Vec3 min(Vec3& t, Vec3& o) {
        return Vec3(fminf(t.x, o.x), fminf(t.y, o.y), fminf(t.z, o.z));
    }

    __host__ __device__ friend Vec3 max(Vec3& t, Vec3& o) {
        return Vec3(fmaxf(t.x, o.x), fmaxf(t.y, o.y), fmaxf(t.z, o.z));
    }

    __host__ __device__ Vec3 normalized() const {
        return *this * this->invLength();
    }

    __host__ __device__ Vec3 epsilonShift(const Vec3& dir) const {
        // dir should be normalised
        return *this + dir * 1e-4f;
    }
};