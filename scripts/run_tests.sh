#!/usr/bin/bash

# Runs the tests CTest registered in an already configured build directory.
# ctest exits 0 when it finds no test at all ("No tests were found!!!"), so -r (CI uses it)
# is what turns "zero registered tests" into a failure.

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
    # PRE_TEST discovery runs the test binary to produce the list, so an empty listing means
    # either "nothing registered" or "the binary will not start"; report them apart
    list_output="$(ctest --test-dir "${BUILD_DIR}" -C "${BUILD_TYPE}" -N 2>&1)"
    list_rc=$?
    if ! printf '%s' "${list_output}" | grep -q 'Test #1'; then
        printf '%s\n' "${list_output}"
        if [[ "${list_rc}" -ne 0 ]]; then
            echo "Error: ctest could not list the tests of ${BUILD_DIR} (rc=${list_rc})."
            echo "Discovery runs the test binary; a crash there (runtime library missing next"
            echo "to it, wrong architecture) looks exactly like this."
        else
            echo "Error: no test is registered in ${BUILD_DIR}."
            echo "Configure with -DBUILD_TESTING=ON and register the suites"
            echo "(gtest_discover_tests / add_test). Refusing to report success."
        fi
        exit 1
    fi
fi

ctest --test-dir "${BUILD_DIR}" -C "${BUILD_TYPE}" --output-on-failure
