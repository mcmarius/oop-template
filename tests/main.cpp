#include <ut.hpp>

extern boost::ut::suite<"simplu"> simplu_test_suite;
extern boost::ut::suite<"oop"> oop_test_suite;

// CLI args required by ut and ctest for registration and filtering
int main(int argc, char** argv) {
    boost::ut::run_cfg rc{};
    rc.report_errors = true;
    rc.argc = argc;
    rc.argv = const_cast<const char**>(argv);

    // older compilers reject a designated initializer here:
    // cfg<>.run({.report_errors = true, .argc = argc, .argv = argv})
    return boost::ut::cfg<>.run(rc) ? 1 : 0;
}
