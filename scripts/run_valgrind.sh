#!/usr/bin/bash

# remove --show-leak-kinds=all (and --track-origins=yes) if there are many leaks in external libs
INPUT_FILENAME=${INPUT_FILENAME:-tastatura.txt}
ZIP_NAME=${ZIP_NAME:-install_dir/bin}
EXECUTABLE_NAME=${EXECUTABLE_NAME:-oop}

#           --gen-suppressions=all \
tr -d '\r' < "${INPUT_FILENAME}" | \
  valgrind --leak-check=full \
           --show-leak-kinds=all \
           --leak-resolution=med \
           --track-origins=yes \
           --vgdb=no \
           --suppressions=./scripts/valgrind-suppressions.supp \
           --error-exitcode=0 ./"${ZIP_NAME}"/"${EXECUTABLE_NAME}" &
bash ./scripts/run_test.sh 10 1 2
