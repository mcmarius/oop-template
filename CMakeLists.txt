cmake_minimum_required(VERSION 3.28)

# NOTE: update EXECUTABLE_NAME in .github/workflows/cmake.yml when changing executable name in this file
# for now, the project name is used as the executable name
set(MAIN_PROJECT_NAME "oop")
set(MAIN_EXECUTABLE_NAME "${MAIN_PROJECT_NAME}_main")
set(MAIN_LIBRARY_NAME "${MAIN_PROJECT_NAME}")


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

###############################################################################

# External dependencies with FetchContent

# include(FetchContent)
#
# set(FETCHCONTENT_QUIET OFF CACHE INTERNAL "Override verbose output" FORCE)
# set(FETCHCONTENT_UPDATES_DISCONNECTED ON CACHE INTERNAL "Override update strategy" FORCE)
#
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

###############################################################################

# External dependencies with find_package

# find_package(Threads REQUIRED)

###############################################################################

# Configure sources

# always STATIC (simpler); TBD if we ever want dynamic for this; BUILD_SHARED_LIBS is for ext deps
add_library(${MAIN_LIBRARY_NAME} STATIC)

# NOTE: update EXECUTABLE_NAME in .github/workflows/cmake.yml when changing name here
add_executable(${MAIN_EXECUTABLE_NAME}
    app/main.cpp
)
# include/ holds the PUBLIC API only; private headers live next to the sources in src/internal/.
target_sources(${MAIN_LIBRARY_NAME}
    PUBLIC
        FILE_SET HEADERS
            BASE_DIRS ${CMAKE_CURRENT_SOURCE_DIR}/include
            FILES
                include/Example.h
    PRIVATE
        src/Example.cpp
        src/internal/Detail.cpp
    PRIVATE
        FILE_SET detail_headers
            TYPE HEADERS
            BASE_DIRS ${CMAKE_CURRENT_SOURCE_DIR}/src
            FILES
                src/internal/Detail.h
)

# NOTE: Add all defined targets (e.g. executables, libraries, etc. )
# NOTE: RUN_SANITIZERS is optional, if it's not present it will default to true
set_compiler_flags(RUN_SANITIZERS ${USE_ASAN} TARGET_NAMES ${MAIN_EXECUTABLE_NAME} ${MAIN_LIBRARY_NAME})

###############################################################################

# Configure includes

target_include_directories(${MAIN_EXECUTABLE_NAME} PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
)

# NOTE: no target_include_directories() for the library's own headers

# use SYSTEM so cppcheck and clang-tidy do not report warnings from these directories
target_include_directories(${MAIN_EXECUTABLE_NAME} SYSTEM PRIVATE
    ext
)
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

target_link_libraries(${MAIN_EXECUTABLE_NAME} PRIVATE ${MAIN_LIBRARY_NAME})

# target_link_directories(${MAIN_EXECUTABLE_NAME} PRIVATE ${<SomeLib>_BINARY_DIR}/lib)
# target_link_libraries(${MAIN_EXECUTABLE_NAME} <SomeLib>)

###############################################################################

# copy binaries to "bin" folder; these are uploaded as artifacts on each release
# DESTINATION_DIR is set as "bin" in cmake/Options.cmake
install(TARGETS ${MAIN_EXECUTABLE_NAME} DESTINATION ${DESTINATION_DIR})
# Export only public headers; FILE_SET HEADERS keeps structure relative to BASE_DIRS
install(TARGETS ${MAIN_LIBRARY_NAME}
    ARCHIVE DESTINATION lib
    FILE_SET HEADERS DESTINATION include
)
if(APPLE)
    install(FILES ${CMAKE_SOURCE_DIR}/launcher.command DESTINATION ${DESTINATION_DIR})
endif()

copy_files(FILES tastatura.txt DIRECTORY assets COPY_TO_DESTINATION TARGET_NAME ${MAIN_EXECUTABLE_NAME})
# copy_files(FILES tastatura.txt config.json DIRECTORY images sounds COPY_TO_DESTINATION TARGET_NAME ${MAIN_EXECUTABLE_NAME})
# copy_files(DIRECTORY images sounds COPY_TO_DESTINATION TARGET_NAME ${MAIN_EXECUTABLE_NAME})
