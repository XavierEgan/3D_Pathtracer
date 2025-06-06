#ifndef VEC3_H
#define VEC3_H

#define PI 3.14159265359f

typedef struct {
    float x;
    float y;
    float z;
} Vec3;

Vec3 vec_init(float x, float y, float z);

Vec3 vec_from_spherical(float pitch, float yaw);

Vec3 vec_add(Vec3 a, Vec3 b);

Vec3 vec_sub(Vec3 a, Vec3 b);

Vec3 vec_mult(Vec3 a, Vec3 b);

Vec3 vec_scale(Vec3 a, float scale);

Vec3 vec_cross(Vec3 a, Vec3 b);

Vec3 vec_normalise(Vec3 a);

Vec3 vec_proj(Vec3 on, Vec3 vec);

Vec3 vec_oproj(Vec3 on, Vec3 vec);

float vec_dot(Vec3 a, Vec3 b);

float vec_len(Vec3 a);

double dist_bet_points(Vec3 p1, Vec3 p2);

Vec3 reflect_ray(Vec3 ray, Vec3 norm);

Vec3 epsilon_shift(Vec3 point, Vec3 dir);

#endif