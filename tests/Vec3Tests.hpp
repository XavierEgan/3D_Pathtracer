#include "tests\TestFramework.hpp"
#include "src\Math\Vec3.hpp"

/*
These tests are pretty bad tbh since they only check integers and all the values of x,y,z are the same
but like it should be fine for these simple operations

also does not check most edge cases
*/

void Vec3Tests(void) {
    TestManager testManager = TestManager();

    TEST(VecCompareOtherVec) {
        Vec3 a = Vec3(1,1,1);
        Vec3 b = Vec3(a.x+1, a.y+1, a.z+1);

        ASSERT_TRUE(a < b);
        ASSERT_TRUE(a <= b);

        ASSERT_TRUE(b > a);
        ASSERT_TRUE(b >= a);

        ASSERT_FALSE(a == b);
        ASSERT_TRUE(a == a);
        ASSERT_TRUE(a != b);
        
        // if all componenets are greater than their counterpart its true
        a = Vec3(1.5,2.5,3.5);
        b = Vec3(-.5, -1.5, -2.5);
        ASSERT_TRUE(a > b);
        ASSERT_FALSE(a < b);

        // if any single component is less than another it should be false
        a = Vec3(10, 10, 0);
        b = Vec3(9, 9, 9);

        ASSERT_FALSE(a > b);
        ASSERT_FALSE(a < b); // BOTH < and > can be false

        return true;
    };

    TEST(VecCompareArithmatic) {
        Vec3 a = Vec3(1,1,1);
        ASSERT_TRUE(a > 0);
        ASSERT_FALSE(a < 0);
        ASSERT_TRUE(a >= 0);
        ASSERT_FALSE(a <= 0);
        
        ASSERT_TRUE(a == 1);
        ASSERT_FALSE(a != 1);
        
        return true;
    };

    TEST(VectorAddition) {
        Vec3 a = Vec3(1,1,1);
        ASSERT_EQ(a + 1, Vec3(2,2,2));
        a += 1;
        ASSERT_EQ(a, Vec3(2,2,2));
        
        Vec3 b = Vec3(1,1,1);
        a = Vec3(1,1,1);
        ASSERT_EQ(a + b, Vec3(2,2,2));
        a += b;
        ASSERT_EQ(a, Vec3(2,2,2));

        return true;
    };

    TEST(VectorSubtraction) {
        Vec3 a = Vec3(1,1,1);
        ASSERT_EQ(a - 1, Vec3(0,0,0));
        a -= 1;
        ASSERT_EQ(a, Vec3(0,0,0));
        
        Vec3 b = Vec3(1,1,1);
        a = Vec3(1,1,1);
        ASSERT_EQ(a - b, Vec3(0,0,0));
        a -= b;
        ASSERT_EQ(a, Vec3(0,0,0));

        a = Vec3(1,1,1);
        b = Vec3(1,1,1);

        a += -b;
        ASSERT_EQ(a, Vec3(0,0,0));

        return true;
    };

    TEST(VectorMultiplication) {
        Vec3 a = Vec3(2,2,2);
        ASSERT_EQ(a * 2, Vec3(4,4,4));
        a *= 2;
        ASSERT_EQ(a, Vec3(4,4,4));
        
        Vec3 b = Vec3(2,2,2);
        a = Vec3(2,2,2);
        ASSERT_EQ(a * b, Vec3(4,4,4));
        a *= b;
        ASSERT_EQ(a, Vec3(4,4,4));

        return true;
    };

    TEST(VectorDivision) {
        Vec3 a = Vec3(2,2,2);
        ASSERT_EQ(a / 2, Vec3(1,1,1));
        a /= 2;
        ASSERT_EQ(a, Vec3(1,1,1));
        
        Vec3 b = Vec3(2,2,2);
        a = Vec3(2,2,2);
        ASSERT_EQ(a / b, Vec3(1,1,1));
        a /= b;
        ASSERT_EQ(a, Vec3(1,1,1));

        return true;
    };

    TEST(VectorLengthSquared) {
        Vec3 a = Vec3(1,2,3);
        ASSERT_EQ(a.lengthSquared(), 14);
        return true;
    };

    TEST(VectorLength) {
        Vec3 a = Vec3(1,2,3);
        ASSERT_CLOSE(a.length(), 3.741657f);

        return true;
    };

    TEST(VectorDot) {
        Vec3 a = Vec3(1,2,3);
        Vec3 b = Vec3(4,5,6);
        ASSERT_EQ(a.dot(b), 32);

        return true;
    };

    TEST(VectorCross) {
        Vec3 a = Vec3(1,2,3);
        Vec3 b = Vec3(4,5,6);

        ASSERT_EQ(a.cross(b), Vec3(-3, 6, -3));

        return true;
    };

    testManager.runTests();
}