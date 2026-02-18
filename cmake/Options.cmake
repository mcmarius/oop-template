option(WARNINGS_AS_ERRORS "Treat warnings as errors" OFF)
option(USE_ASAN "Use Address Sanitizer" OFF)
option(CMAKE_COLOR_DIAGNOSTICS "Enable color diagnostics" ON)
option(BUILD_SHARED_LIBS "Build libraries as shared" OFF)

# update name in .github/workflows/cmake.yml:27 when changing "bin" name here
set(DESTINATION_DIR "bin")

if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
    set(CMAKE_INSTALL_PREFIX "${PROJECT_SOURCE_DIR}/install_dir" CACHE PATH "..." FORCE)
endif()

if (DEFINED ENV{FETCHCONTENT_BASE_DIR} AND NOT IS_DIRECTORY $ENV{FETCHCONTENT_BASE_DIR})
    message(FATAL_ERROR "FETCHCONTENT_BASE_DIR env var defined  as $ENV{FETCHCONTENT_BASE_DIR} but directory does not exist")
endif ()

# if CMake vars are not defined, use paths from environment variables
if (NOT DEFINED FETCHCONTENT_BASE_DIR AND DEFINED ENV{FETCHCONTENT_BASE_DIR})
    set(FETCHCONTENT_BASE_DIR $ENV{FETCHCONTENT_BASE_DIR}
            CACHE INTERNAL "Override deps directory via environment variable"
            FORCE
    )
endif()

if (NOT DEFINED FETCHCONTENT_SOURCE_DIR_SFML AND DEFINED ENV{SFML3_DIR} AND NOT IS_DIRECTORY $ENV{SMFL3_DIR})
    set(FETCHCONTENT_SOURCE_DIR_SFML $ENV{SFML3_DIR}
            CACHE INTERNAL "Override source directory for SFML3 via environment variable"
            FORCE
    )
endif()
#########


# disable sanitizers when releasing executables without explicitly requested debug info
# use generator expressions to set flags correctly in both single and multi config generators
set(is_debug "$<CONFIG:Debug>")
set(is_rel_with_deb "$<CONFIG:RelWithDebInfo>")
set(debug_mode "$<OR:${is_debug},${is_rel_with_deb}>")

set(CPR_USE_SYSTEM_CURL OFF CACHE BOOL "If enabled we will use the curl lib already installed on this system." FORCE)
set(CPR_CURL_USE_LIBPSL OFF CACHE BOOL "Since curl 8.13 curl depends on libpsl (https://everything.curl.dev/build/deps.html#libpsl). By default cpr keeps this as a secure default enabled which in turn requires meson as build dependency. If set to OFF, psl support inside curl will be disabled." FORCE)
set(CPR_USE_SYSTEM_LIB_PSL ${CPR_USE_SYSTEM_CURL} CACHE BOOL "If enabled we will use the psl lib already installed on this system. Else meson is required as build dependency. Only relevant in case 'CPR_CURL_USE_LIBPSL' is set to ON." FORCE)
set(CPR_ENABLE_CURL_HTTP_ONLY ON "If enabled we will only use the HTTP/HTTPS protocols from CURL. If disabled, all the CURL protocols are enabled. This is useful if your project uses libcurl and you need support for other CURL features e.g. sending emails." FORCE)
set(CURL_USE_LIBPSL ${CPR_CURL_USE_LIBPSL} CACHE INTERNAL "" FORCE)
