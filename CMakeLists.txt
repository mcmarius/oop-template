cmake_minimum_required(VERSION 3.26)

# NOTE: update executable name in .github/workflows/cmake.yml:25 when changing executable name in this file
# for now, the project name is used as the executable name
set(MAIN_PROJECT_NAME "oop")
set(MAIN_EXECUTABLE_NAME "${MAIN_PROJECT_NAME}")
set(MAIN_PROJECT_LIB_NAME "${MAIN_PROJECT_NAME}_lib")
set(MAIN_PROJECT_NO_SAN_LIB_NAME "${MAIN_PROJECT_NAME}_nslib")
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

include(CTest)
enable_testing()
###############################################################################

# external dependencies with FetchContent
# include(FetchContent)
#
# set(FETCHCONTENT_QUIET OFF)
# set(FETCHCONTENT_UPDATES_DISCONNECTED ON)
#
# NOTE: Also update env vars used for caching in
#         - .github/actions/configure-cmake/action.yml
#         - .github/workflows/cmake.yml
# FetchContent_Declare(
#         SomeLib
#         GIT_REPOSITORY https://github.com/<SomeUser>/<SomeLib>.git
#         GIT_TAG        <some_git_hash> # <which tag/branch @ <some_date>>
#         GIT_SHALLOW    1  # works only with branches or tags, not with arbitrary commit hashes
# )
#
# FetchContent_MakeAvailable(SomeLib)

###############################################################################

# external dependencies with find_package

# find_package(Threads REQUIRED)

###############################################################################

# NOTE: update executable name in .github/workflows/cmake.yml:25 when changing name here
add_library(${MAIN_PROJECT_LIB_NAME}
        exemplu_test_oop/BankAccount.cpp
)

target_include_directories(${MAIN_PROJECT_LIB_NAME} PUBLIC
        exemplu_test_oop/
)

add_library(${MAIN_PROJECT_NO_SAN_LIB_NAME}
        exemplu_test_oop/BankAccount.cpp
)

target_include_directories(${MAIN_PROJECT_NO_SAN_LIB_NAME} PUBLIC
        exemplu_test_oop/
)


add_executable(${MAIN_EXECUTABLE_NAME}
    main.cpp
)

# NOTE: Add all defined targets (e.g. executables, libraries, etc. )
set_compiler_flags(TARGET_NAMES ${MAIN_EXECUTABLE_NAME} ${MAIN_PROJECT_LIB_NAME})
set_compiler_flags(RUN_SANITIZERS FALSE TARGET_NAMES ${MAIN_PROJECT_NO_SAN_LIB_NAME})
# set_compiler_flags(TARGET_NAMES ${MAIN_EXECUTABLE_NAME} ${FOO} ${BAR})
# where ${FOO} and ${BAR} represent additional executables or libraries
# you want to compile with the set compiler flags

target_link_libraries(${MAIN_EXECUTABLE_NAME} PRIVATE ${MAIN_PROJECT_LIB_NAME})

###############################################################################

set(TEST_SOURCES_DIR ${CMAKE_SOURCE_DIR}/tests)
set(BOOST_UT_INCLUDE_DIR "${CMAKE_SOURCE_DIR}/ext/include/boost")

add_executable(${TESTS_EXECUTABLE_NAME}
        ${TEST_SOURCES_DIR}/main.cpp
        ${TEST_SOURCES_DIR}/test_oop.cpp
        ${TEST_SOURCES_DIR}/test_simplu.cpp
)

target_link_libraries(${TESTS_EXECUTABLE_NAME} PRIVATE ${MAIN_PROJECT_NO_SAN_LIB_NAME})
target_include_directories(${TESTS_EXECUTABLE_NAME} SYSTEM PRIVATE ${BOOST_UT_INCLUDE_DIR})

set_compiler_flags(RUN_SANITIZERS FALSE TARGET_NAMES ${TESTS_EXECUTABLE_NAME})

add_test(NAME ${TESTS_EXECUTABLE_NAME} COMMAND ${TESTS_PROJECT_NAME})

###############################################################################

# use SYSTEM so cppcheck and clang-tidy do not report warnings from these directories
# target_include_directories(${MAIN_EXECUTABLE_NAME} SYSTEM PRIVATE ext/<SomeHppLib>/include)
# target_include_directories(${MAIN_EXECUTABLE_NAME} SYSTEM PRIVATE ${<SomeLib>_SOURCE_DIR}/include)
# target_link_directories(${MAIN_EXECUTABLE_NAME} PRIVATE ${<SomeLib>_BINARY_DIR}/lib)
# target_link_libraries(${MAIN_EXECUTABLE_NAME} <SomeLib>)

###############################################################################

# copy binaries to "bin" folder; these are uploaded as artifacts on each release
# DESTINATION_DIR is set as "bin" in cmake/Options.cmake:6
install(TARGETS ${MAIN_EXECUTABLE_NAME} DESTINATION ${DESTINATION_DIR})
if(APPLE)
    install(FILES launcher.command DESTINATION ${DESTINATION_DIR})
endif()

copy_files(FILES tastatura.txt COPY_TO_DESTINATION TARGET_NAME ${MAIN_EXECUTABLE_NAME})
# copy_files(FILES tastatura.txt config.json DIRECTORY images sounds COPY_TO_DESTINATION TARGET_NAME ${MAIN_EXECUTABLE_NAME})
# copy_files(DIRECTORY images sounds COPY_TO_DESTINATION TARGET_NAME ${MAIN_EXECUTABLE_NAME})
