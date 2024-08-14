option(PROJECT_WARNINGS_AS_ERRORS "Treat warnings as errors" OFF)
option(USE_ASAN "Use Address Sanitizer" OFF)
option(USE_MSAN "Use Memory Sanitizer" OFF)
option(CMAKE_COLOR_DIAGNOSTICS "Enable color diagnostics" ON)
option(BUILD_SHARED_LIBS "Build SFML as shared library" FALSE)

# update name in .github/workflows/cmake.yml:27 when changing "bin" name here
set(DESTINATION_DIR "bin")

if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
    set(CMAKE_INSTALL_PREFIX "${PROJECT_SOURCE_DIR}/install_dir" CACHE PATH "..." FORCE)
endif()

# disable sanitizers when releasing executables without explicitly requested debug info
# use generator expressions to set flags correctly in both single and multi config generators
set(is_debug "$<CONFIG:Debug>")
set(is_rel_with_deb "$<CONFIG:RelWithDebInfo>")
set(debug_mode "$<OR:${is_debug},${is_rel_with_deb}>")

if(GITHUB_ACTIONS)
    # fix for MSVC because we do not care about different configs on CI
    # TODO for those with too much free time: figure out packaging without this hack
    set(CMAKE_RUNTIME_OUTPUT_DIRECTORY_DEBUG ${PROJECT_BINARY_DIR})
    set(CMAKE_RUNTIME_OUTPUT_DIRECTORY_RELEASE ${PROJECT_BINARY_DIR})
    set(CMAKE_RUNTIME_OUTPUT_DIRECTORY_RELWITHDEBINFO ${PROJECT_BINARY_DIR})
    set(CMAKE_RUNTIME_OUTPUT_DIRECTORY_MINSIZEREL ${PROJECT_BINARY_DIR})
endif()