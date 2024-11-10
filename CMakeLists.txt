cmake_minimum_required(VERSION 3.28)

# NOTE: update EXECUTABLE_NAME in .github/workflows/cmake.yml when changing executable name in this file
# for now, the project name is used as the executable name
set(MAIN_PROJECT_NAME "oop")
set(MAIN_EXECUTABLE_NAME "${MAIN_PROJECT_NAME}_main")
set(MAIN_LIBRARY_NAME "${MAIN_PROJECT_NAME}")

set(TESTS_PROJECT_NAME "tests")
set(TESTS_EXECUTABLE_NAME "${MAIN_PROJECT_NAME}_test")

project(${MAIN_PROJECT_NAME})
# set(CMAKE_PROJECT_VERSION_MAJOR 0)
# set(CMAKE_PROJECT_VERSION_MINOR 0)
# set(CMAKE_PROJECT_VERSION_PATCH 1)

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_CXX_SCAN_FOR_MODULES OFF)

include(cmake/Options.cmake)
include(cmake/CompilerFlags.cmake)
include(cmake/CopyHelper.cmake)

include(cmake/RegisterTests.cmake)

###############################################################################

# External dependencies with FetchContent

# enabled here so both src and tests benefit from it
include(FetchContent)

set(FETCHCONTENT_QUIET OFF CACHE INTERNAL "Override verbose output" FORCE)
set(FETCHCONTENT_UPDATES_DISCONNECTED ON CACHE INTERNAL "Override update strategy" FORCE)

###############################################################################

# Tests; BUILD_TESTING is declared in cmake/Options.cmake, include(CTest) enables it
include(CTest)

add_subdirectory(src)
# This must be after src
add_subdirectory(app)
if(BUILD_TESTING)
    add_subdirectory(tests)
endif ()
