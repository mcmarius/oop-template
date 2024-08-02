#!/usr/bin/bash

configure() {
    # cmake -S . -B build -DCMAKE_BUILD_TYPE=Debug
    #
    BUILD_DIR=build
    BUILD_TYPE=Debug
    INSTALL_DIR=install_dir
    SOURCE_DIR=.
    CMAKE_OPTS=()

    while getopts ":b:c:g:i:s:t:" opt; do
      case "${opt}" in
        b) BUILD_DIR="${OPTARG}"
        ;;
        c) IFS=" " read -r -a CMAKE_OPTS <<< "${OPTARG}"
        ;;
        g) export CMAKE_GENERATOR="${OPTARG}"
        ;;
        i) INSTALL_DIR="${OPTARG}"
        ;;
        s) SOURCE_DIR="${OPTARG}"
        ;;
        t) BUILD_TYPE="${OPTARG}"
        ;;
        *) printf "Unknown option; available options: \n\
            -b (build dir)\n\
            -c (custom CMake options)\n\
            -g (generator)\n\
            -i (install dir prefix)\n\
            -s (source dir)\n\
            -t (build type)\n"
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
    cmake --build "${BUILD_DIR:-build}" --config "${BUILD_TYPE:-Debug}" -j "${NPROC:-6}" "$@"
}

install() {
    # cmake --install build --config Debug --prefix install_dir
    #
    INSTALL_DIR="${INSTALL_DIR:-install_dir}"
    echo primit install "$@"
    cmake --install "${BUILD_DIR:-build}" --config "${BUILD_TYPE:-Debug}" --prefix "${INSTALL_DIR:-install_dir}"
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
    *) printf "Unknown option; available options: \n\
        configure\n\
        build\n\
        install\n"
      exit 1
esac

