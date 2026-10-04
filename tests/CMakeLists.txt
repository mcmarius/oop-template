# no project(): nested projects reset PROJECT_SOURCE_DIR / PROJECT_NAME

# NOTE: Also update GTEST_VERSION env var in .github/workflows/cmake.yml
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
set(INSTALL_GTEST OFF CACHE BOOL "" FORCE)   # build-time dep, skip artifacts

# static even with -DBUILD_SHARED_LIBS=ON: oop_test ships in bin/ without gtest
# dylibs/DLLs next to it, so a shared gtest dies at startup (no LC_RPATH's found)
set(BUILD_SHARED_LIBS OFF)

FetchContent_MakeAvailable(gtest)

# MSVC does not allow mixing instrumented and uninstrumented code
if(MSVC)
    foreach(gtest_target IN ITEMS gtest gtest_main gmock gmock_main)
        if(TARGET ${gtest_target})
            set_custom_stdlib_and_sanitizers(${gtest_target} ${USE_ASAN})
        endif()
    endforeach()
endif()

add_executable(${TESTS_EXECUTABLE_NAME}
    main.cpp
    exemplu_test_oop.cpp
    exemplu_test_simplu.cpp
)

target_link_libraries(${TESTS_EXECUTABLE_NAME} PRIVATE ${MAIN_LIBRARY_NAME} gtest gtest_main)

set_compiler_flags(RUN_SANITIZERS ${USE_ASAN} TARGET_NAMES ${TESTS_EXECUTABLE_NAME})

register_tests(${TESTS_EXECUTABLE_NAME}
    LIST_ARGS   "--gtest_list_tests"
    SELECT_ARG  "--gtest_also_run_disabled_tests" "--gtest_filter=<name>"
    PROPERTIES  SKIP_REGULAR_EXPRESSION "\\[  SKIPPED \\]"
)

install(TARGETS ${TESTS_EXECUTABLE_NAME} DESTINATION ${DESTINATION_DIR})
