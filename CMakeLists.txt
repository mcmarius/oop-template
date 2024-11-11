cmake_minimum_required(VERSION 3.26)

project(oop-src)

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

set(PROJECT_ROOT "${CMAKE_CURRENT_LIST_DIR}")
set(CMAKE_HELPER_DIR "${PROJECT_ROOT}/cmake")

include(${CMAKE_HELPER_DIR}/Options.cmake)
include(${CMAKE_HELPER_DIR}/CopyHelper.cmake)

# external dependencies with FetchContent
include(FetchContent)

set(FETCHCONTENT_QUIET OFF)
set(FETCHCONTENT_UPDATES_DISCONNECTED ON)

add_subdirectory(src)
if(BUILD_TESTS)
    include(CTest)
    enable_testing()
    add_subdirectory(tests)
endif ()