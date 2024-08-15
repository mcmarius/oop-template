cmake_minimum_required(VERSION 3.26)

# NOTE: update executable name in .github/workflows/cmake.yml:25 when changing executable name in this file
# for now, the project name is used as the executable name
project(oop)
set(CMAKE_PROJECT_VERSION_MAJOR 0)
set(CMAKE_PROJECT_VERSION_MINOR 0)
set(CMAKE_PROJECT_VERSION_PATCH 1)

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

include(cmake/Options.cmake)

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
add_executable(${PROJECT_NAME}
    main.cpp
    generated/src/Helper.cpp
    icon.rc
)

include(cmake/CompilerFlags.cmake)

###############################################################################

# use SYSTEM so cppcheck and clang-tidy do not report warnings from these directories
target_include_directories(${PROJECT_NAME} SYSTEM PRIVATE generated/include)
# target_include_directories(${PROJECT_NAME} SYSTEM PRIVATE ext/<SomeHppLib>/include)
# target_include_directories(${PROJECT_NAME} SYSTEM PRIVATE ${<SomeLib>_SOURCE_DIR}/include)
# target_link_directories(${PROJECT_NAME} PRIVATE ${<SomeLib>_BINARY_DIR}/lib)
# target_link_libraries(${PROJECT_NAME} <SomeLib>)

###############################################################################

# copy binaries to "bin" folder; these are uploaded as artifacts on each release
# DESTINATION_DIR is set as "bin" in cmake/Options.cmake:6
if(WIN32)
    install(
        TARGETS ${PROJECT_NAME}
        DESTINATION ${DESTINATION_DIR})

    add_custom_command(TARGET ${PROJECT_NAME} POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy
            -t $<TARGET_FILE_DIR:${PROJECT_NAME}> $<TARGET_RUNTIME_DLLS:${PROJECT_NAME}>
        COMMAND_EXPAND_LISTS
    )
else()
    install(
        TARGETS ${PROJECT_NAME}
        RUNTIME_DEPENDENCY_SET dep_set
        DESTINATION ${DESTINATION_DIR})

    install(RUNTIME_DEPENDENCY_SET dep_set
        POST_EXCLUDE_REGEXES "libX.*" "libc.so*" "libm.so*" "libudev*" "libstdc*" "libgcc*" "ld-linux*"
        # POST_INCLUDE_REGEXES "libopenal*" "libvorbis*" "libFLAC*" "libogg*" "libasound*" "libsndio*"
        DESTINATION ${DESTINATION_DIR}/lib)
endif()

if(APPLE)
    install(FILES launcher.command DESTINATION ${DESTINATION_DIR})
elseif(WIN32)
    install(FILES launcher.bat DESTINATION ${DESTINATION_DIR})
endif()

include(cmake/CopyHelper.cmake)
# favicon.ico is needed on windows to have an icon for the start menu shortcut
set(assets_var
    tastatura.txt
    cmake/cpack/favicon.ico
    # cmake/cpack/icon.svg
    )
copy_files(FILES ${assets_var})
# copy_files(FILES tastatura.txt config.json DIRECTORY images sounds)
# copy_files(DIRECTORY images sounds)

# Packaging
include(cmake/cpack/main.cmake)
