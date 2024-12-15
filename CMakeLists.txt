cmake_minimum_required(VERSION 3.26)

# NOTE: update executable name in .github/workflows/cmake.yml:25 when changing executable name in this file
# for now, the project name is used as the executable name
set(MAIN_PROJECT_NAME "oop")
set(MAIN_EXECUTABLE_NAME "${MAIN_PROJECT_NAME}")


project(${MAIN_PROJECT_NAME})
# set(CMAKE_PROJECT_VERSION_MAJOR 0)
# set(CMAKE_PROJECT_VERSION_MINOR 0)
# set(CMAKE_PROJECT_VERSION_PATCH 1)

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

include(cmake/Options.cmake)
include(cmake/CompilerFlags.cmake)
include(cmake/CopyHelper.cmake)

###############################################################################

# external dependencies with FetchContent

include(FetchContent)

set(FETCHCONTENT_QUIET OFF)
set(FETCHCONTENT_UPDATES_DISCONNECTED ON)

set(SFML_WARNINGS_AS_ERRORS OFF)

# NOTE: Also update SFML_VERSION env var in .github/workflows/cmake.yml:33
FetchContent_Declare(
    SFML
    GIT_REPOSITORY https://github.com/SFML/SFML.git
    # renovate: datasource=github-tags depName=SFML/SFML versioning=loose
    GIT_TAG        3.0.0
    # renovate: depName=SFML/SFML
    # GIT_TAG        7f1162dfea4969bc17417563ac55d93b72e84c1e # 3.0.0
    GIT_SHALLOW    1  # works only with branches or tags, not with arbitrary commit hashes
)

FetchContent_MakeAvailable(SFML)

###############################################################################

# external dependencies with find_package

find_package(Threads REQUIRED)
if(APPLE)
elseif(UNIX)
    find_package(X11)
endif()

###############################################################################

# NOTE: update executable name in .github/workflows/cmake.yml:25 when changing name here
add_executable(${MAIN_EXECUTABLE_NAME}
    main.cpp
    ResourceManager.cpp
    ResourceManager.hpp
)

# NOTE: Add all defined targets (e.g. executables, libraries, etc. )
# NOTE: RUN_SANITIZERS is optional, if it's not present it will default to true
set_compiler_flags(RUN_SANITIZERS TRUE TARGET_NAMES ${MAIN_EXECUTABLE_NAME})
# set_compiler_flags(TARGET_NAMES ${MAIN_EXECUTABLE_NAME} ${FOO} ${BAR})
# where ${FOO} and ${BAR} represent additional executables or libraries
# you want to compile with the set compiler flags

###############################################################################

# use SYSTEM so cppcheck and clang-tidy do not report warnings from these directories
# target_include_directories(${MAIN_EXECUTABLE_NAME} SYSTEM PRIVATE ext/<SomeHppLib>/include)
target_include_directories(${MAIN_EXECUTABLE_NAME} SYSTEM PRIVATE ${SFML_SOURCE_DIR}/include)
target_link_directories(${MAIN_EXECUTABLE_NAME} PRIVATE ${SFML_BINARY_DIR}/lib)
target_link_libraries(${MAIN_EXECUTABLE_NAME} PRIVATE SFML::Graphics SFML::Window SFML::System Threads::Threads)

if(APPLE)
elseif(UNIX)
    target_link_libraries(${MAIN_EXECUTABLE_NAME} PRIVATE X11)
endif()

###############################################################################

# copy binaries to "bin" folder; these are uploaded as artifacts on each release
# DESTINATION_DIR is set as "bin" in cmake/Options.cmake:6
install(TARGETS ${MAIN_EXECUTABLE_NAME} DESTINATION ${DESTINATION_DIR})
if(APPLE)
    install(FILES launcher.command DESTINATION ${DESTINATION_DIR})
endif()


copy_files(FILES tastatura.txt COPY_TO_DESTINATION TARGET_NAME ${MAIN_EXECUTABLE_NAME})

# Pentru a putea folosi imagini, sunete, font-uri custom în cadrul programului avem nevoie de funcția `copy_files()`
# Dacă avem mai multe foldere de resurse locale le adăugăm și pe acelea după ce am specificat DIRECTORY în funcția `copy_files()`.
# Exemplu general: copy_files(DIRECTORY folder1 folder2 folder3 COPY_TO_DESTINATION TARGET_NAME ${MAIN_EXECUTABLE_NAME})
# Exemplu 1: Avem un folder cu imagini numit `images` și un folder cu sunete numit `sounds`
#       => copy_files(DIRECTORY images sounds COPY_TO_DESTINATION TARGET_NAME ${MAIN_EXECUTABLE_NAME})
# Exemplu 2: Avem un folder cu font-uri numit `fonts`, un folder cu imagini numit `images` și un folder cu sunete numit `sounds`
#       => copy_files(DIRECTORY fonts images sounds COPY_TO_DESTINATION TARGET_NAME ${MAIN_EXECUTABLE_NAME})
# Pentru exemplul din main.cpp avem nevoie de folder-ul `images` și de folder-ul `fonts`.
copy_files(DIRECTORY images fonts COPY_TO_DESTINATION TARGET_NAME ${MAIN_EXECUTABLE_NAME})

# Dacă avem nevoie de fișiere care nu sunt organizate într-un folder folosim tot funcția `copy_files()`
# Exemplu general: copy_files(FILES fisier1.json fisier2.txt fisier3.in COPY_TO_DESTINATION TARGET_NAME ${MAIN_EXECUTABLE_NAME})
# Exemplu: Avem un fișier JSON care nu se află în nici un folder
# copy_files(FILES un_fisier.json COPY_TO_DESTINATION TARGET_NAME ${MAIN_EXECUTABLE_NAME})

# Dacă avem nevoie de fișiere care nu sunt organizate într-un folder și de fișiere organizate în foldere folosim funcția `copy_files()`
# Exemplu general: copy_files(FILES fisier1.json fisier2.txt fisier3.in DIRECTORY un_folder un_alt_folder alt_folder COPY_TO_DESTINATION TARGET_NAME ${MAIN_EXECUTABLE_NAME})
# Exemplu: copy_files(FILES config.json DIRECTORY images sounds COPY_TO_DESTINATION TARGET_NAME ${MAIN_EXECUTABLE_NAME})
