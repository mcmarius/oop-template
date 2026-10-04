#include "Example.h"

#include <iostream>
#include <stdexcept>

#include "internal/Detail.h"   // not visible to app/ and tests/

namespace {
// no header declares this, so it is tested through the public interface, never directly
bool allowed(int value) {
    return value >= 0 && value <= Example::limit;
}
} // namespace

Example::Example(int initial) {
    if (!allowed(initial)) {
        throw std::invalid_argument("Example: initial value must be in [0, limit]");
    }
    value_ = initial;
}

int Example::value() const {
    return value_;
}

void Example::add(int delta) {
    const int next = value_ + delta;
    if (!allowed(next)) {
        throw std::invalid_argument("Example::add: the value must stay in [0, limit]");
    }
    value_ = next;
}

void Example::g() const {
    Detail d;
    d.g();
    std::cout << "value: " << value_ << "\n";
}
