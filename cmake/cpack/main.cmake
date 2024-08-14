# icon credits: https://www.veryicon.com/icons/food--drinks/fruit-library/coconut-15.html

if(APPLE OR WIN32)
    include(CPack)
    set(CPACK_PACKAGE_NAME "${PROJECT_NAME}")
    set(CPACK_PACKAGE_VENDOR "FMI UniBuc")
endif()

if(APPLE)
    # TODO https://discourse.cmake.org/t/how-to-add-resources-to-macos-bundle/9323
    # https://stackoverflow.com/questions/15120951/generating-a-bundle-file-with-cmake-on-mac-osx?rq=3
    # Bundling macOS application
    set_target_properties(${PROJECT_NAME} PROPERTIES
        MACOSX_BUNDLE TRUE
        MACOSX_BUNDLE_BUNDLE_NAME ${PROJECT_NAME}
        MACOSX_BUNDLE_BUNDLE_VERSION ${CMAKE_PROJECT_VERSION}
        MACOSX_BUNDLE_GUI_IDENTIFIER ro.unibuc.fmi.${PROJECT_NAME}
        MACOSX_BUNDLE_ICON_FILE "${PROJECT_SOURCE_DIR}/cmake/cpack/icon.svg"
        MACOSX_BUNDLE_SHORT_VERSION_STRING ${CMAKE_PROJECT_VERSION}
    )
    #set(CPACK_BUNDLE_NAME ${PROJECT_NAME})
    #set(CPACK_BUNDLE_PLIST "${PROJECT_SOURCE_DIR}/cmake/cpack/info.plist")
    #set(CPACK_BUNDLE_ICON "${PROJECT_SOURCE_DIR}/cmake/cpack/icon.svg")
elseif(UNIX)
    INSTALL(CODE
        "include(${CMAKE_CURRENT_LIST_DIR}/AppImage.cmake)
        make_appimage(
            EXE \"${CMAKE_INSTALL_PREFIX}/bin/${PROJECT_NAME}\"
            NAME \"${PROJECT_NAME}\"
            ICON \"${PROJECT_SOURCE_DIR}/cmake/cpack/icon.svg\"
            DIR_ICON \"${PROJECT_SOURCE_DIR}/cmake/cpack/diricon.png\"
            OUTPUT_NAME \"${CMAKE_BINARY_DIR}/${PROJECT_NAME}.AppImage\"
            ASSETS ${assets_var}
        )
        "
        COMPONENT Runtime
    )
endif()
