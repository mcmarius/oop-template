#!/usr/bin/bash

INPUT_FILENAME=${INPUT_FILENAME:-tastatura.txt}
EXECUTABLE_NAME=${EXECUTABLE_NAME:-oop_main}
TESTS_EXECUTABLE_NAME=${TESTS_EXECUTABLE_NAME:-oop_test}
SCRIPT_RUN_DIR="$(cd "$(dirname "${0}")" && pwd)"

# must be LSAN_OPTIONS: GCC libasan rejects "leak:" rules in ASAN_OPTIONS=suppressions
ASAN_SUPPRESSIONS="${SCRIPT_RUN_DIR}/asan-suppressions.supp"
if [[ -r "${ASAN_SUPPRESSIONS}" ]]; then
    export LSAN_OPTIONS="${LSAN_OPTIONS:+${LSAN_OPTIONS}:}suppressions=${ASAN_SUPPRESSIONS}"
fi

tr -d '\r' < "${INPUT_FILENAME}" | "./${EXECUTABLE_NAME}" &
bash ../scripts/run_ui_test.sh 3 1 2
"./${TESTS_EXECUTABLE_NAME}"
