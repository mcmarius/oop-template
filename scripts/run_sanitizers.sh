#!/usr/bin/bash

INPUT_FILENAME=${INPUT_FILENAME:-tastatura.txt}
ZIP_NAME=${ZIP_NAME:-install_dir/bin}
EXECUTABLE_NAME=${EXECUTABLE_NAME:-oop}

tr -d '\r' < "${INPUT_FILENAME}" | ./"${ZIP_NAME}"/"${EXECUTABLE_NAME}" &
bash ./scripts/run_test.sh 3 1 2
