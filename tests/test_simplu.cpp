#define BOOST_UT_DISABLE_MODULE
#include <ut.hpp>

int sum(const int a, const int b) {
    return a+b;
}

int main() {
    using namespace boost::ut;

    // cppcheck-suppress knownConditionTrueFalse
    "sum of positive numbers"_test = [] {
        expect(sum(2, 3) == 5_i);
    };

    // cppcheck-suppress knownConditionTrueFalse
    "sum with zero"_test = [] {
        expect(sum(5, 0) == 5_i);
    };

    // cppcheck-suppress knownConditionTrueFalse
    "sum of negative numbers"_test = [] {
        expect(sum(-2, -3) == -5_i);
    };

    return 0;
}