#include <stdexcept>

#include <gtest/gtest.h>

#include "Example.h"      // the library under test; include/ comes from oop

static_assert(Example::limit > 0, "the invariant below assumes a positive limit");

// TEST simplu, fără fixture (TEST_F: exemplu_test_oop.cpp); doar interfața publică

TEST(ExampleTest, StartedFromZero) {
    Example e;
    EXPECT_EQ(e.value(), 0);
}

TEST(ExampleTest, AddChangesTheValue) {
    Example e;

    e.add(7);
    EXPECT_EQ(e.value(), 7);

    e.add(-7);
    EXPECT_EQ(e.value(), 0);
}

TEST(ExampleTest, AddRefusesToGoBelowZero) {
    Example e;

    EXPECT_THROW(e.add(-1), std::invalid_argument);
    EXPECT_EQ(e.value(), 0) << "un apel eșuat lasă obiectul neschimbat";
}

TEST(ExampleTest, AddRefusesToGoAboveLimit) {
    Example e;

    EXPECT_THROW(e.add(Example::limit + 1), std::invalid_argument);
    EXPECT_EQ(e.value(), 0) << "un apel eșuat lasă obiectul neschimbat";
}

TEST(ExampleTest, ConstructorRefusesABrokenObject) {
    EXPECT_THROW(Example{-1}, std::invalid_argument);
    EXPECT_THROW(Example{Example::limit + 1}, std::invalid_argument);
}
