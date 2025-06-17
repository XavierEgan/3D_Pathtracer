#include "TestFramework.hpp"
#include "../src/Math/Ray.hpp"

/*
These tests are pretty bad tbh since they only check integers and all the values of x,y,z are the same
but like it should be fine for these simple operations

also does not check most edge cases
*/

void RayTests(void) {
    TestManager testManager = TestManager();

    TEST(BasicTriangleIntersection) {
        Ray ray = Ray(Vec3(1, 0, 0), Vec3(-1, 0, 0));
        Tri tri = Tri(Vec3(0, -1, 1), Vec3(0, 1, -1), Vec3(0, -1, -1), 0);
        ASSERT_TRUE(ray.rayTriIntercept(tri).has_value()); // should be barely touching the edge

        tri = Tri(Vec3(0, -1, 1.1), Vec3(0, 1.1, -1), Vec3(0, -1, -1), 0); // should be just inside
        ASSERT_TRUE(ray.rayTriIntercept(tri).has_value());

        tri = Tri(Vec3(0, -1, .9), Vec3(0, .9, -1), Vec3(0, -1, -1), 0); // should be just outside
        ASSERT_FALSE(ray.rayTriIntercept(tri).has_value());

        return true;
    };

    TEST(RayTriIntersectionRayHit) {
        Ray ray = Ray(Vec3(1, 0, 0), Vec3(-1, 0, 0));
        Tri tri = Tri(Vec3(0, -1, 1), Vec3(0, 1, -1), Vec3(0, -1, -1), 0);
        RayHit hit = ray.rayTriIntercept(tri).value();

        ASSERT_CLOSE(hit.baryCoords, Vec3(.5, .5, 0)); // should be on the edge
        ASSERT_CLOSE(hit.dist, 1);
        ASSERT_CLOSE(hit.intersecPoint, Vec3(0, 0, 0));

        return true;
    };

    testManager.runTests();
}