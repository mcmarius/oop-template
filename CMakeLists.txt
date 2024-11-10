cmake_minimum_required(VERSION 3.26)

# NOTE: update executable name in .github/workflows/cmake.yml:25 when changing executable name in this file
# for now, the project name is used as the executable name
set(MAIN_PROJECT_NAME "oop")
set(MAIN_EXECUTABLE_NAME "${MAIN_PROJECT_NAME}")


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
set(CMAKE_HELPER_DIR "${PROJECT_ROOT}/cmake")

include(${CMAKE_HELPER_DIR}/Options.cmake)
include(${CMAKE_HELPER_DIR}/CopyHelper.cmake)

# external dependencies with FetchContent
include(FetchContent)

set(FETCHCONTENT_QUIET OFF)
set(FETCHCONTENT_UPDATES_DISCONNECTED ON)

option(BUILD_TESTS "Build the test suites" OFF)

add_subdirectory(src)
if(BUILD_TESTS)
    add_subdirectory(tests)
endif ()