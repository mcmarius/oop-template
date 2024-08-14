# icon credits: https://www.veryicon.com/icons/food--drinks/fruit-library/coconut-15.html

if(APPLE OR WIN32)
    include(CPack)
endif()

if(APPLE)
elseif(UNIX)
    INSTALL(CODE
        "include(${CMAKE_CURRENT_LIST_DIR}/AppImage.cmake)
        make_appimage(
            EXE \"${CMAKE_BINARY_DIR}/${PROJECT_NAME}\"
            NAME \"${PROJECT_NAME}\"
            ICON \"${PROJECT_SOURCE_DIR}/cmake/cpack/icon.svg\"
            DIR_ICON \"${PROJECT_SOURCE_DIR}/cmake/cpack/diricon.png\"
            OUTPUT_NAME \"${CMAKE_BINARY_DIR}/${PROJECT_NAME}.AppImage\"
            ASSETS \"tastatura.txt\"
        )
        "
        COMPONENT Runtime
    )
endif()
