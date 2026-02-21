cmake_minimum_required(VERSION 3.28)

# NOTE: update EXECUTABLE_NAME in .github/workflows/cmake.yml when changing executable name in this file
# for now, the project name is used as the executable name
set(MAIN_PROJECT_NAME "oop")
set(MAIN_EXECUTABLE_NAME "${MAIN_PROJECT_NAME}_main")
set(MAIN_LIBRARY_NAME "${MAIN_PROJECT_NAME}")
set(TESTS_EXECUTABLE_NAME "${MAIN_PROJECT_NAME}_test")

# needs to be before `project()` to take effect
option(CMAKE_EXPORT_COMPILE_COMMANDS "Export compilation database" ON)

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

include(CTest)
include(cmake/RegisterTests.cmake)

###############################################################################

if(APPLE)
    find_library(LIBIDN2_LIBRARY idn2 HINTS /opt/homebrew/lib)
    if(NOT LIBIDN2_LIBRARY)
        message(FATAL_ERROR "libidn2 not found")
    endif()
endif()


###############################################################################

# External dependencies with FetchContent

include(FetchContent)

set(FETCHCONTENT_QUIET OFF CACHE INTERNAL "Override verbose output" FORCE)
set(FETCHCONTENT_UPDATES_DISCONNECTED ON CACHE INTERNAL "Override update strategy" FORCE)
set(SFML_WARNINGS_AS_ERRORS OFF)

# NOTE: Also update SFML_VERSION and other env vars used for caching in
#     - .github/actions/configure-cmake/action.yml
#     - .github/workflows/cmake.yml
FetchContent_Declare(
    SFML
    SYSTEM
    GIT_REPOSITORY https://github.com/SFML/SFML.git
    # renovate: datasource=github-tags depName=SFML/SFML versioning=loose
    GIT_TAG        3.1.0
    # renovate: depName=SFML/SFML
    # GIT_TAG        8835b6b955c96fa1ad1278a8dae6f05c4143effc # 3.1.0
    GIT_SHALLOW    1  # works only with branches or tags, not with arbitrary commit hashes
    GIT_PROGRESS   ON
)

FetchContent_Declare(
    cpr
    SYSTEM
    GIT_REPOSITORY https://github.com/libcpr/cpr.git
    # renovate: datasource=github-tags depName=libcpr/cpr versioning=loose
    GIT_TAG        1.14.2
    GIT_SHALLOW    1  # works only with branches or tags, not with arbitrary commit hashes
    GIT_PROGRESS   ON
)

FetchContent_MakeAvailable(SFML cpr)

###############################################################################

# External dependencies with find_package

find_package(Threads REQUIRED)
if(APPLE)
elseif(UNIX)
    find_package(X11)
endif()

###############################################################################

# Configure sources

# always STATIC (simpler); TBD if we ever want dynamic for this; BUILD_SHARED_LIBS is for ext deps
add_library(${MAIN_LIBRARY_NAME} STATIC)

# NOTE: update EXECUTABLE_NAME in .github/workflows/cmake.yml when changing name here
add_executable(${MAIN_EXECUTABLE_NAME}
    app/main.cpp
)
target_sources(${MAIN_LIBRARY_NAME}
    PRIVATE
        src/Example.cpp
        src/internal/Detail.cpp
)

# NOTE: Add all defined targets (e.g. executables, libraries, etc. )
# NOTE: RUN_SANITIZERS is optional, if it's not present it will default to true
set_compiler_flags(RUN_SANITIZERS ${USE_ASAN} TARGET_NAMES ${MAIN_EXECUTABLE_NAME} ${MAIN_LIBRARY_NAME})

###############################################################################

# Configure includes

# app/ needs no include dir of its own: it inherits include/ by linking the library
target_include_directories(${MAIN_LIBRARY_NAME} PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
)
target_include_directories(${MAIN_LIBRARY_NAME} PRIVATE
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/src>
)

# use SYSTEM so cppcheck and clang-tidy do not report warnings from these directories
# vendored external deps should be private by default
# a public dep is an interface commitment, shared by app/ and tests/
target_include_directories(${MAIN_LIBRARY_NAME} SYSTEM PUBLIC
    ${EXT_PUBLIC_DIR}
)
target_include_directories(${MAIN_LIBRARY_NAME} SYSTEM PRIVATE
    ${EXT_PRIVATE_DIR}
)

# target_include_directories(${MAIN_EXECUTABLE_NAME} SYSTEM PRIVATE ${<SomeLib>_SOURCE_DIR}/include)

###############################################################################

# Link libraries

target_link_libraries(${MAIN_EXECUTABLE_NAME} PRIVATE ${MAIN_LIBRARY_NAME} cpr::cpr SFML::Graphics SFML::Window SFML::System Threads::Threads)

# target_link_directories(${MAIN_EXECUTABLE_NAME} PRIVATE ${<SomeLib>_BINARY_DIR}/lib)
# target_link_libraries(${MAIN_EXECUTABLE_NAME} <SomeLib>)

if(APPLE)
    target_link_libraries(${MAIN_EXECUTABLE_NAME} PRIVATE ${LIBIDN2_LIBRARY})
elseif(UNIX)
    target_link_libraries(${MAIN_EXECUTABLE_NAME} PRIVATE X11)
endif()

###############################################################################

# copy binaries to "bin" folder; these are uploaded as artifacts on each release
# DESTINATION_DIR is set as "bin" in cmake/Options.cmake
install(TARGETS ${MAIN_EXECUTABLE_NAME} DESTINATION ${DESTINATION_DIR})
install(TARGETS ${MAIN_LIBRARY_NAME} ARCHIVE DESTINATION lib)
install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/include/
    DESTINATION include
    FILES_MATCHING
        PATTERN "*.h"
        PATTERN "*.hpp"
)
if(APPLE)
    install(FILES ${CMAKE_SOURCE_DIR}/launcher.command DESTINATION ${DESTINATION_DIR})
endif()

copy_files(FILES tastatura.txt DIRECTORY assets COPY_TO_DESTINATION TARGET_NAME ${MAIN_EXECUTABLE_NAME})
# copy_files(FILES tastatura.txt config.json DIRECTORY images sounds COPY_TO_DESTINATION TARGET_NAME ${MAIN_EXECUTABLE_NAME})
# copy_files(DIRECTORY images sounds COPY_TO_DESTINATION TARGET_NAME ${MAIN_EXECUTABLE_NAME})

###############################################################################

# Tests; BUILD_TESTING is declared in cmake/Options.cmake, include(CTest) enables it. No framework on main

if(BUILD_TESTING)
    add_subdirectory(tests)
endif()
