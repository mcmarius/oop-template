#include <stdexcept>

#include <ut.hpp>

#include "Example.h"      // the library under test; include/ comes from oop

static_assert(Example::limit > 0, "the invariant below assumes a positive limit");

// Test simplu, fără fixture (suite cu state: test_oop.cpp); doar interfața publică,
// helper-ul din spatele invariantului e file-local în src/Example.cpp
boost::ut::suite<"simplu"> simplu_test_suite = [] {
    using namespace boost::ut;

    "StartedFromZero"_test = [] {
        const Example e;
        expect(e.value() == 0_i);
    };

    "AddChangesTheValue"_test = [] {
        Example e;

        e.add(7);
        expect(e.value() == 7_i);

        e.add(-7);
        expect(e.value() == 0_i);
    };

    "AddRefusesToGoBelowZero"_test = [] {
        Example e;

        expect(throws<std::invalid_argument>([&] { e.add(-1); }));
        expect(e.value() == 0_i) << "un apel eșuat lasă obiectul neschimbat";
    };

    "AddRefusesToGoAboveLimit"_test = [] {
        Example e;

        expect(throws<std::invalid_argument>([&] { e.add(Example::limit + 1); }));
        expect(e.value() == 0_i) << "un apel eșuat lasă obiectul neschimbat";
    };

    "ConstructorRefusesABrokenObject"_test = [] {
        expect(throws<std::invalid_argument>([] { Example broken{-1}; (void) broken; }));
        expect(throws<std::invalid_argument>([] { Example broken{Example::limit + 1}; (void) broken; }));
    };
};
