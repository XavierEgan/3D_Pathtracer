#include "TestFramework.hpp"
#include "src/Math/Vec3.hpp"
#include "src/Math/Tri.hpp"

/*
These tests are pretty bad tbh since they only check integers and all the values of x,y,z are the same
but like it should be fine for these simple operations

also does not check most edge cases
*/

void TriTests(void) {
    TestManager testManager = TestManager();

    TEST(GetUVCoordsFromBarycentricCoords) {
        Tri tri = Tri(
            Vec3(),
            Vec3(),
            Vec3(),
            Vec3(1, 0, 0),
            Vec3(0, 1, 0),
            Vec3(0, 0, 1),
            0
        );

        Vec3 baryCoords = Vec3(1,1,1) / 3; // 1/3 is the middle
        ASSERT_CLOSE(tri.getUV(baryCoords), Vec3(1, 1, 1)/3);

        tri = Tri(
            Vec3(),
            Vec3(),
            Vec3(),
            Vec3(0, 0, 0),
            Vec3(0, .5, .5),
            Vec3(0, 0, .5),
            0
        );
        ASSERT_CLOSE(tri.getUV(baryCoords), Vec3(0, .5, 1)/3);

        baryCoords = Vec3(0,1,1) / 2; // 0, 1/2, 1/2 is the edge
        ASSERT_CLOSE(tri.getUV(baryCoords), Vec3(0, .25, .5));

        return true;
    };

    testManager.runTests();
}