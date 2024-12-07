project(tests)
FetchContent_Declare(
        gtest
        GIT_REPOSITORY https://github.com/google/googletest.git
        GIT_TAG main
)
FetchContent_MakeAvailable(gtest)

add_executable(${PROJECT_NAME}
        main.cpp
        exemplu_test_oop.cpp
        exemplu_test_simplu.cpp
)
target_link_libraries(${PROJECT_NAME} PRIVATE source_lib gtest gtest_main)
include(${CMAKE_HELPER_DIR}/CompilerFlags.cmake)
add_test(NAME ${PROJECT_NAME} COMMAND ${PROJECT_NAME})

install(TARGETS ${PROJECT_NAME} DESTINATION ${DESTINATION_DIR})
if(APPLE)
    install(FILES ${PROJECT_ROOT}/launcher.command DESTINATION ${DESTINATION_DIR})
endif()
copy_files(FILES tastatura.txt)