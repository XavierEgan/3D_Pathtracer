#pragma once

/*  
    Written by Xavier Egan 2025
*/

#include <functional>
#include <vector>
#include <iostream>
#include <string>
#include <cmath>

struct TestStruct {
    std::function<bool()>* func;
    std::string name;

    TestStruct(std::function<bool()>* func, std::string name) : func(func), name(name) {}
};

struct TestManager {
    std::vector<TestStruct> tests;
    TestManager() {
        tests = std::vector<TestStruct>();
    }

    void registerTest(TestStruct test) {
        tests.push_back(test);
    }

    void runTests() {
        for (size_t i=0; i<tests.size(); i++) {
            std::cout << "TEST " << tests.at(i).name << ": ";
            try {
                if ((*tests.at(i).func)()) { // dereference the function pointer and call it 
                    // test passed
                    std::cout << "PASSED" << "\n";
                } else {
                    // test failed
                    std::cout << "FAILED - bool" << "\n";
                }
            } catch (std::exception& e) {
                // test failed
                std::cout << "FAILED - error {" << e.what() << "}" << "\n";
            }
        }
    }
};

#define TEST(testName) std::function<bool()> testName; testManager.registerTest(TestStruct(&testName, #testName)); testName = []() -> bool

#define ASSERT_TRUE(condition) if (!(condition)) throw std::runtime_error("Assert True failed: " #condition)

#define ASSERT_FALSE(condition) if (condition) throw std::runtime_error("Assert False failed: " #condition)

#define ASSERT_EQ(actual, expected) if ((expected) != (actual)) throw std::runtime_error("Assertion failed: " #expected #actual)

#define ASSERT_CLOSE(actual, expected) if (!((expected - actual) >= -1e-4f && (expected - actual) <= 1e-4f)) throw std::runtime_error("Assertion failed: " #expected #actual)