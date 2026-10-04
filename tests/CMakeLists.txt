# no project(): nested projects reset PROJECT_SOURCE_DIR / PROJECT_NAME

add_executable(${TESTS_EXECUTABLE_NAME}
    exemplu_test.cpp
)

target_link_libraries(${TESTS_EXECUTABLE_NAME} PRIVATE ${MAIN_LIBRARY_NAME})

# same flags as lib and app: MSVC refuses mixing instrumented and uninstrumented code
set_compiler_flags(RUN_SANITIZERS ${USE_ASAN} TARGET_NAMES ${TESTS_EXECUTABLE_NAME})

# one CTest entry for the whole executable
register_tests(${TESTS_EXECUTABLE_NAME})

install(TARGETS ${TESTS_EXECUTABLE_NAME} DESTINATION ${DESTINATION_DIR})
