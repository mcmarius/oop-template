#!/usr/bin/bash

INPUT_FILENAME=${INPUT_FILENAME:-tastatura.txt}
EXECUTABLE_NAME=${EXECUTABLE_NAME:-oop_main}
TESTS_EXECUTABLE_NAME=${TESTS_EXECUTABLE_NAME:-oop_test}

tr -d '\r' < "${INPUT_FILENAME}" | "./${EXECUTABLE_NAME}" &
bash ../scripts/run_ui_test.sh 3 1 2
"./${TESTS_EXECUTABLE_NAME}"
