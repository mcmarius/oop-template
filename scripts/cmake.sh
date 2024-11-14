#!/usr/bin/bash

DEFAULT_BUILD_DIR="build"
DEFAULT_BUILD_TYPE="Debug"
DEFAULT_INSTALL_DIR="install_dir"

configure() {
    # cmake -S . -B build -DCMAKE_BUILD_TYPE=Debug
    #
    BUILD_DIR="${DEFAULT_BUILD_DIR}"
    BUILD_TYPE="${DEFAULT_BUILD_TYPE}"
    INSTALL_DIR="${DEFAULT_INSTALL_DIR}"
    SOURCE_DIR="."
    CMAKE_OPTS=()

    while getopts ":b:c:e:g:i:s:" opt; do
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
        *) printf "Unknown option %s; available options: \n\
            -b (build dir)\n\
            -c (CMake config build type)\n\n\
            -e (extra CMake options)\n\
            -g (generator)\n\
            -i (install dir prefix)\n\
            -s (source dir)\n"\
            "${opt}"
          exit 1
        ;;
      esac
    done

    cmake -S "${SOURCE_DIR}" \
          -B "${BUILD_DIR}" \
          -DCMAKE_BUILD_TYPE="${BUILD_TYPE}" \
          -DCMAKE_INSTALL_PREFIX="${INSTALL_DIR}" \
          "${CMAKE_OPTS[@]}"
}

build() {
    # cmake --build build --config Debug -j6
    #
    BUILD_DIR="${DEFAULT_BUILD_DIR}"
    BUILD_TYPE="${DEFAULT_BUILD_TYPE}"
    NPROC=6

    while getopts ":b:c:h:j:" opt; do
      case "${opt}" in
        b) BUILD_DIR="${OPTARG}"
        ;;
        c) BUILD_TYPE="${OPTARG}"
        ;;
        j) NPROC="${OPTARG}"
        ;;
        h) printf "Unknown option %s; available options: \n\
            -b (build dir)\n\
            -c (CMake config build type)\n\
            -j (number of jobs for parallel build)\n"\
            "${opt}"
          exit 1
        ;;
        *)
        ;;
      esac
      shift $((OPTIND-1))
    done

    cmake --build "${BUILD_DIR}" --config "${BUILD_TYPE}" -j "${NPROC}" "$@"
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
        i) INSTALL_DIR="${OPTARG}"
        ;;
        c) BUILD_TYPE="${OPTARG}"
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

    cmake --install "${BUILD_DIR}" --config "${BUILD_TYPE}" --prefix "${INSTALL_DIR}"
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
    install)
    shift
    install "$@"
    ;;
    *) printf "Unknown option %s; available options: \n\
        configure\n\
        build\n\
        install\n" "${opt}"
      exit 1
esac

