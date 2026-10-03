# no project() here: a nested one would only reset PROJECT_SOURCE_DIR / PROJECT_NAME

# NOTE: Also update GTEST_VERSION env var in .github/workflows/cmake.yml:31
FetchContent_Declare(
    gtest
    SYSTEM
    EXCLUDE_FROM_ALL   # build only what we link; needs CMake >= 3.28
    GIT_REPOSITORY https://github.com/google/googletest.git
    # renovate: datasource=github-tags depName=google/googletest versioning=loose
    GIT_TAG        v1.18.0
    GIT_SHALLOW    1
    GIT_PROGRESS   ON
)
set(INSTALL_GTEST OFF CACHE BOOL "" FORCE)   # build-time dep, never part of the artifacts
FetchContent_MakeAvailable(gtest)

# the MSVC STL records /fsanitize=address in the objects (#pragma detect_mismatch of
# annotate_string / annotate_vector / annotate_optional), so an un-sanitized gtest.lib fails
# to link into a sanitized tests.exe with LNK2038/LNK1319. Other toolchains allow the mix.
if(MSVC)
    foreach(gtest_target IN ITEMS gtest gtest_main gmock gmock_main)
        if(TARGET ${gtest_target})
            set_custom_stdlib_and_sanitizers(${gtest_target} true)
        endif()
    endforeach()
endif()

add_executable(${TESTS_EXECUTABLE_NAME}
    main.cpp
    exemplu_test_oop.cpp
    exemplu_test_simplu.cpp
)

target_link_libraries(${TESTS_EXECUTABLE_NAME} PRIVATE ${MAIN_PROJECT_LIB_NAME} gtest gtest_main)

set_compiler_flags(TARGET_NAMES ${TESTS_EXECUTABLE_NAME})

# one CTest entry per Google Test case, so a failure names the test that failed.
# WORKING_DIRECTORY is a keyword of this function: after PROPERTIES it would stop the
# property list and silently drop TIMEOUT.
include(GoogleTest)
gtest_discover_tests(${TESTS_EXECUTABLE_NAME}
    DISCOVERY_MODE PRE_TEST      # the build step must never run the binary
    DISCOVERY_TIMEOUT 60         # first run after linking exceeds the default 5s on Windows/ASan
    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}   # default build/tests breaks tests opening assets/
    PROPERTIES TIMEOUT 60        # a suite stuck on std::cin would eat the whole job budget
)
