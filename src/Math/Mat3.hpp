#pragma once

#include <iostream>
#include <cmath>
#include <array>

#include "Vec3.hpp"

struct Mat3 {
    std::array<float, 9> data;

    // constructors
    Mat3() : data({}) {}
    Mat3(float fill) : data({fill, fill, fill, fill, fill, fill, fill, fill, fill}) {}
    Mat3(float m00, float m01, float m02,float m10, float m11, float m12,float m20, float m21, float m22) 
    : data({m00, m01, m02, m10, m11, m12, m20, m21, m22}) {}

    // overloads
    // access overloads
    float& operator()(int row, int col) {
        return data[row*3 + col];
    }
    const float operator()(int row, int col) const {
        return data[row*3 + col];
    }
    
    // + overloads
    Mat3 operator+(const Mat3& other) const {
        return Mat3(
            (*this)(0,0) + other(0,0), (*this)(0,1) + other(0,1), (*this)(0,2) + other(0,2),
            (*this)(1,0) + other(1,0), (*this)(1,1) + other(1,1), (*this)(1,2) + other(1,2),
            (*this)(2,0) + other(2,0), (*this)(2,1) + other(2,1), (*this)(2,2) + other(2,2)
        );
    }

    // - overloads
    Mat3 operator-(const Mat3& other) const {
        return Mat3(
            (*this)(0,0) - other(0,0), (*this)(0,1) - other(0,1), (*this)(0,2) - other(0,2),
            (*this)(1,0) - other(1,0), (*this)(1,1) - other(1,1), (*this)(1,2) - other(1,2),
            (*this)(2,0) - other(2,0), (*this)(2,1) - other(2,1), (*this)(2,2) - other(2,2)
        );
    }

    // * overloads
    Mat3 operator*(const Mat3& other) const {
        return Mat3(
            // Row 0
            (*this)(0,0)*other(0,0) + (*this)(1,0)*other(0,1) + (*this)(2,0)*other(0,2),  // (0,0)
            (*this)(0,0)*other(1,0) + (*this)(1,0)*other(1,1) + (*this)(2,0)*other(1,2),  // (0,1)
            (*this)(0,0)*other(2,0) + (*this)(1,0)*other(2,1) + (*this)(2,0)*other(2,2),  // (0,2)
            
            // Row 1
            (*this)(0,1)*other(0,0) + (*this)(1,1)*other(0,1) + (*this)(2,1)*other(0,2),  // (1,0)
            (*this)(0,1)*other(1,0) + (*this)(1,1)*other(1,1) + (*this)(2,1)*other(1,2),  // (1,1)
            (*this)(0,1)*other(2,0) + (*this)(1,1)*other(2,1) + (*this)(2,1)*other(2,2),  // (1,2)
            
            // Row 2
            (*this)(0,2)*other(0,0) + (*this)(1,2)*other(0,1) + (*this)(2,2)*other(0,2),  // (2,0)
            (*this)(0,2)*other(1,0) + (*this)(1,2)*other(1,1) + (*this)(2,2)*other(1,2),  // (2,1)
            (*this)(0,2)*other(2,0) + (*this)(1,2)*other(2,1) + (*this)(2,2)*other(2,2)   // (2,2)
        );
    }
    Vec3 operator*(const Vec3& vec) {
        return Vec3(
            (*this)(0,0)*vec.x + (*this)(0,1)*vec.y + (*this)(0,2)*vec.z,
            (*this)(1,0)*vec.x + (*this)(1,1)*vec.y + (*this)(1,2)*vec.z,
            (*this)(2,0)*vec.x + (*this)(2,1)*vec.y + (*this)(2,2)*vec.z
        );
    }
    friend Vec3 operator*(const Vec3& vec, const Mat3& mat) {
        return Vec3(
            mat(0,0)*vec.x + mat(1,0)*vec.y + mat(2,0)*vec.z,
            mat(0,1)*vec.x + mat(1,1)*vec.y + mat(2,1)*vec.z,
            mat(0,2)*vec.x + mat(1,2)*vec.y + mat(2,2)*vec.z
        );
    }
    Mat3 operator*(const float scale) const {
        return Mat3(
            (*this)(0,0)*scale, (*this)(1,0)*scale, (*this)(2,0)*scale,
            (*this)(0,1)*scale, (*this)(1,1)*scale, (*this)(2,1)*scale,
            (*this)(0,2)*scale, (*this)(1,2)*scale, (*this)(2,2)*scale
        );
    }
    friend Mat3 operator*(const float scale, const Mat3& other) {
        return Mat3(
            other(0,0)*scale, other(1,0)*scale, other(2,0)*scale,
            other(0,1)*scale, other(1,1)*scale, other(2,1)*scale,
            other(0,2)*scale, other(1,2)*scale, other(2,2)*scale
        );
    }

    // other needed funcs
    float det() const {
        return ((*this)(0,0) * ((*this)(1,1) * (*this)(2,2) - (*this)(1,2) * (*this)(2,1))) -
            ((*this)(0,1) * ((*this)(1,0) * (*this)(2,2) - (*this)(1,2) * (*this)(2,0))) +
            ((*this)(0,2) * ((*this)(1,0) * (*this)(2,1) - (*this)(1,1) * (*this)(2,0)));
    }

    Mat3 adjoint() const {
        return (
            Mat3(
                // Row 0
                (*this)(1,1) * (*this)(2,2) - (*this)(1,2) * (*this)(2,1),
                (*this)(0,2) * (*this)(2,1) - (*this)(0,1) * (*this)(2,2),
                (*this)(0,1) * (*this)(1,2) - (*this)(0,2) * (*this)(1,1),
                
                // Row 1
                (*this)(1,2) * (*this)(2,0) - (*this)(1,0) * (*this)(2,2),
                (*this)(0,0) * (*this)(2,2) - (*this)(0,2) * (*this)(2,0),
                (*this)(0,2) * (*this)(1,0) - (*this)(0,0) * (*this)(1,2),
                
                // Row 2
                (*this)(1,0) * (*this)(2,1) - (*this)(1,1) * (*this)(2,0),
                (*this)(0,1) * (*this)(2,0) - (*this)(0,0) * (*this)(2,1),
                (*this)(0,0) * (*this)(1,1) - (*this)(0,1) * (*this)(1,0)
            )
        );
    }

    Mat3 inverse() const {
        return (*this).adjoint() * (1.0f/(*this).det());
    }

    Mat3 transpose() const {
        return Mat3 {
            (*this)(0,0), (*this)(0,1), (*this)(0,2), 
            (*this)(1,0), (*this)(1,1), (*this)(1,2), 
            (*this)(2,0), (*this)(2,1), (*this)(2,2)
        };
    }

    friend std::ostream& operator<<(std::ostream& os, const Mat3& mat) {
        os << "((" 
        << mat(0,0) << ", " << mat(1,0) << ", " << mat(2,0) << ")\n(" 
        << mat(0,1) << ", " << mat(1,1) << ", " << mat(2,1) << ")\n(" 
        << mat(0,2) << ", " << mat(1,2) << ", " << mat(2,2) << "))";
        return os;
    }
};