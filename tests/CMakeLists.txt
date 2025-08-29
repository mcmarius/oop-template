project(${TESTS_PROJECT_NAME})

# NOTE: Also update GTEST_VERSION env var in .github/workflows/cmake.yml:31
FetchContent_Declare(
        gtest
        GIT_REPOSITORY https://github.com/google/googletest.git
        # renovate: datasource=github-tags depName=google/googletest versioning=loose
        GIT_TAG v1.17.0
)
FetchContent_MakeAvailable(gtest)

add_executable(${TESTS_EXECUTABLE_NAME}
        main.cpp
        exemplu_test_oop.cpp
        exemplu_test_simplu.cpp
)

target_link_libraries(${TESTS_EXECUTABLE_NAME} PRIVATE ${MAIN_PROJECT_LIB_NAME} gtest gtest_main)

set_compiler_flags(TARGET_NAMES ${TESTS_EXECUTABLE_NAME})

add_test(NAME ${TESTS_EXECUTABLE_NAME} COMMAND ${TESTS_PROJECT_NAME})