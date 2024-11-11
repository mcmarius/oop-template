# no project(): nested projects reset PROJECT_SOURCE_DIR / PROJECT_NAME

add_executable(${TESTS_EXECUTABLE_NAME}
    main.cpp
    test_oop.cpp
    test_simplu.cpp
)

# target_link_libraries(${TESTS_EXECUTABLE_NAME} PRIVATE ${MAIN_LIBRARY_NAME})
target_link_libraries(${TESTS_EXECUTABLE_NAME} PRIVATE ${MAIN_LIBRARY_NO_SAN_NAME})

# header only dependency; SYSTEM so cppcheck and clang-tidy do not report warnings from it
target_include_directories(${TESTS_EXECUTABLE_NAME} SYSTEM PRIVATE ${CMAKE_SOURCE_DIR}/ext/include/boost)

# tests do not work with sanitizers on msvc
set_compiler_flags(RUN_SANITIZERS FALSE TARGET_NAMES ${TESTS_EXECUTABLE_NAME})

# one CTest test per test case, see cmake/RegisterTests.cmake
#
# ut lists its cases with --list-test-names-only and runs a single one when it is
# given the case name, but that name is matched as a pattern where * ? ! . and \
# are wildcards, so those characters are replaced with "?" (any single character)
register_tests(${TESTS_EXECUTABLE_NAME}
    LIST_ARGS   "--list-test-names-only"
    LIST_NOISE  "UT starts [=]*|^Completed.*"
    SELECT_ARG  "<name>"
    NAME_ESCAPE ".*?!\\"
)

install(TARGETS ${TESTS_EXECUTABLE_NAME} DESTINATION ${DESTINATION_DIR})
