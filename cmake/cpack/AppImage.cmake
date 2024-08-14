# credits: https://github.com/Ravbug/AppImage.cmake

function(make_appimage)
	set(optional)
	set(args EXE NAME DIR_ICON ICON OUTPUT_NAME)
	set(list_args ASSETS)
	cmake_parse_arguments(
		PARSE_ARGV 0
		ARGS
		"${optional}"
		"${args}"
		"${list_args}"
	)

	if(${ARGS_UNPARSED_ARGUMENTS})
		message(WARNING "Unparsed arguments: ${ARGS_UNPARSED_ARGUMENTS}")
	endif()


    # download AppImageTool if needed (TODO: non-x86 build machine?)
    SET(AIT_PATH "${CMAKE_BINARY_DIR}/AppImageTool.AppImage" CACHE INTERNAL "")
    if (NOT EXISTS "${AIT_PATH}")
        file(DOWNLOAD https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage "${AIT_PATH}")
        execute_process(COMMAND chmod +x ${AIT_PATH})
    endif()

    # make the AppDir
    set(APPDIR "${CMAKE_BINARY_DIR}/AppDir")
    file(REMOVE_RECURSE "${APPDIR}")       # remove if leftover
    file(MAKE_DIRECTORY "${APPDIR}")
    file(MAKE_DIRECTORY "${APPDIR}/lib")

    if(EXISTS "${CMAKE_INSTALL_PREFIX}/bin/lib")
        file(COPY "${CMAKE_INSTALL_PREFIX}/bin/lib" DESTINATION "${APPDIR}")
    endif()

    # copy executable to appdir
    file(COPY "${ARGS_EXE}" DESTINATION "${APPDIR}" FOLLOW_SYMLINK_CHAIN)
    get_filename_component(EXE_NAME "${ARGS_EXE}" NAME)

    # create the script that will launch the AppImage
    # the sleep is used to make the filesystem available
    # until all the resources are loaded
    file(WRITE "${APPDIR}/AppRun"
        "#!/bin/sh\n"
        "cd \"$(dirname \"$0\")\";\n"
        "export RESOURCES_DIR=\"$(dirname \"$0\")\"\n"
        "x-terminal-emulator -e ./${EXE_NAME} $@ && sleep 10 &\n"
    )
    # NOTE
    # if you also need a terminal
    # use "x-terminal-emulator -e ./${EXE_NAME} $@ && sleep 10"
    # if you only want GUI, use "./${EXE_NAME} $@"
    #
    execute_process(COMMAND chmod +x "${APPDIR}/AppRun")

    # copy assets to appdir
    string(REPLACE "\;" ";" ARGS_ASSETS "${ARGS_ASSETS}")
    foreach(file ${ARGS_ASSETS})
        message("copying ${file} to ${APPDIR}...")
        file(COPY ${file} DESTINATION "${APPDIR}")
    endforeach()

    # copy icon thumbnail
    file(COPY ${ARGS_DIR_ICON} DESTINATION "${APPDIR}")
    get_filename_component(THUMB_NAME "${ARGS_DIR_ICON}" NAME)
    file(RENAME "${APPDIR}/${THUMB_NAME}" "${APPDIR}/.DirIcon")

    # copy icon highres
    file(COPY ${ARGS_ICON} DESTINATION "${APPDIR}")
    get_filename_component(ICON_NAME "${ARGS_ICON}" NAME)
    get_filename_component(ICON_EXT "${ARGS_ICON}" EXT)
    file(RENAME "${APPDIR}/${ICON_NAME}" "${APPDIR}/icon${ICON_EXT}")

    # Create the .desktop file
    file(WRITE "${APPDIR}/${ARGS_NAME}.desktop"
        "[Desktop Entry]\n"
        "Type=Application\n"
        "Name=${ARGS_NAME}\n"
        "Icon=icon\n"
        "Categories=Utility;"
    )

    # Invoke AppImageTool
    execute_process(COMMAND ${AIT_PATH} ${APPDIR} ${ARGS_OUTPUT_NAME} -n)
    file(REMOVE_RECURSE "${APPDIR}")

endfunction()

