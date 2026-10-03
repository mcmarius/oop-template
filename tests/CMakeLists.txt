# no project() here: a nested one changes nothing about CMAKE_SOURCE_DIR and only resets
# PROJECT_SOURCE_DIR / PROJECT_NAME in this scope; the tests belong to the oop project

# NOTE: Also update GTEST_VERSION env var in .github/workflows/cmake.yml:31
# EXCLUDE_FROM_ALL: only the gtest pieces we link are built (no gmock, no install rules);
# needs CMake >= 3.28 (cmake_minimum_required in the top-level CMakeLists.txt)
FetchContent_Declare(
    gtest
    SYSTEM
    EXCLUDE_FROM_ALL
    GIT_REPOSITORY https://github.com/google/googletest.git
    # renovate: datasource=github-tags depName=google/googletest versioning=loose
    GIT_TAG        v1.18.0
    GIT_SHALLOW    1
    GIT_PROGRESS   ON
)
# googletest installs its own headers/libs unless told not to; they are a build-time
# dependency of the test binary and must never reach the artifacts
set(INSTALL_GTEST OFF CACHE BOOL "" FORCE)
FetchContent_MakeAvailable(gtest)

add_executable(${TESTS_EXECUTABLE_NAME}
    main.cpp
    exemplu_test_oop.cpp
    exemplu_test_simplu.cpp
)

target_link_libraries(${TESTS_EXECUTABLE_NAME} PRIVATE ${MAIN_PROJECT_LIB_NAME} gtest gtest_main)

set_compiler_flags(TARGET_NAMES ${TESTS_EXECUTABLE_NAME})

# one CTest entry per Google Test case, so a failure names the test that failed.
# PRE_TEST discovery lists the tests when ctest runs them instead of after the build: the
# build step must never execute the binary (cross builds, sanitizers, Windows/MSVC).
# WORKING_DIRECTORY: the default (build/tests) breaks any test opening assets/...;
# TIMEOUT: a suite spinning on EOF from std::cin would eat the whole job budget.
# WORKING_DIRECTORY is a keyword of gtest_discover_tests() itself - writing it after
# PROPERTIES makes CMake stop collecting them and the TIMEOUT is silently dropped.
include(GoogleTest)
gtest_discover_tests(${TESTS_EXECUTABLE_NAME}
    DISCOVERY_MODE PRE_TEST
    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
    PROPERTIES TIMEOUT 60
)
