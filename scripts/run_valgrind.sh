#!/usr/bin/bash

INPUT_FILENAME=${INPUT_FILENAME:-tastatura.txt}
RUN_INTERACTIVE=${RUN_INTERACTIVE:-false}
BUILD_DIR=${BUILD_DIR:-build}
EXECUTABLE_NAME=${EXECUTABLE_NAME:-oop}

if [[ -n "$1" ]]; then
    BIN_DIR="$1"
elif [[ -d "install_dir/bin" ]]; then
    BIN_DIR="install_dir/bin"
else
    BIN_DIR="${BUILD_DIR}"
fi

run_valgrind() {
    # remove --show-leak-kinds=all (and --track-origins=yes) if there are many leaks in external libs
    valgrind --leak-check=full \
             --show-leak-kinds=all \
             --track-origins=yes \
             --error-exitcode=1 \
             ./"${BIN_DIR}"/"${EXECUTABLE_NAME}"
}

if [[ "${RUN_INTERACTIVE}" = true ]]; then
    run_valgrind
else
    tr -d '\r' < "${INPUT_FILENAME}" | run_valgrind
fi
