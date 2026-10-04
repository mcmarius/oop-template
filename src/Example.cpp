#include <iostream>
// include/ and src/ are both on this target's include path, no `../` is needed
#include "Example.h"
#include "internal/Detail.h"   // implementation-only, not installed, not visible to app/

void Example::f() const {
    std::cout << "private function f: " << x << "\n";
}

void Example::g() {
    ++y;
    f();
    Detail d;
    d.g();          // allowed here; app/ cannot see internal/Detail.h
    std::cout << "public function g: " << y << "\n";
}
