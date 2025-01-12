include(cmake/CustomStdlibAndSanitizers.cmake)

# target definitions

function(set_compiler_flags)
    set(multiValueArgs TARGET_NAMES)
    cmake_parse_arguments(PARSE_ARGV 0 ARG "" "" "${multiValueArgs}")

    # iterate over all specified targets
    foreach (TARGET_NAME IN LISTS ARG_TARGET_NAMES)
        if(GITHUB_ACTIONS)
            message("NOTE: GITHUB_ACTIONS defined")
            target_compile_definitions(${TARGET_NAME} PRIVATE GITHUB_ACTIONS)
        endif()

        ###############################################################################

        if(PROJECT_WARNINGS_AS_ERRORS)
            if(NOT "${TARGET_NAME}" STREQUAL "pqxx")
                set_property(TARGET ${TARGET_NAME} PROPERTY COMPILE_WARNING_AS_ERROR ON)
            endif ()
        endif()

        # custom compiler flags
        message("Compiler: ${CMAKE_CXX_COMPILER_ID} version ${CMAKE_CXX_COMPILER_VERSION}")
        if(MSVC)
            if("${TARGET_NAME}" STREQUAL "pqxx")
                target_compile_options(${TARGET_NAME} PRIVATE /W0)
            else()
                target_compile_options(${TARGET_NAME} PRIVATE /W4 /permissive- /wd4244 /wd4267 /wd4996
                        /external:anglebrackets /external:W0 /utf-8 /MP)
            endif ()
        else()
            if("${TARGET_NAME}" STREQUAL "pqxx")
                target_compile_options(${TARGET_NAME} PRIVATE -w)
            else()
                target_compile_options(${TARGET_NAME} PRIVATE -Wall -Wextra -pedantic)
            endif ()
        endif()

        ###############################################################################

        # sanitizers
        set_custom_stdlib_and_sanitizers(${TARGET_NAME} true)
    endforeach ()
endfunction()