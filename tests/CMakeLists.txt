cmake_minimum_required(VERSION 3.26)

project(oop-Test-Runner)
set(TEST_PROJECT ${PROJECT_NAME} PARENT_SCOPE)

FetchContent_Declare(
        gtest
        GIT_REPOSITORY https://github.com/google/googletest.git
        GIT_TAG main
)
FetchContent_MakeAvailable(gtest)

add_executable(${PROJECT_NAME}
        main.cpp
        exemplu_test_oop.cpp
        exemplu_test_simplu.cpp
)
target_link_libraries(${PROJECT_NAME} PRIVATE ${SRC_PROJECT}_lib gtest gtest_main)
include(${CMAKE_HELPER_DIR}/CompilerFlags.cmake)

install(TARGETS ${PROJECT_NAME} DESTINATION ${DESTINATION_DIR})

add_test(NAME ${PROJECT_NAME}_tests COMMAND ${PROJECT_NAME})