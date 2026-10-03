#!/usr/bin/bash

# Runs the tests CTest registered in an already configured build directory.
#
# ctest exits 0 when it finds no test at all ("No tests were found!!!"), so a build
# configured with BUILD_TESTING=OFF, a deleted gtest_discover_tests()/add_test() call and a
# project whose suites were never registered all read as green. Pass -r (CI does) to turn
# zero registered tests into an error.

BUILD_DIR=${BUILD_DIR:-build}
BUILD_TYPE=${BUILD_TYPE:-Debug}
REQUIRE_TESTS=false

while getopts ":b:c:r" opt; do
  case "${opt}" in
    b) BUILD_DIR="${OPTARG}"
    ;;
    c) BUILD_TYPE="${OPTARG}"
    ;;
    r) REQUIRE_TESTS=true
    ;;
    *) printf "Unknown option %s; available options: \n\
        -b (build dir)\n\
        -c (CMake config build type)\n\
        -r (fail when no test is registered)\n" "${opt}"
      exit 1
    ;;
  esac
done

if [[ "${REQUIRE_TESTS}" = true ]]; then
    # ctest -N lists without running; the numbering is absent when no test is registered
    if ! ctest --test-dir "${BUILD_DIR}" -C "${BUILD_TYPE}" -N | grep -q 'Test #1'; then
        echo "Error: no test is registered in ${BUILD_DIR}."
        echo "Configure with -DBUILD_TESTING=ON and register the suites"
        echo "(gtest_discover_tests / add_test). Refusing to report success."
        exit 1
    fi
fi

ctest --test-dir "${BUILD_DIR}" -C "${BUILD_TYPE}" --output-on-failure
