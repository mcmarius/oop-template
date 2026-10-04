#!/usr/bin/bash

# Dynamic analysis (Valgrind/memcheck) of the executables of the project.
#
#   bash ./scripts/run_valgrind.sh [BIN_DIR] [EXECUTABLE...]
#
#   BIN_DIR     directory the executables are taken from;
#               default: install_dir/bin when it exists, otherwise ${BUILD_DIR}
#   EXECUTABLE  which executables to check, in order;
#               default: ${EXECUTABLE_NAMES}, the app plus the test binary
#
# Environment:
#   BUILD_DIR                build directory                 (default: build)
#   INPUT_FILENAME           fed on stdin                    (default: tastatura.txt)
#   RUN_INTERACTIVE          true = keep the terminal on stdin (default: false)
#   EXECUTABLE_NAME          the application                 (default: oop_main)
#   TESTS_EXECUTABLE_NAME    the test binary                 (default: oop_test)
#   EXECUTABLE_NAMES         space separated list, replaces the two names above
#
# The test binary is in the default list on purpose: it reaches library code that
# tastatura.txt never touches, which is where the memory errors actually hide.
# CI runs this script unchanged (.github/actions/runtime-checks/action.yml), so a
# local run gives the CI verdict. The ASan rows need neither this nor a second
# build: `Run tests` already executes the sanitizer-instrumented test binary.
#
# An executable of the list that is not in BIN_DIR is an error, never a skip: a
# check that silently stopped running is worse than a red CI. To check fewer
# executables, name them on the command line.
#
# Every executable is checked, not only the first: one leak must not hide the rest.
# If the test framework itself trips memcheck, add a suppression to
# valgrind-suppressions.supp (--gen-suppressions=all prints one for the report);
# never compile a second, un-instrumented copy of the library to make it quiet.

INPUT_FILENAME=${INPUT_FILENAME:-tastatura.txt}
RUN_INTERACTIVE=${RUN_INTERACTIVE:-false}
BUILD_DIR=${BUILD_DIR:-build}
# the defaults are the targets of CMakeLists.txt (MAIN_EXECUTABLE_NAME, TESTS_EXECUTABLE_NAME);
# CI passes the app name from the env of .github/workflows/cmake.yml
EXECUTABLE_NAMES=${EXECUTABLE_NAMES:-${EXECUTABLE_NAME:-oop_main} ${TESTS_EXECUTABLE_NAME:-oop_test}}
SCRIPT_RUN_DIR="$(dirname "${0}")"

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

# an empty list would exit 0 having checked nothing, the way ctest exits 0 with no
# registered test; a dynamic analysis row that analyses nothing is never a pass
if [[ ${#EXECUTABLES[@]} -eq 0 ]]; then
    echo "Error: no executable to analyse. EXECUTABLE_NAMES is empty and none was given."
    exit 1
fi

if [[ "${RUN_INTERACTIVE}" != true && ! -r "${INPUT_FILENAME}" ]]; then
    echo "Warning: ${INPUT_FILENAME} not readable; running with empty stdin."
    INPUT_FILENAME="/dev/null"
fi

run_valgrind() {
    # no ./ prefix in front of BIN_DIR: it always contains a /, so valgrind still
    # treats the argument as a path and never searches PATH, and an absolute
    # BIN_DIR works too
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
        echo "Build it (BUILD_TESTING is ON unless you turned it off) and install it:"
        echo "    bash ./scripts/cmake.sh install"
        echo "or name only the executables you want checked:"
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
