# On MinGW, the EDB PostgreSQL installer ships libpq.a as a static archive of
# MSVC-compiled objects (references __security_cookie, __GSHandlerCheck, etc.).
# MinGW cannot link these. This module generates a proper MinGW import library
# from libpq.dll using gendef + dlltool, then overrides PostgreSQL_LIBRARY so
# that pqxx (via find_package(PostgreSQL)) links against the DLL instead.
#
# Must be included BEFORE FetchContent_MakeAvailable(pqxx).

if(NOT MINGW)
    return()
endif()

find_package(PostgreSQL QUIET)

if(NOT PostgreSQL_FOUND)
    return()
endif()

# Only fix if the found library looks like an MSVC static archive
# (a plain .a, not a .dll.a import library)
if(PostgreSQL_LIBRARY AND EXISTS "${PostgreSQL_LIBRARY}")
    get_filename_component(_lib_name "${PostgreSQL_LIBRARY}" NAME)
    if(NOT _lib_name MATCHES "\\.dll\\.a$")
        # Find libpq.dll next to the PostgreSQL installation
        get_filename_component(_lib_dir "${PostgreSQL_LIBRARY}" DIRECTORY)
        get_filename_component(_pg_root "${_lib_dir}" DIRECTORY)
        find_file(_libpq_dll NAMES libpq.dll PATHS "${_pg_root}/bin" NO_DEFAULT_PATH)

        if(NOT _libpq_dll)
            message(WARNING "MinGW: found ${_lib_name} but no libpq.dll; "
                            "pqxx link may fail")
            return()
        endif()

        find_program(GENDEF_EXECUTABLE NAMES gendef)
        find_program(DLLTOOL_EXECUTABLE NAMES dlltool)

        if(NOT GENDEF_EXECUTABLE OR NOT DLLTOOL_EXECUTABLE)
            message(WARNING "MinGW: gendef/dlltool not found; "
                            "pqxx link will likely fail")
            return()
        endif()

        set(_gen_dir "${CMAKE_BINARY_DIR}/_mingw_libpq")
        file(MAKE_DIRECTORY "${_gen_dir}")
        set(_import_lib "${_gen_dir}/libpq.dll.a")

        # Only regenerate if the import lib doesn't exist or the DLL is newer
        if(NOT EXISTS "${_import_lib}" OR
           "${_libpq_dll}" IS_NEWER_THAN "${_import_lib}")

            message(STATUS "MinGW: generating import library from ${_libpq_dll}")

            execute_process(
                COMMAND "${GENDEF_EXECUTABLE}" "${_libpq_dll}"
                WORKING_DIRECTORY "${_gen_dir}"
                RESULT_VARIABLE _gendef_result
                OUTPUT_QUIET ERROR_QUIET
            )

            if(NOT _gendef_result EQUAL 0)
                message(FATAL_ERROR
                    "MinGW: gendef failed on ${_libpq_dll}")
            endif()

            execute_process(
                COMMAND "${DLLTOOL_EXECUTABLE}"
                        -d "${_gen_dir}/libpq.def"
                        -l "${_import_lib}"
                        -D "libpq.dll"
                RESULT_VARIABLE _dlltool_result
                OUTPUT_QUIET ERROR_QUIET
            )

            if(NOT _dlltool_result EQUAL 0)
                message(FATAL_ERROR
                    "MinGW: dlltool failed generating ${_import_lib}")
            endif()
        endif()

        # Override the cache so find_package(PostgreSQL) inside pqxx is a no-op
        # (PostgreSQL_FOUND is already set)
        set(PostgreSQL_LIBRARY "${_import_lib}"
            CACHE FILEPATH "PostgreSQL library (MinGW import lib)" FORCE)

        # Patch the imported target that find_package already created
        if(TARGET PostgreSQL::PostgreSQL)
            set_target_properties(PostgreSQL::PostgreSQL PROPERTIES
                IMPORTED_LOCATION "${_import_lib}")
        endif()

        message(STATUS "MinGW: PostgreSQL library overridden -> ${_import_lib}")
    endif()
endif()
