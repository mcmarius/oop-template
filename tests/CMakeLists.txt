project(${TESTS_PROJECT_NAME})

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

add_test(NAME ${TESTS_EXECUTABLE_NAME} COMMAND ${TESTS_PROJECT_NAME})
