include(cmake/CustomStdlibAndSanitizers.cmake)

# target definitions

function(set_compiler_flags)
    set(multiValueArgs TARGET_NAMES)
    set(oneValueArgs RUN_SANITIZERS)
    cmake_parse_arguments(PARSE_ARGV 0 ARG "" "${oneValueArgs}" "${multiValueArgs}")

    if(NOT DEFINED ARG_RUN_SANITIZERS)
        set(ARG_RUN_SANITIZERS TRUE)
    endif()

    # iterate over all specified targets
    foreach (TARGET_NAME IN LISTS ARG_TARGET_NAMES)
        if(GITHUB_ACTIONS)
            message("NOTE: GITHUB_ACTIONS defined")
            target_compile_definitions(${TARGET_NAME} PRIVATE GITHUB_ACTIONS)
        endif()

        ###############################################################################

        if(PROJECT_WARNINGS_AS_ERRORS)
            set_property(TARGET ${TARGET_NAME} PROPERTY COMPILE_WARNING_AS_ERROR ON)
        endif()

        # custom compiler flags
        message("Compiler: ${CMAKE_CXX_COMPILER_ID} version ${CMAKE_CXX_COMPILER_VERSION}")
        if(MSVC)
            target_compile_options(${TARGET_NAME} PRIVATE /W4 /permissive- /wd4244 /wd4267 /wd4996 /external:anglebrackets /external:W0 /utf-8 /MP)
            set_target_properties(${TARGET_NAME} PROPERTIES WIN32_EXECUTABLE TRUE)
        else()
            target_compile_options(${TARGET_NAME} PRIVATE -Wall -Wextra -pedantic)
        endif()

        ###############################################################################
        set(WX_LIBS sharpyuv webputils webpdecode webpencode webpdsp webp wxxml wxnet wxwebkit2_ext webpdemux wxrc wxscintilla wxlexilla wxcore wxadv wxribbon wxaui wxpropgrid wxhtml wxstc wxwebview wxqa wxgl wxrichtext wxxrc)
        # sanitizers
        if("${ARG_RUN_SANITIZERS}" STREQUAL "TRUE")
            if("${CMAKE_CXX_COMPILER_ID}" MATCHES "GNU")
            else()
                set_custom_stdlib_and_sanitizers(${WX_LIBS} false)
            endif()

            set_custom_stdlib_and_sanitizers(${TARGET_NAME} true)
        endif ()
    endforeach ()
endfunction()
