#!/usr/bin/bash

INPUT_FILE=${INPUT_FILE:-tastatura.txt}
RUN_INTERACTIVE=${RUN_INTERACTIVE:-false}
BUILD_DIR=${BUILD_DIR:-build}
EXECUTABLE_NAME=${EXECUTABLE_NAME:-oop}

if [ -d "install_dir/bin" ]; then
    ZIP_NAME="install_dir/bin"
else
    ZIP_NAME="$BUILD_DIR"
fi

run_valgrind() {
    # remove --show-leak-kinds=all (and --track-origins=yes) if there are many leaks in external libs
    valgrind --leak-check=full \
            --show-leak-kinds=all \
            --track-origins=yes \
            --error-exitcode=1 \
            ./${ZIP_NAME}/"${EXECUTABLE_NAME}"
}

if [ "$RUN_INTERACTIVE" = true ]; then
    run_valgrind
else
    cat "$INPUT_FILE" | tr -d '\r' | run_valgrind
fi