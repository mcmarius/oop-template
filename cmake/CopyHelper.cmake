# helper function to copy files to build directory and install directory without duplicating file names across commands
function(copy_files)
    set(options COPY_TO_DESTINATION)
    set(oneValueArgs TARGET_NAME)
    set(multiValueArgs FILES DIRECTORY)
    cmake_parse_arguments(PARSE_ARGV 0 ARG "${options}" "${oneValueArgs}" "${multiValueArgs}")

    # copy files to build dir relative to CMAKE_SOURCE_DIR, which is always the top level
    foreach(file ${ARG_FILES})
        add_custom_command(
            TARGET ${ARG_TARGET_NAME} POST_BUILD
            COMMENT "Copying ${file}..."
            COMMAND ${CMAKE_COMMAND} -E copy_if_different
            ${CMAKE_SOURCE_DIR}/${file} $<TARGET_FILE_DIR:${ARG_TARGET_NAME}>)
            # ${CMAKE_CURRENT_BINARY_DIR})
    endforeach()

    # copy folders to build dir
    foreach(dir ${ARG_DIRECTORY})
        add_custom_command(
            TARGET ${ARG_TARGET_NAME} POST_BUILD
            COMMENT "Copying directory ${dir}..."
            COMMAND ${CMAKE_COMMAND} -E copy_directory_if_different
            ${CMAKE_SOURCE_DIR}/${dir} $<TARGET_FILE_DIR:${ARG_TARGET_NAME}>/${dir})
            # ${CMAKE_CURRENT_BINARY_DIR}/${dir})
    endforeach()

    if(ARG_COPY_TO_DESTINATION)
        # copy files and folders to install dir
        # install() would resolve these against the caller's dir (src/), not the top level
        set(copy_files_files ${ARG_FILES})
        set(copy_files_dirs ${ARG_DIRECTORY})
        list(TRANSFORM copy_files_files PREPEND "${CMAKE_SOURCE_DIR}/")
        list(TRANSFORM copy_files_dirs PREPEND "${CMAKE_SOURCE_DIR}/")
        if(copy_files_files)
            install(FILES ${copy_files_files} DESTINATION ${DESTINATION_DIR})
        endif()
        if(copy_files_dirs)
            install(DIRECTORY ${copy_files_dirs} DESTINATION ${DESTINATION_DIR})
        endif()
    endif()
endfunction()
