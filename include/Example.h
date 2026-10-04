#ifndef EXAMPLE_H
#define EXAMPLE_H

// What is declared here is what app/ and tests/ can reach; helpers that do not need
// to be public stay in the .cpp or in src/internal/.
class Example {
public:
    static constexpr int limit = 100;         // the invariant: value_ is in [0, limit]

    explicit Example(int initial = 0);        // throws std::invalid_argument if broken
    void add(int delta);                      // throws, leaving the object untouched
    int value() const;                        // the only observer, what tests assert on
    void g() const;                           // display

private:
    int value_ = 0;
};

#endif // EXAMPLE_H
