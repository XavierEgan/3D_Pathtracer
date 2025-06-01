#pragma once

#include "Mat3.hpp"
#include "Vec3.hpp"

// Transform3D takes a point from local space and returns the equiv in global space
// Transform3D uses ROW MAJOR ORDER. So EACH ROW in the basis matrix is a basis vector
/*  NOTES:
        Basics
            The basis matrix defines the basis vectors i, j and k in super-space of the transform, with each row being a basis vector.
                So if this is a local transform in global space, then pos and basis is just defined using global i, j and k vectors
        
        Transforming Points
            Pg = Pl * T.b + T.p
                Pg = global point
                Pl = local point
                this transforms a point Pl from local space to global space

        Combining Transforms
            TN = T1 * T2
                This is essentially trying to unwrap T1 (defined in terms of T2 space) into global space, which means we can take a point in T1 local space and transform it straight into global space
                Just pretend that instead of T1 being defined in terms of global i, j and k, its defined using T2 i, j and k
                T1 = sublocal space (transform in T2 space) 
                T2 = local space (transform in global space (or another transform))
                which gives us the formula:
                    TN.b = T1.b * T2.b (transform each of the T1 basis vectors into T2 space)
                    TN.p = (T1.p*T2.b) + T2.p (T1.p is in T2 local space, and we want TN.p in global space, so first get T1.p in global space by using T2.b then add T2.p)
        
        Inverse
            Basis vectors must be orthonormal (Orthogonal/perpendicular and normalized)
            
        Affine Inverse
            Basis vectors can be anything lmao
            
*/
struct Transform3D {
    Mat3 basis;
    Vec3 pos;

    // constructors
    Transform3D() : basis({1.0f, 0.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 0.0f, 1.0f}), pos(Vec3()) {}
    Transform3D(Mat3 basis, Vec3 pos) : basis(basis), pos(pos) {}

    // overrides
    // * overrides
    Transform3D operator*(const Transform3D other) const {
        return Transform3D(basis * other.basis, pos + other.pos);
    }
    Vec3 operator*(const Vec3 other) const {
        // returns the local point in global space
        return other * basis + pos;
    }
    Transform3D inverse() const {
        
    }
    Transform3D affine_inverse() const {
        
    }
};
