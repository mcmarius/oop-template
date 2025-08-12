cmake_minimum_required(VERSION 3.28)

# NOTE: update EXECUTABLE_NAME in .github/workflows/cmake.yml when changing executable name in this file
# for now, the project name is used as the executable name
set(MAIN_PROJECT_NAME "oop")
set(MAIN_EXECUTABLE_NAME "${MAIN_PROJECT_NAME}_main")
set(MAIN_LIBRARY_NAME "${MAIN_PROJECT_NAME}")
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

include(CTest)
include(cmake/RegisterTests.cmake)

###############################################################################

# External dependencies with FetchContent

include(FetchContent)

set(FETCHCONTENT_QUIET OFF CACHE INTERNAL "Override verbose output" FORCE)
set(FETCHCONTENT_UPDATES_DISCONNECTED ON CACHE INTERNAL "Override update strategy" FORCE)

# NOTE: Also update env vars used for caching in
#     - .github/actions/configure-cmake/action.yml
#     - .github/workflows/cmake.yml
# FetchContent_Declare(
#     SomeLib
#     SYSTEM         # keeps ext libs out of static code analysis
#     GIT_REPOSITORY https://github.com/<SomeUser>/<SomeLib>.git
#     GIT_TAG        <some_git_hash> # <which tag/branch @ <some_date>>
#     GIT_SHALLOW    1  # works only with branches or tags, not with arbitrary commit hashes
#     GIT_PROGRESS   ON
# )
#
# FetchContent_MakeAvailable(SomeLib)

# NOTE: Also update PQXX_VERSION env var in .github/workflows/cmake.yml:31
FetchContent_Declare(
    pqxx
    GIT_REPOSITORY https://github.com/jtv/libpqxx.git
    # renovate: datasource=github-tags depName=jtv/libpqxx versioning=loose
    GIT_TAG 7.9.2
    GIT_SHALLOW    1
    GIT_PROGRESS ON
)

FetchContent_MakeAvailable(pqxx)

###############################################################################

# External dependencies with find_package

# find_package(Threads REQUIRED)

find_package(PostgreSQL)

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
        src/database/Database.cpp
)

# NOTE: Add all defined targets (e.g. executables, libraries, etc. )
set_compiler_flags(RUN_SANITIZERS ${USE_ASAN} TARGET_NAMES ${MAIN_EXECUTABLE_NAME} pqxx ${MAIN_LIBRARY_NAME})

###############################################################################

# Configure includes

# app/ needs no include dir of its own: it inherits include/ by linking the library
target_include_directories(${MAIN_LIBRARY_NAME} PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
)
target_include_directories(${MAIN_LIBRARY_NAME} PRIVATE
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/src>
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/src/database>
)

# use SYSTEM so cppcheck and clang-tidy do not report warnings from these directories
# vendored external deps should be private by default
# a public dep is an interface commitment, shared by app/ and tests/
target_include_directories(${MAIN_LIBRARY_NAME} SYSTEM PUBLIC
    ${EXT_PUBLIC_DIR}
)
target_include_directories(${MAIN_LIBRARY_NAME} SYSTEM PRIVATE
    ${EXT_PRIVATE_DIR}
    # ${EXT_PRIVATE_DIR}/laserpants/dotenv
)

# target_include_directories(${MAIN_EXECUTABLE_NAME} SYSTEM PRIVATE ${<SomeLib>_SOURCE_DIR}/include)

###############################################################################

# Link libraries

target_link_libraries(${MAIN_EXECUTABLE_NAME} PRIVATE pqxx ${MAIN_LIBRARY_NAME})

# target_link_directories(${MAIN_EXECUTABLE_NAME} PRIVATE ${<SomeLib>_BINARY_DIR}/lib)
# target_link_libraries(${MAIN_EXECUTABLE_NAME} <SomeLib>)

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

copy_files(FILES tastatura.txt .env DIRECTORY assets COPY_TO_DESTINATION TARGET_NAME ${MAIN_EXECUTABLE_NAME})
# copy_files(FILES tastatura.txt config.json DIRECTORY images sounds COPY_TO_DESTINATION TARGET_NAME ${MAIN_EXECUTABLE_NAME})
# copy_files(DIRECTORY images sounds COPY_TO_DESTINATION TARGET_NAME ${MAIN_EXECUTABLE_NAME})

###############################################################################

# Tests; BUILD_TESTING is declared in cmake/Options.cmake, include(CTest) enables it. No framework on main

if(BUILD_TESTING)
    add_subdirectory(tests)
endif()
