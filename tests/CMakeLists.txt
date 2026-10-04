# no project(): nested projects reset PROJECT_SOURCE_DIR / PROJECT_NAME

# no test framework here: plain assert / static_assert, see tests/README.md
# framework examples: the branches tests/gtest (googletest) and tests/Boost-ext-ut

add_executable(${TESTS_EXECUTABLE_NAME}
    exemplu_test.cpp
)

# the library is compiled once (by the oop target) and linked a second time here
target_link_libraries(${TESTS_EXECUTABLE_NAME} PRIVATE ${MAIN_LIBRARY_NAME})

# the same flags as the library and the app: MSVC refuses to link instrumented
# and uninstrumented code, clang on macOS must not mix libc++ with libstdc++
set_compiler_flags(RUN_SANITIZERS ${USE_ASAN} TARGET_NAMES ${TESTS_EXECUTABLE_NAME})

# one CTest entry for the whole executable, see cmake/RegisterTests.cmake
# (nothing can list individual cases here; WORKING_DIRECTORY and TIMEOUT default)
register_tests(${TESTS_EXECUTABLE_NAME})

# shipped with the app (the zip top level), so the tests of a download bundle can
# be run in any environment, without the build directory
install(TARGETS ${TESTS_EXECUTABLE_NAME} DESTINATION ${DESTINATION_DIR})
