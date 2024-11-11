#include <ut.hpp>

int sum(const int a, const int b) {
    return a+b;
}

int main() {
    using namespace boost::ut;

    "sum of positive numbers"_test = [] {
        expect(sum(2, 3) == 5_i);
    };

    "sum with zero"_test = [] {
        expect(sum(5, 0) == 5_i);
    };

    "sum of negative numbers"_test = [] {
        expect(sum(-2, -3) == -5_i);
    };

    return 0;
}