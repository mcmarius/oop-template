#!/usr/bin/bash
#
# bash ./scripts/run_valgrind.sh [BIN_DIR] [EXECUTABLE...]
#     BIN_DIR     default: install_dir/bin if it exists, else ${BUILD_DIR}
#     EXECUTABLE  default: ${EXECUTABLE_NAMES} = the app + the test binary
#
# Smoke test (tastatura.txt) + test binaries (should be orthogonal to smoke test).
# If a framework trips memcheck, add the suppression its report prints
# (--gen-suppressions=all) and open a pull request; contributions welcome.

INPUT_FILENAME=${INPUT_FILENAME:-tastatura.txt}
RUN_INTERACTIVE=${RUN_INTERACTIVE:-false}
BUILD_DIR=${BUILD_DIR:-build}
EXECUTABLE_NAMES=${EXECUTABLE_NAMES:-${EXECUTABLE_NAME:-oop_main} ${TESTS_EXECUTABLE_NAME:-oop_test}}
SCRIPT_RUN_DIR="$(dirname "${0}")"

# TODO: refactor into functions

if [[ -n "$1" ]]; then
    BIN_DIR="$1"
    shift
elif [[ -d "install_dir/bin" ]]; then
    BIN_DIR="install_dir/bin"
else
    BIN_DIR="${BUILD_DIR}"
fi

if [[ $# -gt 0 ]]; then
    EXECUTABLES=("$@")
else
    read -r -a EXECUTABLES <<< "${EXECUTABLE_NAMES}"
fi

# an empty list would exit 0 having checked nothing
if [[ ${#EXECUTABLES[@]} -eq 0 ]]; then
    echo "Error: no executable to analyse. EXECUTABLE_NAMES is empty and none was given."
    exit 1
fi

if [[ "${RUN_INTERACTIVE}" != true && ! -r "${INPUT_FILENAME}" ]]; then
    echo "Warning: ${INPUT_FILENAME} not readable; running with empty stdin."
    INPUT_FILENAME="/dev/null"
fi

run_valgrind() {
    # no ./ prefix: BIN_DIR always contains a /, so valgrind never searches PATH
    # remove --show-leak-kinds=all (and --track-origins=yes) if there are many leaks in external libs
    valgrind --leak-check=full \
             --show-leak-kinds=all \
             --track-origins=yes \
             --leak-resolution=med \
             --vgdb=no \
             --gen-suppressions=all \
             --suppressions="${SCRIPT_RUN_DIR}/valgrind-suppressions.supp" \
             --error-exitcode=1 \
             "${BIN_DIR}/$1"
}

exit_code=0

for executable in "${EXECUTABLES[@]}"; do
    if [[ ! -f "${BIN_DIR}/${executable}" ]]; then
        echo "Error: ${BIN_DIR}/${executable} not found."
        echo "Build and install it (bash ./scripts/cmake.sh install), or check fewer executables:"
        echo "    bash ./scripts/run_valgrind.sh ${BIN_DIR} ${EXECUTABLE_NAME:-oop_main}"
        exit_code=1
        continue
    fi

    echo "=== Valgrind: ${BIN_DIR}/${executable} ==="
    if [[ "${RUN_INTERACTIVE}" = true ]]; then
        run_valgrind "${executable}"
    else
        tr -d '\r' < "${INPUT_FILENAME}" | run_valgrind "${executable}"
    fi
    rc=$?

    if [[ ${rc} -ne 0 ]]; then
        echo "Valgrind reported problems for ${executable} (exit code ${rc})."
        if [[ ${exit_code} -eq 0 ]]; then
            exit_code=${rc}
        fi
    fi
done

exit "${exit_code}"
