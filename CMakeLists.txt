cmake_minimum_required(VERSION 3.28)

# NOTE: update executable name in .github/workflows/cmake.yml when changing executable name in this file
# for now, the project name is used as the executable name
set(MAIN_PROJECT_NAME "oop")
set(MAIN_EXECUTABLE_NAME "${MAIN_PROJECT_NAME}")
set(MAIN_LIBRARY_NAME "${MAIN_PROJECT_NAME}_lib")
set(MAIN_LIBRARY_NO_SAN_NAME "${MAIN_PROJECT_NAME}_nslib")
set(TESTS_PROJECT_NAME "${MAIN_PROJECT_NAME}_test")
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
include(cmake/RegisterTests.cmake)

# include(CTest) declares BUILD_TESTING (default ON)
include(CTest)
###############################################################################

# external dependencies with FetchContent
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

# external dependencies with find_package

# find_package(Threads REQUIRED)

###############################################################################

# NOTE: update executable name in .github/workflows/cmake.yml when changing name here
add_library(${MAIN_LIBRARY_NAME} STATIC)
target_sources(${MAIN_LIBRARY_NAME}
    PRIVATE
        src/exemplu_test_oop/BankAccount.cpp
)

add_library(${MAIN_LIBRARY_NO_SAN_NAME} STATIC)
target_sources(${MAIN_LIBRARY_NO_SAN_NAME}
    PRIVATE
        src/exemplu_test_oop/BankAccount.cpp
)

add_executable(${MAIN_EXECUTABLE_NAME}
    main.cpp
)
target_sources(${MAIN_EXECUTABLE_NAME}
    PRIVATE
        src/Example.cpp
)

###############################################################################

# NOTE: Add all defined targets (e.g. executables, libraries, etc. )
# NOTE: RUN_SANITIZERS is optional, if it's not present it will default to true
set_compiler_flags(RUN_SANITIZERS ${USE_ASAN} TARGET_NAMES ${MAIN_EXECUTABLE_NAME} ${MAIN_LIBRARY_NAME})
set_compiler_flags(RUN_SANITIZERS FALSE TARGET_NAMES ${MAIN_LIBRARY_NO_SAN_NAME})
# set_compiler_flags(TARGET_NAMES ${MAIN_EXECUTABLE_NAME} ${FOO} ${BAR})
# where ${FOO} and ${BAR} represent additional executables or libraries
# you want to compile with the set compiler flags

###############################################################################

target_include_directories(${MAIN_LIBRARY_NAME} PUBLIC
    $<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}/include>
)
target_include_directories(${MAIN_LIBRARY_NO_SAN_NAME} PUBLIC
    $<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}/include>
)
target_include_directories(${MAIN_EXECUTABLE_NAME} PUBLIC
    $<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}/include>
)
target_include_directories(${MAIN_LIBRARY_NAME} SYSTEM PRIVATE
    ${CMAKE_SOURCE_DIR}/ext
)
target_include_directories(${MAIN_LIBRARY_NO_SAN_NAME} SYSTEM PRIVATE
    ${CMAKE_SOURCE_DIR}/ext
)
target_include_directories(${MAIN_EXECUTABLE_NAME} SYSTEM PRIVATE
    ${CMAKE_SOURCE_DIR}/ext
)

target_link_libraries(${MAIN_EXECUTABLE_NAME} PRIVATE ${MAIN_LIBRARY_NAME})

###############################################################################

# use SYSTEM so cppcheck and clang-tidy do not report warnings from these directories
# target_include_directories(${MAIN_PROJECT_NAME} SYSTEM PRIVATE ext/<SomeHppLib>/include)
# target_include_directories(${MAIN_EXECUTABLE_NAME} SYSTEM PRIVATE ${<SomeLib>_SOURCE_DIR}/include)
# target_link_directories(${MAIN_EXECUTABLE_NAME} PRIVATE ${<SomeLib>_BINARY_DIR}/lib)
# target_link_libraries(${MAIN_EXECUTABLE_NAME} <SomeLib>)

###############################################################################

if(BUILD_TESTING)
    add_subdirectory(tests)
endif ()

###############################################################################

# copy binaries to "bin" folder; these are uploaded as artifacts on each release
# DESTINATION_DIR is set as "bin" in cmake/Options.cmake
install(TARGETS ${MAIN_EXECUTABLE_NAME} DESTINATION ${DESTINATION_DIR})
if(APPLE)
    install(FILES launcher.command DESTINATION ${DESTINATION_DIR})
endif()

copy_files(FILES tastatura.txt DIRECTORY assets COPY_TO_DESTINATION TARGET_NAME ${MAIN_EXECUTABLE_NAME})
# copy_files(FILES tastatura.txt config.json DIRECTORY images sounds COPY_TO_DESTINATION TARGET_NAME ${MAIN_EXECUTABLE_NAME})
# copy_files(DIRECTORY images sounds COPY_TO_DESTINATION TARGET_NAME ${MAIN_EXECUTABLE_NAME})
