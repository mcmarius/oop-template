// Main ships no test framework on purpose: plain assert / static_assert only.
// Full framework examples live on tests/gtest and tests/Boost-ext-ut branches.

// assert() disappears when NDEBUG is defined (Release, RelWithDebInfo): the
// binary would exit 0 having checked nothing, and CI would call that a pass.
// Keep the checks on in every build type.
#undef NDEBUG
#include <cassert>
#include <type_traits>

#include "Example.h"      // the library under test; include/ comes from oop

// a check the compiler makes, in every build type
static_assert(std::is_default_constructible_v<Example>, "app/ and tests/ do Example e;");

// Replace this with your own classes from src/. The example library only prints
// to std::cout, so there is no state here to assert on yet.
int sum(int a, int b) {
    return a + b;
}

int main() {
    assert(sum(2, 3) == 5);
    assert(sum(-2, -3) == -5);
    return 0;
}
