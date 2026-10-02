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
        target_compile_definitions(${TARGET_NAME} PRIVATE NK_NATIVE_F16=0)
        target_compile_definitions(${TARGET_NAME} PRIVATE NK_NATIVE_BF16=0)

        # On MSVC, NumKong turns on the AVX2/AVX-512/AMX kernels based only on the
        # toolset version, so the binary demands those CPU extensions and dies with an
        # illegal instruction where they are missing (CI runners, older laptops).
        # Keep the portable kernels (as GCC/Clang do) unless -DUSE_NUMKONG_SIMD=ON.
        if(MSVC AND NOT USE_NUMKONG_SIMD)
            target_compile_definitions(${TARGET_NAME} PRIVATE
                NK_TARGET_HASWELL=0     # AVX2 + FMA + F16C
                NK_TARGET_ALDER=0       # AVX-VNNI
                NK_TARGET_SKYLAKE=0     # AVX-512F/CD/BW/DQ/VL
                NK_TARGET_ICELAKE=0     # AVX-512 VNNI/VBMI/VBMI2/BITALG/POPCNTDQ/IFMA
                NK_TARGET_GENOA=0       # AVX-512 BF16
                NK_TARGET_SAPPHIRE=0    # AVX-512 FP16
                NK_TARGET_TURIN=0       # AVX-VNNI-INT8
                NK_TARGET_SIERRA=0      # AVX-512 VP2INTERSECT
                NK_TARGET_SAPPHIREAMX=0 # AMX tile + BF16 + INT8
                NK_TARGET_GRANITEAMX=0  # AMX tile + FP16
                NK_TARGET_DIAMOND=0     # AVX10.2
            )
        endif()

        ###############################################################################

        if(PROJECT_WARNINGS_AS_ERRORS)
            set_property(TARGET ${TARGET_NAME} PROPERTY COMPILE_WARNING_AS_ERROR ON)
        endif()

        # custom compiler flags
        message("Compiler: ${CMAKE_CXX_COMPILER_ID} version ${CMAKE_CXX_COMPILER_VERSION}")
        if(MSVC)
            target_compile_options(${TARGET_NAME} PRIVATE /W4 /Zc:__cplusplus /permissive- /wd4244 /wd4267 /wd4996 /external:anglebrackets /external:W0 /utf-8 /MP)
        else()
            target_compile_options(${TARGET_NAME} PRIVATE -Wall -Wextra -pedantic)
        endif()

        ###############################################################################

        # sanitizers
        if(ARG_RUN_SANITIZERS)
            if("${CMAKE_CXX_COMPILER_ID}" MATCHES "GNU")
            else()
                set_custom_stdlib_and_sanitizers(cpr false)
            endif()
            set_custom_stdlib_and_sanitizers(${TARGET_NAME} true)
        endif ()
    endforeach ()
endfunction()
