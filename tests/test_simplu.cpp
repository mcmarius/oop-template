#include <ut.hpp>

int sum(const int a, const int b) {
    return a + b;
}

boost::ut::suite simplu_test_suite = [] {
    using namespace boost::ut;

    "sum of positive numbers"_test = [] {
        // cppcheck-suppress knownConditionTrueFalse
        expect(sum(2, 3) == 5_i);
    };

    "sum with zero"_test = [] {
        // cppcheck-suppress knownConditionTrueFalse
        expect(sum(5, 0) == 5_i);
    };

    "sum of negative numbers"_test = [] {
        // cppcheck-suppress knownConditionTrueFalse
        expect(sum(-2, -3) == -5_i);
    };
};
