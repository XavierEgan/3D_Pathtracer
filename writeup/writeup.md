# 3d Raytracer
## Section 1 - what are meshs?
A mesh in 3d graphics is a collection of triangles, where a triangle is a collection of 3 verticies, which are each 3 doubles representing the verts x, y and z location in 3d space.

### Möller–Trumbore intersection
In order to determine if our ray has hit a triangle, we can use the Möller–Trumbore ray intersection algorithm. [learn more](https://en.wikipedia.org/wiki/M%C3%B6ller%E2%80%93Trumbore_intersection_algorithm#External_links).

My implimentation (very closely following wikipedias implimentation), shown below, takes in a ray and a triangle and returns 1 or 0 depending on if there was an intercept. It also takes in a pointer to a Vec3 and modifies it with the location of the intercept. We need to know where the intercept is for later when we do ray tracing.
```C
int ray_triangle_intercept(Vec3 ray, Vec3 ray_origin, Tri tri, Vec3* int_pos) {
    ray = vec_normalise(ray);

    Vec3 e1 = vec_sub(tri.b, tri.a);
    Vec3 e2 = vec_sub(tri.c, tri.a);
    Vec3 rxe2 = vec_cross(ray, e2);
    float det = vec_dot(e1, rxe2);

    if (det > -epsilon && det < epsilon) {
        return 0; // no intercept
    }

    float inv_det = 1.0/det;
    Vec3 s = vec_sub(ray_origin, tri.a);
    float u = inv_det * vec_dot(s, rxe2);

    if (u < 0.0 || u > 1.0) { // modified from the wiki to be stricter and more efficient saving a couple checks
        return 0; // no intercept
    }

    Vec3 sxe1 = vec_cross(s, e1);
    float v = inv_det * vec_dot(ray, sxe1);

    if (v < 0.0 || u + v > 1.0) {
        return 0; // no intercept
    }

    float t = inv_det * vec_dot(e2, sxe1);

    if (t > epsilon) {
        *int_pos = vec_add(ray_origin, vec_scale(ray, t));
        return 1; // intercept
    } else {
        return 0; // no intercept
    }
}
```

