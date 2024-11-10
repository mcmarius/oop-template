cmake_minimum_required(VERSION 3.26)

# NOTE: update executable name in .github/workflows/cmake.yml:25 when changing executable name in this file
# for now, the project name is used as the executable name
set(MAIN_PROJECT_NAME "oop")
set(MAIN_EXECUTABLE_NAME "${MAIN_PROJECT_NAME}")
set(MAIN_PROJECT_LIB_NAME "${MAIN_PROJECT_NAME}_lib")

set(TESTS_PROJECT_NAME "tests")
set(TESTS_EXECUTABLE_NAME "${TESTS_PROJECT_NAME}")

project(${MAIN_PROJECT_NAME})
# set(CMAKE_PROJECT_VERSION_MAJOR 0)
# set(CMAKE_PROJECT_VERSION_MINOR 0)
# set(CMAKE_PROJECT_VERSION_PATCH 1)

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

include(cmake/Options.cmake)
include(cmake/CompilerFlags.cmake)

include(cmake/CopyHelper.cmake)
set(PROJECT_ROOT "${CMAKE_CURRENT_LIST_DIR}")

# external dependencies with FetchContent
include(FetchContent)

set(FETCHCONTENT_QUIET OFF)
set(FETCHCONTENT_UPDATES_DISCONNECTED ON)

add_subdirectory(src)
if(RUN_TESTS)
    include(CTest)
    enable_testing()
    add_subdirectory(tests)
endif ()
