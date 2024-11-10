###############################################################################

# NOTE: Also update env vars used for caching in
#         - .github/actions/configure-cmake/action.yml
#         - .github/workflows/cmake.yml
# FetchContent_Declare(
#         SomeLib
#         GIT_REPOSITORY https://github.com/<SomeUser>/<SomeLib>.git
#         GIT_TAG        <some_git_hash> # <which tag/branch @ <some_date>>
#         GIT_SHALLOW    1  # works only with branches or tags, not with arbitrary commit hashes
# )
#
# FetchContent_MakeAvailable(SomeLib)

###############################################################################

# external dependencies with find_package

# find_package(Threads REQUIRED)

###############################################################################

add_library(${MAIN_PROJECT_LIB_NAME}
            exemplu_test_oop/BankAccount.cpp
            exemplu_test_oop/BankAccount.h
)

target_include_directories(${MAIN_PROJECT_LIB_NAME} PUBLIC
            exemplu_test_oop/
)

add_executable(${MAIN_EXECUTABLE_NAME}
        main.cpp
)

set_compiler_flags(TARGET_NAMES ${MAIN_EXECUTABLE_NAME} ${MAIN_PROJECT_LIB_NAME})

target_link_libraries(${MAIN_EXECUTABLE_NAME} PRIVATE ${MAIN_PROJECT_LIB_NAME})
###############################################################################

# use SYSTEM so cppcheck and clang-tidy do not report warnings from these directories
# target_include_directories(${MAIN_PROJECT_NAME} SYSTEM PRIVATE ext/<SomeHppLib>/include)
# target_include_directories(${MAIN_PROJECT_NAME} SYSTEM PRIVATE ${<SomeLib>_SOURCE_DIR}/include)
# target_link_directories(${MAIN_PROJECT_NAME} PRIVATE ${<SomeLib>_BINARY_DIR}/lib)
# target_link_libraries(${MAIN_PROJECT_NAME} <SomeLib>)

###############################################################################

# copy binaries to "bin" folder; these are uploaded as artifacts on each release
# DESTINATION_DIR is set as "bin" in cmake/Options.cmake:6

install(TARGETS ${MAIN_PROJECT_NAME} DESTINATION ${DESTINATION_DIR})
if(APPLE)
    install(FILES ${PROJECT_ROOT}/launcher.command DESTINATION ${DESTINATION_DIR})
endif()
copy_files(FILES tastatura.txt COPY_TO_DESTINATION TARGET_NAME ${MAIN_EXECUTABLE_NAME})

# copy_files copiaza fisiere din radacina proiectului
# copy_files(FILES tastatura.txt config.json DIRECTORY images sounds COPY_TO_DESTINATION TARGET_NAME ${MAIN_EXECUTABLE_NAME})
# copy_files(DIRECTORY images sounds COPY_TO_DESTINATION TARGET_NAME ${MAIN_EXECUTABLE_NAME})
