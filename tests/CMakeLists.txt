project(${TESTS_PROJECT_NAME})
FetchContent_Declare(
        gtest
        GIT_REPOSITORY https://github.com/google/googletest.git
        GIT_TAG main
)
FetchContent_MakeAvailable(gtest)

add_executable(${TESTS_EXECUTABLE_NAME}
        main.cpp
        exemplu_test_oop.cpp
        exemplu_test_simplu.cpp
)
target_link_libraries(${TESTS_EXECUTABLE_NAME} PRIVATE ${MAIN_PROJECT_NAME}_lib gtest gtest_main)
include(${CMAKE_HELPER_DIR}/CompilerFlags.cmake)
add_test(NAME ${TESTS_EXECUTABLE_NAME} COMMAND ${TESTS_PROJECT_NAME})

install(TARGETS ${TESTS_EXECUTABLE_NAME} DESTINATION ${DESTINATION_DIR})
if(APPLE)
    install(FILES ${PROJECT_ROOT}/launcher.command DESTINATION ${DESTINATION_DIR})
endif()
copy_files(FILES tastatura.txt COPY_TO_DESTINATION TARGET_NAME ${TESTS_EXECUTABLE_NAME})