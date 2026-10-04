#!/usr/bin/bash

DEFAULT_BUILD_DIR="build"
DEFAULT_BUILD_TYPE="Debug"
DEFAULT_INSTALL_DIR="install_dir"
DEFAULT_BUILD_TESTING='ON'

# Pentru a folosi biblioteci instalate deja local cu FetchContent:
# ./scripts/cmake.sh configure -e "-DFETCHCONTENT_BASE_DIR=~/.local/fetchcontent-deps"
# sau
# mkdir -p ~/.local/fetchcontent-deps
# export FETCHCONTENT_BASE_DIR=~/.local/fetchcontent-deps

configure() {
    # cmake -S . -B build -DCMAKE_BUILD_TYPE=Debug
    #
    BUILD_DIR="${DEFAULT_BUILD_DIR}"
    BUILD_TYPE="${DEFAULT_BUILD_TYPE}"
    INSTALL_DIR="${DEFAULT_INSTALL_DIR}"
    BUILD_TESTING="${DEFAULT_BUILD_TESTING}"
    SOURCE_DIR="."
    CMAKE_OPTS=()

    while getopts ":b:c:e:g:i:s:t:" opt; do
      case "${opt}" in
        b) BUILD_DIR="${OPTARG}"
        ;;
        c) BUILD_TYPE="${OPTARG}"
        ;;
        e) IFS=" " read -r -a CMAKE_OPTS <<< "${OPTARG}"
        ;;
        g) export CMAKE_GENERATOR="${OPTARG}"
        ;;
        i) INSTALL_DIR="${OPTARG}"
        ;;
        s) SOURCE_DIR="${OPTARG}"
        ;;
        t) BUILD_TESTING="${OPTARG}"
           if [[ "${BUILD_TESTING}" != 'ON' && "${BUILD_TESTING}" != 'OFF' ]]; then
            echo "Invalid value for -t: $BUILD_TESTING. Use ON or OFF."
            exit 1
           fi
        ;;
        *) printf "Unknown option %s; available options: \n\
            -b (build dir)\n\
            -c (CMake config build type)\n\
            -e (extra CMake options)\n\
            -g (generator)\n\
            -i (install dir prefix)\n\
            -s (source dir)\n\
            -t (build tests ON/OFF -> -DBUILD_TESTING)\n"\
            "${opt}"
           exit 1
        ;;
      esac
    done

    cmake -B "${BUILD_DIR}" \
          -S "${SOURCE_DIR}" \
          -DCMAKE_BUILD_TYPE="${BUILD_TYPE}" \
          -DCMAKE_INSTALL_PREFIX="${INSTALL_DIR}" \
          -DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
          -DBUILD_TESTING="${BUILD_TESTING}" \
          "${CMAKE_OPTS[@]}"
}

build() {
    # cmake --build build --config Debug -j6
    #
    BUILD_DIR="${DEFAULT_BUILD_DIR}"
    BUILD_TYPE="${DEFAULT_BUILD_TYPE}"
    NPROC=6
    CMAKE_OPTS=()

    while getopts ":b:c:e:j:" opt; do
      case "${opt}" in
        b) BUILD_DIR="${OPTARG}"
        ;;
        c) BUILD_TYPE="${OPTARG}"
        ;;
        e) IFS=" " read -r -a CMAKE_OPTS <<< "${OPTARG}"
        ;;
        j) NPROC="${OPTARG}"
        ;;
        *) printf "Unknown option %s; available options: \n\
            -b (build dir)\n\
            -c (CMake config build type)\n\
            -e (extra CMake options)\n\
            -j (number of jobs for parallel build)\n"\
            "${opt}"
           exit 1
        ;;
      esac
    done

    cmake --build "${BUILD_DIR}" \
          --config "${BUILD_TYPE}" \
          -j "${NPROC}" \
          "${CMAKE_OPTS[@]}"
}

test() {
    # bash ./scripts/run_tests.sh -b build -c Debug -r
    #
    BUILD_DIR="${DEFAULT_BUILD_DIR}"
    BUILD_TYPE="${DEFAULT_BUILD_TYPE}"
    RUN_TESTS_SCRIPT_OPTS=()    # -r: zero registered tests is an error, see scripts/run_tests.sh

    while getopts ":b:c:r" opt; do
        case "${opt}" in
          b) BUILD_DIR="${OPTARG}"
          ;;
          c) BUILD_TYPE="${OPTARG}"
          ;;
          r) RUN_TESTS_SCRIPT_OPTS+=("-r")
          ;;
          *) printf "Unknown option %s; available options: \n\
              -b (build dir)\n\
              -c (CMake config build type)\n\
              -r (fail when no test is registered)\n"\
              "${opt}"
            exit 1
          ;;
        esac
    done

    bash "$(dirname "${BASH_SOURCE[0]}")/run_tests.sh" \
          -b "${BUILD_DIR}" \
          -c "${BUILD_TYPE}" \
          "${RUN_TESTS_SCRIPT_OPTS[@]}"
}

install() {
    # cmake --install build --config Debug --prefix install_dir
    #
    BUILD_DIR="${DEFAULT_BUILD_DIR}"
    BUILD_TYPE="${DEFAULT_BUILD_TYPE}"
    INSTALL_DIR="${DEFAULT_INSTALL_DIR}"
    while getopts ":b:c:i:" opt; do
      case "${opt}" in
        b) BUILD_DIR="${OPTARG}"
        ;;
        c) BUILD_TYPE="${OPTARG}"
        ;;
        i) INSTALL_DIR="${OPTARG}"
        ;;
        *) printf "Unknown option %s; available options: \n\
            -b (build dir)\n\
            -c (CMake config build type)\n\
            -i (install dir prefix)\n"\
            "${opt}"
           exit 1
        ;;
      esac
    done

    cmake --install "${BUILD_DIR}" \
          --config "${BUILD_TYPE}" \
          --prefix "${INSTALL_DIR}"
}

case "$1" in
    configure)
    shift
    configure "$@"
    ;;
    build)
    shift
    build "$@"
    ;;
    test)
    shift
    test "$@"
    ;;
    install)
    shift
    install "$@"
    ;;
    *) printf "Unknown option %s; available options: \n\
        configure\n\
        build\n\
        test\n\
        install\n" "${opt}"
       exit 1
esac
